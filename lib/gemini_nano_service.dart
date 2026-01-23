import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

class GeminiNanoService {
  static const MethodChannel _channel = MethodChannel('gemini_nano_service');

  /// Génère une réponse en utilisant Gemini Nano sur Android
  /// ou retourne un message d'indisponibilité sur les autres plateformes
  Future<String> generateResponse(String input) async {
    // Vérifier si nous sommes sur Android
    if (Platform.isAndroid) {
      try {
        final String result = await _channel.invokeMethod('prompt', input);
        return result;
      } catch (e, s) {
        // En cas d'erreur avec le code natif, retourner le message d'indisponibilité
        debugPrint(e.toString());
        debugPrint(s.toString());
        return "Je ne suis pas disponible sur ce device";
      }
    } else {
      // iOS, Web ou autres plateformes
      return "Je ne suis pas disponible sur ce device";
    }
  }

  Future<String> summarize(String input) async {
    if (Platform.isAndroid) {
      try {
        final String result = await _channel.invokeMethod('summarize', input);
        return result;
      } catch (e, s) {
        // En cas d'erreur avec le code natif, retourner le message d'indisponibilité
        debugPrint(e.toString());
        debugPrint(s.toString());
        return "Je ne suis pas disponible sur ce device";
      }
    } else {
      // iOS, Web ou autres plateformes
      return "Je ne suis pas disponible sur ce device";
    }
  }


  Future<String> generateResponseWithImage(File input) async {
    // Vérifier si nous sommes sur Android
    if (Platform.isAndroid) {
      try {
        final String imageResult = await _channel.invokeMethod('imageDescription', input.path);
        debugPrint('imageResult : $imageResult');
        final finalPrompt = """Image que je t'envoie l'image avec la description suivante : $imageResult.
        Tu es chien qui doit me faire voir la vie en positif.
        Je veux que tu me redécrive, en tant que chien qui parle français, en moins de 100 mots, l'image de manière beaucoup plus positive. 
        """;
        final String result = await generateResponse(finalPrompt);
        return result;
      } catch (e, s) {
        // En cas d'erreur avec le code natif, retourner le message d'indisponibilité
        debugPrint(e.toString());
        debugPrint(s.toString());
        return "Je ne suis pas disponible sur ce device";
      }
    } else {
      // iOS, Web ou autres plateformes
      return "Je ne suis pas disponible sur ce device";
    }
  }

  Future<bool> initialize() async {
    // Vérifier si nous sommes sur Android
    if (Platform.isAndroid) {
      try {
        await _channel.invokeMethod('initialize');
        return true;
      } catch (e) {
        // En cas d'erreur avec le code natif, retourner le message d'indisponibilité
        return false;
      }
    } else {
      // iOS, Web ou autres plateformes
      return false;
    }
  }

  Future<String> reformulate(String userInput, GeminiReformulate type) async {
    if (Platform.isAndroid) {
      try {
        final String result = await _channel.invokeMethod('reformulate', [userInput, type.toLabel()]);
        return result;
      } catch (e, s) {
        // En cas d'erreur avec le code natif, retourner le message d'indisponibilité
        debugPrint(e.toString());
        debugPrint(s.toString());
        return "Je ne suis pas disponible sur ce device";
      }
    } else {
      // iOS, Web ou autres plateformes
      return "Je ne suis pas disponible sur ce device";
    }
  }
}

enum GeminiReformulate {
  DYNAMISE,
  EMOJIFY,
  DEVELOP;

  String toLabel() {
    switch (this) {
      case DEVELOP:
        return "DEVELOP";
      case EMOJIFY:
        return "EMOJIFY";
      case DYNAMISE:
        return "DYNAMISE";
    }
  }
}
