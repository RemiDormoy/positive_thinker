import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'gemini_nano_service.dart' as main;

class GeminiNanoService {
  static const MethodChannel _channel = MethodChannel('gemini_nano_service');

  /// Génère une réponse en utilisant Gemini Nano sur Android/iOS
  /// ou retourne un message d'indisponibilité sur les autres plateformes
  Future<String> generateResponse(String input) async {
      try {
        final String result = await _channel.invokeMethod('prompt', input);
        return result;
      } catch (e, s) {
        debugPrint(e.toString());
        debugPrint(s.toString());
        return "Je ne suis pas disponible sur ce device";
      }
  }

  Future<String> summarize(String input) async {
      try {
        final String result = await _channel.invokeMethod('summarize', input);
        return result;
      } catch (e, s) {
        debugPrint(e.toString());
        debugPrint(s.toString());
        return "Je ne suis pas disponible sur ce device";
      }
  }

  Future<String> generateResponseWithImage(File input) async {
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
  }

  Future<bool> initialize() async {
      try {
        await _channel.invokeMethod('initialize');
        return true;
      } catch (e) {
        return false;
      }
  }

  Future<String> reformulate(String userInput, main.GeminiReformulate type) async {
      try {
        final String result = await _channel.invokeMethod('reformulate', [userInput, type.toLabel()]);
        return result;
      } catch (e, s) {
        debugPrint(e.toString());
        debugPrint(s.toString());
        return "Je ne suis pas disponible sur ce device";
      }
  }

  Future<String> correct(String userInput) async {
      try {
        final String result = await _channel.invokeMethod('correct', userInput);
        return result;
      } catch (e, s) {
        debugPrint(e.toString());
        debugPrint(s.toString());
        return "Je ne suis pas disponible sur ce device";
      }
  }
}
