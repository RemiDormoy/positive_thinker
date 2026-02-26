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

final _activityCard = S.object(
  properties: {
    'activites': S.list(
      maxItems: 3,
      minItems: 3,
      items: S.object(
        properties: {
          'type': S.string(
            description: 'Le type de l\'activité',
            enumValues: possibleActivities,
          ),
          'description': S.string(description: 'La description de l\'activité'),
          'explication_humeur': S.string(
            description:
                'Pourquoi je pense que cette activité va améliorer ton humeur',
          ),
        },
        required: ['type', 'description', 'explication_humeur'],
      ),
    ),
  },
  required: ['activites'],
);

final possibleActivities = [
  "faire une promenade rapide",
  "danser",
  "faire du yoga",
  "aller nager",
  "faire le ménage",
  "pratiquer un sport de combat",
  //"suivre un cours de fitness en ligne",
  //"monter et descendre les escaliers",
  //"faire du vélo",
  //"faire du saut à la corde",
  //"méditer",
  //"faire une sieste",
  //"prendre un bain",
  //"bronzer au soleil",
  //"aller faire un massage",
  //"allumer de l'encens",
  //"écouter les bruits de la nature",
  //"boire une infusion",
  //"dessiner",
  //"écrire ses pensées dans un journal intime",
  //"jouer de la musique",
  //"cuisiner",
  //"jardiner",
  //"bricoler",
  "regarder un film",
  "lire un livre",
  "jouer à un jeu de société",
  "écouter de la musique",
  "appeler un ami",
  "caresser son animal de compagnie",
  "aller boire une bière",
  "ne rien faire du tout",
];

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

final _activityCardWidget = CatalogItem(
  name: 'ActivityCard',
  dataSchema: _activityCard,
  widgetBuilder: (CatalogItemContext context) {
    final data = context.data as Map<String, dynamic>;
    final List<dynamic> activites = data['activites'] ?? [];

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
          _ActivityHeaderWidget(),
          const SizedBox(height: 16.0),
          ...activites.asMap().entries.map((entry) {
            final index = entry.key;
            final activity = entry.value;
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (index > 0) const SizedBox(height: 12.0),
                _SingleActivityWidget(
                  type: activity['type'] ?? '',
                  description: activity['description'] ?? '',
                  explicationHumeur: activity['explication_humeur'] ?? '',
                  index: index + 1,
                ),
              ],
            );
          }),
        ],
      ),
    );
    // Cette nuit j'ai fait un cauchemard ou j'ai perdu mon chien. Je n'arrive pas à me sortir ça de la tête.
    return _ActivityCardWidget(
      activites: activites.map((activity) {
        return {
          'type': activity['type'] ?? '',
          'description': activity['description'] ?? '',
          'explication_humeur': activity['explication_humeur'] ?? '',
        };
      }).toList(),
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

class _ActivityCardWidget extends StatelessWidget {
  final List<Map<String, dynamic>> activites;

  const _ActivityCardWidget({required this.activites});

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
          _ActivityHeaderWidget(),
          const SizedBox(height: 16.0),
          ...activites.asMap().entries.map((entry) {
            final index = entry.key;
            final activity = entry.value;
            return Column(
              children: [
                if (index > 0) const SizedBox(height: 12.0),
                _SingleActivityWidget(
                  type: activity['type'] ?? '',
                  description: activity['description'] ?? '',
                  explicationHumeur: activity['explication_humeur'] ?? '',
                  index: index + 1,
                ),
              ],
            );
          }),
        ],
      ),
    );
  }
}

