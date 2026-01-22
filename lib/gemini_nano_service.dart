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


  Future<String> generateResponseWithImage(File input) async {
    // Vérifier si nous sommes sur Android
    if (Platform.isAndroid) {
      try {
        final String imageResult = await _channel.invokeMethod('imageDescription', input.path);
        debugPrint('imageResult : $imageResult');
        final finalPrompt = """Avec la description d'une image suivante : $imageResult peut tu répondre de la manière suivante :
         - si c'est une image qui concerne les chiens, répond comme un chien en précisant à la fin "Mais je suis coach de NFL ici !" 
         - si c'est une image qui concerne la NFL, explique la
         - si ce n'est ni l'un ni l'autre, répond simplement "Je suis coach de NFL, cette image ne m'interesse pas" puis explique pourquoi
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
}
