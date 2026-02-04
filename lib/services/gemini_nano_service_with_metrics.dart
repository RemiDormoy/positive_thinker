import 'dart:io';

import 'package:flutter/foundation.dart';

import 'gemini_nano_service.dart';
import 'performance_tracker.dart';

class GeminiNanoServiceWithMetrics {
  final GeminiNanoService _service = GeminiNanoService();
  final PerformanceTracker _tracker = PerformanceTracker();

  PerformanceTracker get tracker => _tracker;

  String get _platform {
    if (kIsWeb) {
      return 'Web (Chrome)';
    } else if (Platform.isAndroid) {
      return 'Android (Gemini Nano)';
    } else if (Platform.isIOS) {
      return 'iOS (Apple Foundation)';
    } else {
      return 'Unknown';
    }
  }

  Future<bool> initialize() async {
    _tracker.startInitialization();
    try {
      final result = await _service.initialize();
      _tracker.endInitialization();
      return result;
    } catch (e) {
      _tracker.endInitialization();
      rethrow;
    }
  }

  Future<String> generateResponse(String input) async {
    _tracker.startTracking('generateResponse', _platform);
    try {
      final result = await _service.generateResponse(input);
      final isError =
          result.contains('Je ne suis pas disponible') ||
          result.contains('non disponible') ||
          result.contains('Erreur');
      _tracker.endTracking(success: !isError, errorMessage: isError ? result : null);
      return result;
    } catch (e) {
      _tracker.endTracking(success: false, errorMessage: e.toString());
      rethrow;
    }
  }

  Future<String> summarize(String input) async {
    _tracker.startTracking('summarize', _platform);
    try {
      final result = await _service.summarize(input);
      final isError =
          result.contains('Je ne suis pas disponible') ||
          result.contains('non disponible') ||
          result.contains('Erreur');
      _tracker.endTracking(success: !isError, errorMessage: isError ? result : null);
      return result;
    } catch (e) {
      _tracker.endTracking(success: false, errorMessage: e.toString());
      rethrow;
    }
  }

  Future<String> generateResponseWithImage(dynamic input) async {
    _tracker.startTracking('generateResponseWithImage', _platform);
    try {
      final result = await _service.generateResponseWithImage(input);
      final isError =
          result.contains('Je ne suis pas disponible') ||
          result.contains('non disponible') ||
          result.contains('Erreur');
      _tracker.endTracking(success: !isError, errorMessage: isError ? result : null);
      return result;
    } catch (e) {
      _tracker.endTracking(success: false, errorMessage: e.toString());
      rethrow;
    }
  }

  Future<String> reformulate(String userInput, GeminiReformulate type) async {
    _tracker.startTracking('reformulate (${type.toLabel()})', _platform);
    try {
      final result = await _service.reformulate(userInput, type);
      final isError =
          result.contains('Je ne suis pas disponible') ||
          result.contains('non disponible') ||
          result.contains('Erreur');
      _tracker.endTracking(success: !isError, errorMessage: isError ? result : null);
      return result;
    } catch (e) {
      _tracker.endTracking(success: false, errorMessage: e.toString());
      rethrow;
    }
  }

  Future<String> correct(String userInput) async {
    _tracker.startTracking('correct', _platform);
    try {
      final result = await _service.correct(userInput);
      final isError =
          result.contains('Je ne suis pas disponible') ||
          result.contains('non disponible') ||
          result.contains('Erreur');
      _tracker.endTracking(success: !isError, errorMessage: isError ? result : null);
      return result;
    } catch (e) {
      _tracker.endTracking(success: false, errorMessage: e.toString());
      rethrow;
    }
  }
}