class _ActivityHeaderWidget extends StatelessWidget {
  const _ActivityHeaderWidget();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: const Color(0xFF81C784).withValues(alpha: 0.2),
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFF81C784), width: 3.0),
          ),
          child: const Icon(
            Icons.emoji_events,
            color: Color(0xFF81C784),
            size: 32,
          ),
        ),
        const SizedBox(width: 16.0),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Activités suggérées',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF8B4513),
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 4.0),
              Text(
                'Pour améliorer ton humeur',
                style: TextStyle(
                  fontSize: 20,
                  color: Color(0xFF81C784),
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

class _SingleActivityWidget extends StatelessWidget {
  final String type;
  final String description;
  final String explicationHumeur;
  final int index;

  const _SingleActivityWidget({
    required this.type,
    required this.description,
    required this.explicationHumeur,
    required this.index,
  });

  String _getActivityImagePath(String activityType) {
    switch (activityType) {
      case "faire une promenade rapide":
        return "assets/images_activites/promenade_rapide.png";
      case "danser":
        return "assets/images_activites/danse.png";
      case "faire du yoga":
        return "assets/images_activites/yoga.png";
      case "aller nager":
        return "assets/images_activites/nage_piscine.png";
      case "faire le ménage":
        return "assets/images_activites/menage.png";
      case "pratiquer un sport de combat":
        return "assets/images_activites/combat.png";
      case "suivre un cours de fitness en ligne":
        return "assets/images_activites/fitness.png";
      case "monter et descendre les escaliers":
        return "assets/images_activites/escaliers.png";
      case "faire du vélo":
        return "assets/images_activites/velo.png";
      case "faire du saut à la corde":
        return "assets/images_activites/corde.png";
      case "méditer":
        return "assets/images_activites/meditation.png";
      case "faire une sieste":
        return "assets/images_activites/sieste.png";
      case "prendre un bain":
        return "assets/images_activites/bain.png";
      case "bronzer au soleil":
        return "assets/images_activites/bronzer.png";
      case "aller faire un massage":
        return "assets/images_activites/massage.png";
      case "allumer de l'encens":
        return "assets/images_activites/encens.png";
      case "écouter les bruits de la nature":
        return "assets/images_activites/bruits_nature.png";
      case "boire une infusion":
        return "assets/images_activites/infusion.png";
      case "dessiner":
        return "assets/images_activites/dessin.png";
      case "écrire ses pensées dans un journal intime":
        return "assets/images_activites/journal_intime.png";
      case "jouer de la musique":
        return "assets/images_activites/musique.png";
      case "cuisiner":
        return "assets/images_activites/cuisiner.png";
      case "jardiner":
        return "assets/images_activites/jardiner.png";
      case "bricoler":
        return "assets/images_activites/bricoler.png";
      case "regarder un film":
        return "assets/images_activites/regarder_film.png";
      case "lire un livre":
        return "assets/images_activites/lire.png";
      case "jouer à un jeu de société":
        return "assets/images_activites/jeu_de_société.png";
      case "écouter de la musique":
        return "assets/images_activites/ecouter_musique.png";
      case "appeler un ami":
        return "assets/images_activites/appel_ami.png";
      case "caresser son animal de compagnie":
        return "assets/images_activites/caresser_animal.png";
      case "aller boire une bière":
        return "assets/images_activites/boire_une_biere.png";
      case "ne rien faire du tout":
        return "assets/images_activites/rien_faire.png";
      default:
        return "assets/images_activites/rien_faire.png";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: const Color(0xFF8B4513).withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
            flex: 1,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12.0),
              child: Image.asset(
                _getActivityImagePath(type),
                fit: BoxFit.fitHeight,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      type,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFF5D4037),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12.0),
                _ActivityDescriptionWidget(description: description),
                const SizedBox(height: 8.0),
                _ActivityExplicationWidget(explication: explicationHumeur),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityDescriptionWidget extends StatelessWidget {
  final String description;

  const _ActivityDescriptionWidget({required this.description});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        color: const Color(0xFFE8B4A0).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.description, color: Color(0xFF8B4513), size: 18),
          const SizedBox(width: 8.0),
          Expanded(
            child: Text(
              description,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF5D4037),
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityExplicationWidget extends StatelessWidget {
  final String explication;

  const _ActivityExplicationWidget({required this.explication});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        color: const Color(0xFF81C784).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.lightbulb_outline,
            color: Color(0xFF81C784),
            size: 18,
          ),
          const SizedBox(width: 8.0),
          Expanded(
            child: Text(
              explication,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF5D4037),
                height: 1.3,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
