part of 'positive_activities_page.dart';

final _moodCard = S.object(
  properties: {
    'humeur': Schema.string(
      description: 'L\'humeur que je pense que tu as',
      enumValues: possibleMoods,
    ),
    'energie': Schema.integer(
      description: 'L\'énergie que je pense que tu as de 1 à 10',
      minimum: 1,
      maximum: 10,
    ),
    'explication': S.string(
      description: 'Pourquoi je pense que tu as cette humeur',
    ),
  },
  required: ['humeur', 'energie', "explication"],
);

final _assistantMessage = S.object(
  properties: {'text': S.string(description: "La réponse de l'assistant")},
  required: ['text'],
);

final possibleMoods = [
  "JOYEUX",
  "IRRITABLE",
  "MELANCOLIQUE",
  "ANXIEUX",
  "APATHIQUE",
  "SEREIN",
  "NOSTALGIQUE",
  "ENTHOUSIASTE",
  "MOROSE",
  "PREOCCUPE",
];
final _assistantMessageWidget = CatalogItem(
  name: 'AssistantMessageCard',
  dataSchema: _assistantMessage,
  widgetBuilder: (CatalogItemContext context) {
    final data = context.data as Map<String, dynamic>;
    final String text = data['text'] ?? '';
    return _MessageWidget(
      message: PositiveChatMessage(
        text: text,
        isUser: false,
        timestamp: DateTime.now(),
      ),
    );
  },
);
final _moodCardWidget = CatalogItem(
  name: 'MoodCard',
  dataSchema: _moodCard,
  widgetBuilder: (CatalogItemContext context) {
    final data = context.data as Map<String, dynamic>;
    final String humeur = data['humeur'] ?? 'SEREIN';
    final int energie = (data['energie'] as num).toInt();
    final String explication = data['explication'] ?? '';

    return _MoodCardWidget(
      humeur: humeur,
      energie: energie,
      explication: explication,
    );
  },
);

class _MoodCardWidget extends StatelessWidget {
  final String humeur;
  final int energie;
  final String explication;

  const _MoodCardWidget({
    required this.humeur,
    required this.energie,
    required this.explication,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF5E6D3), Color(0xFFFFFFFF)],
        ),
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: const Color(0xFF8B4513), width: 2.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8.0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _MoodHeaderWidget(humeur: humeur),
          const SizedBox(height: 16.0),
          _EnergyBarWidget(energie: energie),
          if (explication.isNotEmpty) ...[
            const SizedBox(height: 16.0),
            _ExplicationWidget(explication: explication),
          ],
        ],
      ),
    );
  }
}

class _MoodHeaderWidget extends StatelessWidget {
  final String humeur;

  const _MoodHeaderWidget({required this.humeur});

  IconData _getMoodIcon(String mood) {
    switch (mood) {
      case 'JOYEUX':
        return Icons.sentiment_very_satisfied;
      case 'IRRITABLE':
        return Icons.sentiment_very_dissatisfied;
      case 'MELANCOLIQUE':
        return Icons.sentiment_dissatisfied;
      case 'ANXIEUX':
        return Icons.sentiment_neutral;
      case 'APATHIQUE':
        return Icons.sentiment_neutral;
      case 'SEREIN':
        return Icons.spa;
      case 'NOSTALGIQUE':
        return Icons.history;
      case 'ENTHOUSIASTE':
        return Icons.celebration;
      case 'MOROSE':
        return Icons.cloud;
      case 'PREOCCUPE':
        return Icons.psychology;
      default:
        return Icons.sentiment_satisfied;
    }
  }

  Color _getMoodColor(String mood) {
    switch (mood) {
      case 'JOYEUX':
        return const Color(0xFFFFD700);
      case 'IRRITABLE':
        return const Color(0xFFFF6B6B);
      case 'MELANCOLIQUE':
        return const Color(0xFF6B8E9F);
      case 'ANXIEUX':
        return const Color(0xFFFF8C42);
      case 'APATHIQUE':
        return const Color(0xFF9E9E9E);
      case 'SEREIN':
        return const Color(0xFF81C784);
      case 'NOSTALGIQUE':
        return const Color(0xFFBA68C8);
      case 'ENTHOUSIASTE':
        return const Color(0xFFFFB74D);
      case 'MOROSE':
        return const Color(0xFF78909C);
      case 'PREOCCUPE':
        return const Color(0xFF7986CB);
      default:
        return const Color(0xFF8B4513);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: _getMoodColor(humeur).withValues(alpha: 0.2),
            shape: BoxShape.circle,
            border: Border.all(color: _getMoodColor(humeur), width: 3.0),
          ),
          child: Icon(
            _getMoodIcon(humeur),
            color: _getMoodColor(humeur),
            size: 32,
          ),
        ),
        const SizedBox(width: 16.0),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Ton humeur',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF8B4513),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4.0),
              Text(
                humeur,
                style: TextStyle(
                  fontSize: 24,
                  color: _getMoodColor(humeur),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _EnergyBarWidget extends StatelessWidget {
  final int energie;

  const _EnergyBarWidget({required this.energie});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Niveau d\'énergie',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF8B4513),
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '$energie/10',
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF8B4513),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8.0),
        Row(
          children: List.generate(10, (index) {
            final isFilled = index < energie;
            return Expanded(
              child: Container(
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 2.0),
                decoration: BoxDecoration(
                  color: isFilled
                      ? const Color(0xFF8B4513)
                      : const Color(0xFF8B4513).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4.0),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _ExplicationWidget extends StatelessWidget {
  final String explication;

  const _ExplicationWidget({required this.explication});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: const Color(0xFFE8B4A0).withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, color: Color(0xFF8B4513), size: 20),
          const SizedBox(width: 8.0),
          Expanded(
            child: Text(
              explication,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF5D4037),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
