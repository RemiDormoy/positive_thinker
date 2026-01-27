import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'dart:js' as js;

class GeminiNanoService {
  static const MethodChannel _channel = MethodChannel('gemini_nano_service');

  /// Génère une réponse en utilisant Gemini Nano sur Android ou Web
  /// ou retourne un message d'indisponibilité sur les autres plateformes
  Future<String> generateResponse(String input) async {
    if (kIsWeb) {
      return _callWebMethod('prompt', input);
    } else if (Platform.isAndroid) {
      try {
        final String result = await _channel.invokeMethod('prompt', input);
        return result;
      } catch (e, s) {
        debugPrint(e.toString());
        debugPrint(s.toString());
        return "Je ne suis pas disponible sur ce device";
      }
    } else {
      return "Je ne suis pas disponible sur ce device";
    }
  }

  Future<String> summarize(String input) async {
    if (kIsWeb) {
      return _callWebMethod('summarize', input);
    } else if (Platform.isAndroid) {
      try {
        final String result = await _channel.invokeMethod('summarize', input);
        return result;
      } catch (e, s) {
        debugPrint(e.toString());
        debugPrint(s.toString());
        return "Je ne suis pas disponible sur ce device";
      }
    } else {
      return "Je ne suis pas disponible sur ce device";
    }
  }


  Future<String> generateResponseWithImage(File input) async {
    if (kIsWeb) {
      try {
        debugPrint('début de l\'analyse de l\'image (web)');
        final String imageResult = await _callWebMethod('imageDescription', input.path);
        debugPrint('imageResult : $imageResult');
        final finalPrompt = """Imagine que je t'envoie l'image avec la description suivante : $imageResult.
        Tu es un chien qui doit me faire voir la vie en positif.
        Je veux que tu me la redécrive, en tant que chien qui parle français, en moins de 100 mots, et de manière beaucoup plus positive. 
        """;
        final String result = await generateResponse(finalPrompt);
        return result;
      } catch (e, s) {
        debugPrint(e.toString());
        debugPrint(s.toString());
        return "Je ne suis pas disponible sur ce device";
      }
    } else if (Platform.isAndroid) {
      try {
        debugPrint('début de l\'analyse de l\'image');
        final String imageResult = await _channel.invokeMethod('imageDescription', input.path);
        debugPrint('imageResult : $imageResult');
        final finalPrompt = """Imagine que je t'envoie l'image avec la description suivante : $imageResult.
        Tu es un chien qui doit me faire voir la vie en positif.
        Je veux que tu me la redécrive, en tant que chien qui parle français, en moins de 100 mots, et de manière beaucoup plus positive. 
        """;
        final String result = await generateResponse(finalPrompt);
        return result;
      } catch (e, s) {
        debugPrint(e.toString());
        debugPrint(s.toString());
        return "Je ne suis pas disponible sur ce device";
      }
    } else {
      return "Je ne suis pas disponible sur ce device";
    }
  }

  Future<bool> initialize() async {
    if (kIsWeb) {
      try {
        final result = await _callWebMethod('initialize', null);
        return result == 'true' || result == true;
      } catch (e) {
        debugPrint('Erreur initialisation web: $e');
        return false;
      }
    } else if (Platform.isAndroid) {
      try {
        await _channel.invokeMethod('initialize');
        return true;
      } catch (e) {
        return false;
      }
    } else {
      return false;
    }
  }

  Future<String> reformulate(String userInput, GeminiReformulate type) async {
    if (kIsWeb) {
      return _callWebMethod('reformulate', [userInput, type.toLabel()]);
    } else if (Platform.isAndroid) {
      try {
        final String result = await _channel.invokeMethod('reformulate', [userInput, type.toLabel()]);
        return result;
      } catch (e, s) {
        debugPrint(e.toString());
        debugPrint(s.toString());
        return "Je ne suis pas disponible sur ce device";
      }
    } else {
      return "Je ne suis pas disponible sur ce device";
    }
  }

