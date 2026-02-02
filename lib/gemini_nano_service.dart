// Import conditionnel de l'implémentation selon la plateforme
import 'gemini_nano_service_web.dart' if (dart.library.io) 'gemini_nano_service_native.dart' as platform;

// Interface publique qui délègue à l'implémentation de la plateforme
class GeminiNanoService {
  // Instance de l'implémentation spécifique à la plateforme
  final platform.GeminiNanoService _impl = platform.GeminiNanoService();

  Future<String> generateResponse(String input) {
    return _impl.generateResponse(input);
  }

  Future<String> summarize(String input) {
    return _impl.summarize(input);
  }

  Future<String> generateResponseWithImage(dynamic input) {
    return _impl.generateResponseWithImage(input);
  }

  Future<bool> initialize() {
    return _impl.initialize();
  }

  Future<String> reformulate(String userInput, GeminiReformulate type) {
    return _impl.reformulate(userInput, type);
  }

  Future<String> correct(String userInput) {
    return _impl.correct(userInput);
  }
}

// Enum partagé entre toutes les plateformes
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