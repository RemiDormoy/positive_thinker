import 'package:flutter/material.dart';
import '../models/guardian_article.dart';
import '../services/guardian_service.dart';
import 'article_detail_page.dart';

class PositiveNewsPage extends StatefulWidget {
  const PositiveNewsPage({super.key});

  @override
  State<PositiveNewsPage> createState() => _PositiveNewsPageState();
}

class _PositiveNewsPageState extends State<PositiveNewsPage> {
  final TextEditingController _searchController = TextEditingController();
  final GuardianService _guardianService = GuardianService();
  Future<List<GuardianArticle>>? _articlesFuture;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    // Charger les articles par défaut à l'initialisation
    _articlesFuture = _guardianService.fetchPositiveNews();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch() {
    final searchQuery = _searchController.text.trim();
    if (searchQuery.isEmpty) return;

    setState(() {
      _isSearching = true;
      _articlesFuture = _guardianService.searchArticles(searchQuery);
    });
  }

  void _resetToDefault() {
    setState(() {
      _isSearching = false;
      _articlesFuture = _guardianService.fetchPositiveNews();
    });
    _searchController.clear();
  }

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
        child: Column(
          children: [
            // Barre de recherche
            _SearchBarWidget(
              controller: _searchController,
              onSearch: _performSearch,
              onReset: _isSearching ? _resetToDefault : null,
              isSearching: _isSearching,
            ),

            // Liste des articles
            Expanded(
              child: FutureBuilder<List<GuardianArticle>>(
                future: _articlesFuture,
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
                    return _EmptyStateWidget(isSearchResult: _isSearching);
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final article = snapshot.data![index];
                      return _ArticleCard(article: article);
                    },
                  );
                },
              ),
            ),
          ],
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
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ArticleDetailPage(
                apiUrl: article.apiUrl,
                title: article.webTitle,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
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

// Widget privé pour la barre de recherche
class _SearchBarWidget extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSearch;
  final VoidCallback? onReset;
  final bool isSearching;

  const _SearchBarWidget({
    required this.controller,
    required this.onSearch,
    this.onReset,
    required this.isSearching,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          // Champ de texte
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: 'Rechercher des articles...',
                  hintStyle: const TextStyle(
                    color: Color(0xFF8B4513),
                    fontSize: 16,
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Color(0xFF8B4513),
                  ),
                  suffixIcon: isSearching
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: Color(0xFF8B4513)),
                          onPressed: onReset,
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                style: const TextStyle(
                  color: Color(0xFF8B4513),
                  fontSize: 16,
                ),
                onSubmitted: (_) => onSearch(),
              ),
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Bouton de recherche
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFD2691E), Color(0xFFFF8C00)],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.orange.withValues(alpha: 0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onSearch,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  child: const Icon(
                    Icons.search,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyStateWidget extends StatelessWidget {
  final bool isSearchResult;

  const _EmptyStateWidget({this.isSearchResult = false});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSearchResult ? Icons.search_off : Icons.article_outlined,
              size: 64,
              color: const Color(0xFF8B4513),
            ),
            const SizedBox(height: 16),
            Text(
              isSearchResult 
                ? 'Aucun résultat trouvé'
                : 'Aucun article disponible',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF8B4513),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              isSearchResult
                ? 'Essayez avec des mots-clés différents ou vérifiez l\'orthographe.'
                : 'Revenez plus tard pour découvrir de nouveaux articles positifs !',
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