  Future<String> correct(String userInput) async {
    if (kIsWeb) {
      return _callWebMethod('correct', userInput);
    } else if (Platform.isAndroid) {
      try {
        final String result = await _channel.invokeMethod('correct', userInput);
        return result;
      } catch (e, s) {
        debugPrint(e.toString());
        debugPrint(s.toString());
        return "Je ne suis pas disponible sur ce device";
      }
    } else {
      return "Je ne suis pas disponible sur ce device";
    }
  }

  /// Appelle une méthode sur le service web JavaScript
  Future<String> _callWebMethod(String method, dynamic arguments) async {
    try {
      if (!kIsWeb) {
        return "Méthode web appelée sur une plateforme non-web";
      }

      // Vérifier que le service web est disponible
      if (js.context['geminiNanoWebService'] == null) {
        debugPrint('Service web GeminiNano non trouvé');
        return "Service web non disponible";
      }

      // Créer et exécuter un appel JavaScript
      String jsCode = '';
      switch (method) {
        case 'initialize':
          jsCode = 'window.geminiNanoWebService.initialize()';
          break;
        case 'prompt':
          final escapedArg = arguments.toString().replaceAll('"', '\\"').replaceAll('\n', '\\n');
          jsCode = 'window.geminiNanoWebService.prompt("$escapedArg")';
          break;
        case 'summarize':
          final escapedArg = arguments.toString().replaceAll('"', '\\"').replaceAll('\n', '\\n');
          jsCode = 'window.geminiNanoWebService.summarize("$escapedArg")';
          break;
        case 'imageDescription':
          final escapedArg = arguments.toString().replaceAll('"', '\\"').replaceAll('\n', '\\n');
          jsCode = 'window.geminiNanoWebService.imageDescription("$escapedArg")';
          break;
        case 'correct':
          final escapedArg = arguments.toString().replaceAll('"', '\\"').replaceAll('\n', '\\n');
          jsCode = 'window.geminiNanoWebService.correct("$escapedArg")';
          break;
        case 'reformulate':
          if (arguments is List && arguments.length >= 2) {
            final escapedInput = arguments[0].toString().replaceAll('"', '\\"').replaceAll('\n', '\\n');
            final escapedType = arguments[1].toString().replaceAll('"', '\\"').replaceAll('\n', '\\n');
            jsCode = 'window.geminiNanoWebService.reformulate("$escapedInput", "$escapedType")';
          } else {
            return "Arguments invalides pour reformulate";
          }
          break;
        default:
          return "Méthode non supportée: $method";
      }
      
      // Exécuter le code JavaScript et attendre le résultat
      final result = await _executeJavaScriptAsync(jsCode);
      
      return result?.toString() ?? "Aucun résultat du service web";
    } catch (e) {
      debugPrint('Erreur lors de l\'appel web: $e');
      return "Erreur lors de l'appel web: $e";
    }
  }

  /// Exécute du code JavaScript de façon asynchrone
  Future<dynamic> _executeJavaScriptAsync(String jsCode) async {
    final completer = Completer<dynamic>();
    
    // Créer un wrapper qui gère l'asynchrone
    final wrappedCode = '''
      (async function() {
        try {
          const result = await $jsCode;
          window.dartCallback('success', result);
        } catch (error) {
          window.dartCallback('error', error.message);
        }
      })();
    ''';
    
    // Définir le callback Dart
    js.context['dartCallback'] = js.allowInterop((String status, dynamic result) {
      if (status == 'success') {
        completer.complete(result);
      } else {
        completer.completeError(result);
      }
      // Nettoyer le callback
      js.context['dartCallback'] = null;
    });
    
    // Exécuter le code
    js.context.callMethod('eval', [wrappedCode]);
    
    return completer.future;
  }
}

enum GeminiReformulate {
  DYNAMISE,
  EMOJIFY,
  REFORMULATE,
  DEVELOP;

  String toLabel() {
    switch (this) {
      case DEVELOP:
        return "DEVELOP";
      case EMOJIFY:
        return "EMOJIFY";
      case REFORMULATE:
        return "REFORMULATE";
      case DYNAMISE:
        return "DYNAMISE";
    }
  }
}
