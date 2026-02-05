import 'package:flutter/foundation.dart';
import 'package:positive_thinker/models/performance_metrics.dart';

class PerformanceTracker {
  static final PerformanceTracker _instance = PerformanceTracker._internal();
  factory PerformanceTracker() => _instance;
  PerformanceTracker._internal();

  PerformanceMetrics? _currentMetrics;
  DateTime? _initializationStart;
  int? _initializationTimeMs;

  PerformanceMetrics? get currentMetrics => _currentMetrics;

  int? get initializationTimeMs => _initializationTimeMs;

  void startInitialization() {
    _initializationStart = DateTime.now();
    debugPrint('🚀 Début initialisation du modèle');
  }

  void endInitialization() {
    if (_initializationStart != null) {
      _initializationTimeMs = DateTime.now().difference(_initializationStart!).inMilliseconds;
      debugPrint('✅ Initialisation terminée en $_initializationTimeMs ms');
      _initializationStart = null;
    }
  }

  PerformanceTracker startTracking(String operationName, String platform) {
    _currentMetrics = PerformanceMetrics(operationName: operationName, platform: platform, startTime: DateTime.now());
    debugPrint('⏱️ Début $operationName sur $platform');
    return this;
  }

  void endTracking({bool success = true, String? errorMessage}) {
    if (_currentMetrics != null) {
      final endTime = DateTime.now();
      final duration = endTime.difference(_currentMetrics!.startTime).inMilliseconds;

      _currentMetrics = PerformanceMetrics(
        operationName: _currentMetrics!.operationName,
        platform: _currentMetrics!.platform,
        startTime: _currentMetrics!.startTime,
        endTime: endTime,
        durationMs: duration,
        success: success,
        errorMessage: errorMessage,
      );

      if (success) {
        debugPrint('✅ ${_currentMetrics!.operationName} terminé en $duration ms');
      } else {
        debugPrint('❌ ${_currentMetrics!.operationName} échoué après $duration ms: $errorMessage');
      }
    }
  }

  void reset() {
    _currentMetrics = null;
    _initializationTimeMs = null;
    _initializationStart = null;
  }
}
