import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:positive_thinker/coach_page.dart';
import 'package:positive_thinker/pages/ActivateNanoPage.dart';
import 'package:positive_thinker/pages/positive_news_page.dart';
import 'package:positive_thinker/pages/better_reading_page.dart';
import 'package:positive_thinker/pages/writing_improvement_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pensée Positive',
      theme: ThemeData(primarySwatch: Colors.orange, fontFamily: 'Georgia'),
      home: const HomePage(),
      routes: {
        "/coach": (context) => SmartCoachAssistantPage(),
        "/positive_news": (context) => const PositiveNewsPage(),
        "/better_reading": (context) => const BetterReadingPage(),
        "/activate_nano": (context) => const ActivateNanoPage(),
        "/writing_improvement": (context) => const WritingImprovementPage(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF5E6D3), // Crème/beige clair
              Color(0xFFE8B4A0), // Orange/pêche
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              children: [
                const SizedBox(height: 30),

                // Titre principal
                const Text(
                  'Positive Thinker',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF8B4513),
                  ),
                ),

                const SizedBox(height: 10),

                // Sous-titre
                const Text(
                  'Cultivez votre bonheur au quotidien',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF8B4513),
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 50),

                if (kIsWeb) ...[
                  // Section Positive Coach
                  _buildFeatureItem(
                    icon: Icons.psychology,
                    title: 'Activer Gemini Nano',
                    description:
                    'Si vous faites pas ça, ça marchera pas',
                    onClick: () {
                      Navigator.of(context).pushNamed("/activate_nano");
                    },
                  ),

                  const SizedBox(height: 30),
                ],

                // Section Positive Coach
                _buildFeatureItem(
                  icon: Icons.favorite,
                  title: 'Positive Coach',
                  description:
                      'Votre accompagnateur personnel vers une vie plus positive',
                  onClick: () {
                    Navigator.of(context).pushNamed("/coach");
                  },
                ),

                const SizedBox(height: 30),

                // Section Ma vie en mieux
                _buildFeatureItem(
                  icon: Icons.auto_awesome,
                  title: 'Mon écriture en mieux',
                  description:
                      'Lachez vos messages les plus moches, je les corrigerais',
                  onClick: () {
                    Navigator.of(context).pushNamed("/writing_improvement");
                  },
                ),

                /*const SizedBox(height: 30),

                // Section La lentille positive
                _buildFeatureItem(
                  icon: Icons.visibility,
                  title: 'La lentille positive',
                  description:
                      'Apprenez à voir le monde sous un angle bienveillant',
                  onClick: () {
                    Navigator.of(context).pushNamed("/coach");
                  },
                ),*/

                const SizedBox(height: 30),

                // Section Le côté positif en bref
                _buildFeatureItem(
                  icon: Icons.menu_book,
                  title: 'Le côté positif en bref',
                  description:
                      'Les news de la france mais en plus positif',
                  onClick: () {
                    Navigator.of(context).pushNamed("/positive_news");
                  },
                ),

                const SizedBox(height: 30),

                // Section Une meilleure relecture
                _buildFeatureItem(
                  icon: Icons.flash_on,
                  title: 'Une meilleure relecture',
                  description:
                      'Revisitez votre vie avec positivité',
                  onClick: () {
                    Navigator.of(context).pushNamed("/better_reading");
                  },
                ),

                const SizedBox(height: 50),

                // Citation en bas
                const Text(
                  '"Chaque jour est une nouvelle opportunité de choisir le bonheur."',
                  style: TextStyle(
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                    color: Color(0xFF8B4513),
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String description,
    required void Function() onClick,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onClick,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white),
            color: Colors.white.withAlpha(80),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icône dans un cercle blanc
              Icon(icon, color: Color(0xFFD2691E), size: 40),

              const SizedBox(width: 20),

              // Texte
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF8B4513),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF8B4513),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
