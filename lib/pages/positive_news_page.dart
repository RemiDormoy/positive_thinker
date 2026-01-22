import 'package:flutter/material.dart';
import '../models/guardian_article.dart';
import '../services/guardian_service.dart';

class PositiveNewsPage extends StatelessWidget {
  const PositiveNewsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Le côté positif en bref',
          style: TextStyle(
            color: Color(0xFF8B4513),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFFF5E6D3),
        iconTheme: const IconThemeData(color: Color(0xFF8B4513)),
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF5E6D3),
              Color(0xFFE8B4A0),
            ],
          ),
        ),
        child: FutureBuilder<List<GuardianArticle>>(
          future: GuardianService().fetchPositiveNews(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8B4513)),
                ),
              );
            }

            if (snapshot.hasError) {
              return _ErrorWidget(error: snapshot.error.toString());
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const _EmptyStateWidget();
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final article = snapshot.data![index];
                return _ArticleCard(article: article);
              },
            );
          },
        ),
      ),
    );
  }
}

class _ArticleCard extends StatelessWidget {
  final GuardianArticle article;

  const _ArticleCard({required this.article});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              article.webTitle,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF8B4513),
                height: 1.3,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _SectionChip(sectionName: article.sectionName),
                const Spacer(),
                Text(
                  _formatDate(article.webPublicationDate),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF8B4513),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays == 0) {
        return "Aujourd'hui";
      } else if (difference.inDays == 1) {
        return "Hier";
      } else if (difference.inDays < 7) {
        return "Il y a ${difference.inDays} jours";
      } else {
        return "${date.day}/${date.month}/${date.year}";
      }
    } catch (e) {
      return dateString;
    }
  }
}

class _SectionChip extends StatelessWidget {
  final String sectionName;

  const _SectionChip({required this.sectionName});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFD2691E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        sectionName.toUpperCase(),
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _ErrorWidget extends StatelessWidget {
  final String error;

  const _ErrorWidget({required this.error});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Color(0xFF8B4513),
            ),
            const SizedBox(height: 16),
            const Text(
              'Oops ! Une erreur est survenue',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF8B4513),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Impossible de charger les articles pour le moment.',
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF8B4513),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyStateWidget extends StatelessWidget {
  const _EmptyStateWidget();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.article_outlined,
              size: 64,
              color: Color(0xFF8B4513),
            ),
            SizedBox(height: 16),
            Text(
              'Aucun article disponible',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF8B4513),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              'Revenez plus tard pour découvrir de nouveaux articles positifs !',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF8B4513),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
