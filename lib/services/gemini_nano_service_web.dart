import 'dart:async';
import 'dart:js' as js;

import 'package:flutter/cupertino.dart';

import 'gemini_nano_service.dart' as main;

class GeminiNanoService {
  /// Génère une réponse en utilisant Gemini Nano sur Web
  /// ou retourne un message d'indisponibilité sur les autres plateformes
  Future<String> generateResponse(String input) async {
    return _callWebMethod('prompt', input);
  }

  Future<String> summarize(String input) async {
    return _callWebMethod('summarize', input);
  }

  Future<String> generateResponseWithImage(dynamic input) async {
    try {
      debugPrint('début de l\'analyse de l\'image (web)');
      // Sur le web, input devrait être un String (chemin ou URL de l'image)
      final String imagePath = input is String ? input : input.toString();
      final String imageResult = await _callWebMethod('imageDescription', imagePath);
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
  }

  Future<bool> initialize() async {
    try {
      final result = await _callWebMethod('initialize', null);
      return result == 'true';
    } catch (e) {
      debugPrint('Erreur initialisation web: $e');
      return false;
    }
  }

  Future<String> reformulate(String userInput, main.GeminiReformulate type) async {
    return _callWebMethod('reformulate', [userInput, type.toLabel()]);
  }

  Future<String> correct(String userInput) async {
    return _callWebMethod('correct', userInput);
  }

  /// Appelle une méthode sur le service web JavaScript
  Future<String> _callWebMethod(String method, dynamic arguments) async {
    try {
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
    final wrappedCode =
        '''
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
