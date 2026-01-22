import 'package:flutter/material.dart';
import '../models/guardian_article_detail.dart';
import '../services/guardian_service.dart';

class ArticleDetailPage extends StatelessWidget {
  final String apiUrl;
  final String title;

  const ArticleDetailPage({
    super.key,
    required this.apiUrl,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Article',
          style: const TextStyle(
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
        child: FutureBuilder<GuardianArticleDetail>(
          future: GuardianService().fetchArticleDetail(apiUrl),
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

            if (!snapshot.hasData) {
              return const _EmptyStateWidget();
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: _ArticleContent(article: snapshot.data!),
            );
          },
        ),
      ),
    );
  }
}

class _ArticleContent extends StatelessWidget {
  final GuardianArticleDetail article;

  const _ArticleContent({required this.article});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ArticleHeader(
              title: article.webTitle,
              sectionName: article.sectionName,
              date: article.webPublicationDate,
            ),
            const SizedBox(height: 20),
            if (article.standfirst.isNotEmpty) ...[
              _StandfirstWidget(standfirst: article.standfirst),
              const SizedBox(height: 20),
            ],
            if (article.byline.isNotEmpty) ...[
              _BylineWidget(byline: article.byline),
              const SizedBox(height: 20),
            ],
            _BodyTextWidget(bodyText: article.bodyText),
          ],
        ),
      ),
    );
  }
}

class _ArticleHeader extends StatelessWidget {
  final String title;
  final String sectionName;
  final String date;

  const _ArticleHeader({
    required this.title,
    required this.sectionName,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF8B4513),
            height: 1.3,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            _SectionChip(sectionName: sectionName),
            const Spacer(),
            Text(
              _formatDate(date),
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF8B4513),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ],
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFD2691E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        sectionName.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _StandfirstWidget extends StatelessWidget {
  final String standfirst;

  const _StandfirstWidget({required this.standfirst});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5E6D3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFFD2691E),
          width: 1,
        ),
      ),
      child: Text(
        _stripHtmlTags(standfirst),
        style: const TextStyle(
          fontSize: 16,
          fontStyle: FontStyle.italic,
          color: Color(0xFF8B4513),
          height: 1.5,
        ),
      ),
    );
  }

  String _stripHtmlTags(String htmlString) {
    final RegExp exp = RegExp(r"<[^>]*>", multiLine: true, caseSensitive: true);
    return htmlString.replaceAll(exp, '').trim();
  }
}

class _BylineWidget extends StatelessWidget {
  final String byline;

  const _BylineWidget({required this.byline});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(
          Icons.person,
          size: 16,
          color: Color(0xFF8B4513),
        ),
        const SizedBox(width: 8),
        Text(
          _stripHtmlTags(byline),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF8B4513),
          ),
        ),
      ],
    );
  }

  String _stripHtmlTags(String htmlString) {
    final RegExp exp = RegExp(r"<[^>]*>", multiLine: true, caseSensitive: true);
    return htmlString.replaceAll(exp, '').trim();
  }
}

class _BodyTextWidget extends StatelessWidget {
  final String bodyText;

  const _BodyTextWidget({required this.bodyText});

  @override
  Widget build(BuildContext context) {
    if (bodyText.isEmpty) {
      return const Text(
        'Contenu de l\'article non disponible.',
        style: TextStyle(
          fontSize: 16,
          color: Color(0xFF8B4513),
          fontStyle: FontStyle.italic,
        ),
      );
    }

    return Text(
      _stripHtmlTags(bodyText),
      style: const TextStyle(
        fontSize: 16,
        color: Color(0xFF8B4513),
        height: 1.6,
      ),
    );
  }

  String _stripHtmlTags(String htmlString) {
    final RegExp exp = RegExp(r"<[^>]*>", multiLine: true, caseSensitive: true);
    return htmlString.replaceAll(exp, '').replaceAll('&nbsp;', ' ').trim();
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
            const Text(
              'Impossible de charger le détail de l\'article pour le moment.',
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
              'Article non trouvé',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF8B4513),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              'Cet article n\'est plus disponible.',
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
