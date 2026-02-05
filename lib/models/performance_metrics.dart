class PerformanceMetrics {
  final String operationName;
  final String platform;
  final DateTime startTime;
  final DateTime? endTime;
  final int? durationMs;
  final bool success;
  final String? errorMessage;
  final List<SubOperation> subOperations;
  final int totalDurationMs;

  PerformanceMetrics({
    required this.operationName,
    required this.platform,
    required this.startTime,
    this.endTime,
    this.durationMs,
    this.success = true,
    this.errorMessage,
    this.subOperations = const [],
    this.totalDurationMs = 0,
  });

  bool get isComplete => endTime != null && durationMs != null;

  bool get hasSubOperations => subOperations.isNotEmpty;

  @override
  String toString() {
    if (!isComplete) {
      return '$operationName sur $platform - En cours...';
    }
    if (hasSubOperations) {
      return '$operationName sur $platform - Total: ${totalDurationMs}ms (${subOperations.length} opérations) ${success ? "✅" : "❌"}';
    }
    return '$operationName sur $platform - ${durationMs}ms ${success ? "✅" : "❌"}';
  }
}

class SubOperation {
  final String name;
  final int durationMs;
  final bool success;

  SubOperation({required this.name, required this.durationMs, this.success = true});
}
