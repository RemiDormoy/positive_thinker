import 'package:flutter/material.dart';

import '../services/performance_tracker.dart';

class PerformanceMetricsWidget extends StatefulWidget {
  final PerformanceTracker tracker;

  const PerformanceMetricsWidget({super.key, required this.tracker});

  @override
  State<PerformanceMetricsWidget> createState() => _PerformanceMetricsWidgetState();
}

class _PerformanceMetricsWidgetState extends State<PerformanceMetricsWidget> {
  @override
  void initState() {
    super.initState();
    _scheduleRebuild();
  }

  void _scheduleRebuild() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        setState(() {});
        // Continuer à rebuilder si une opération est en cours
        if (widget.tracker.currentMetrics != null && !widget.tracker.currentMetrics!.isComplete) {
          _scheduleRebuild();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final metrics = widget.tracker.currentMetrics;
    final initTime = widget.tracker.initializationTimeMs;

    if (metrics == null && initTime == null) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Color(0xFFF5E6D3)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Titre
          Row(
            children: [
              Icon(Icons.speed, color: const Color(0xFFD2691E), size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: const Text(
                  'Métriques de Performance',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF8B4513)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Plateforme
          if (metrics != null) ...[
            _MetricRow(
              icon: Icons.devices,
              label: 'Plateforme',
              value: metrics.platform,
              color: const Color(0xFF8B4513),
            ),
            const SizedBox(height: 24),
          ],

          // Temps d'initialisation
          if (initTime != null) ...[
            _MetricRow(
              icon: Icons.rocket_launch,
              label: 'Initialisation',
              value: _formatDuration(initTime),
              color: const Color(0xFF4CAF50),
            ),
            const SizedBox(height: 24),
          ],

          // Dernière opération ou session
          if (metrics != null && metrics.isComplete) ...[
            // Si c'est une session avec sous-opérations
            if (metrics.hasSubOperations) ...[
              _MetricRow(
                icon: Icons.functions,
                label: 'Opération composite',
                value: metrics.operationName,
                color: const Color(0xFF2196F3),
              ),
              const SizedBox(height: 24),

              // Temps total
              _MetricRow(
                icon: metrics.success ? Icons.timer : Icons.error,
                label: 'Temps total',
                value: _formatDuration(metrics.totalDurationMs),
                color: metrics.success ? const Color(0xFFFF9800) : Colors.red,
                isHighlight: true,
              ),

              const SizedBox(height: 24),

              // Liste des sous-opérations
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF2196F3).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.list, color: const Color(0xFF2196F3), size: 16),
                        const SizedBox(width: 8),
                        Text(
                          'Détail des opérations (${metrics.subOperations.length})',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF8B4513)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ...metrics.subOperations.map(
                      (subOp) => Padding(
                        padding: const EdgeInsets.only(left: 24, top: 4),
                        child: Row(
                          children: [
                            Icon(
                              subOp.success ? Icons.check_circle : Icons.error,
                              size: 14,
                              color: subOp.success ? Colors.green : Colors.red,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                subOp.name,
                                style: TextStyle(fontSize: 12, color: const Color(0xFF8B4513).withValues(alpha: 0.8)),
                              ),
                            ),
                            Text(
                              _formatDuration(subOp.durationMs),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF2196F3),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              // Opération simple
              _MetricRow(
                icon: Icons.functions,
                label: 'Dernière opération',
                value: metrics.operationName,
                color: const Color(0xFF2196F3),
              ),
              const SizedBox(height: 24),

              // Temps de réponse
              _MetricRow(
                icon: metrics.success ? Icons.timer : Icons.error,
                label: 'Temps de réponse',
                value: _formatDuration(metrics.durationMs!),
                color: metrics.success ? const Color(0xFFFF9800) : Colors.red,
                isHighlight: true,
              ),
            ],

            // Message d'erreur si échec
            if (!metrics.success && metrics.errorMessage != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning, color: Colors.red, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        metrics.errorMessage!,
                        style: const TextStyle(fontSize: 12, color: Colors.red),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ] else if (metrics != null && !metrics.isComplete) ...[
            // Opération en cours
            Row(
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(const Color(0xFFD2691E)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '${metrics.operationName} en cours...',
                    style: const TextStyle(fontSize: 14, color: Color(0xFF8B4513), fontStyle: FontStyle.italic),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _formatDuration(int milliseconds) {
    if (milliseconds < 1000) {
      return '$milliseconds ms';
    } else {
      final seconds = (milliseconds / 1000).toStringAsFixed(2);
      return '$seconds s';
    }
  }
}

class _MetricRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final bool isHighlight;

  const _MetricRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.isHighlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: isHighlight ? const EdgeInsets.all(8) : EdgeInsets.zero,
      decoration: isHighlight
          ? BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6))
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 8),
              Text("$label : ", style: TextStyle(fontSize: 14, color: const Color(0xFF8B4513).withValues(alpha: 0.8))),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isHighlight ? FontWeight.bold : FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
