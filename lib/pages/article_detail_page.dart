import 'package:flutter/material.dart';
import 'package:positive_thinker/gemini_nano_service.dart';
import '../models/guardian_article_detail.dart';
import '../services/guardian_service.dart';

class ArticleDetailPage extends StatefulWidget {
  final String apiUrl;
  final String title;

  const ArticleDetailPage({
    super.key,
    required this.apiUrl,
    required this.title,
  });

  @override
  State<ArticleDetailPage> createState() => _ArticleDetailPageState();
}

class _ArticleDetailPageState extends State<ArticleDetailPage> {

  PositiveNewsStep step = PositiveNewsStep.LOADING_CONTENT;
  String finalContent = "";
  final GeminiNanoService geminiNanoService = GeminiNanoService();

  @override
  void initState() {
    super.initState();
    _initializeGeminiNano().then((_) {
      _fetchArticles();
    });
  }

  _fetchArticles() {
    GuardianService().fetchArticleDetail(widget.apiUrl).then((articles) {
      setState(() {
        step = PositiveNewsStep.SUMMURAZING_CONTENT;
      });
      _summarizeArticles(articles);
    });
  }

  _summarizeArticles(GuardianArticleDetail article) {
    geminiNanoService.summarize(article.bodyText).then((summary) {
      setState(() {
        step = PositiveNewsStep.READY;
        finalContent = summary;
      });
    });
  }

  Future<void> _initializeGeminiNano() async {
    await geminiNanoService.initialize();
  }

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
        child: step == PositiveNewsStep.LOADING_CONTENT ? _LoadingContentFromInternetWidget() :
        step == PositiveNewsStep.SUMMURAZING_CONTENT ? _LoadingSummarizedContent() :
        step == PositiveNewsStep.TRANSLATING ? _TranslatingWidget() :
        step == PositiveNewsStep.ADDING_GOOD_VIBES ? _AddingGoodVibesWidget() :
        Text(finalContent),
      ),
    );
  }
}

class _LoadingContentFromInternetWidget extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: Color(0xFF8B4513),
            ),
            SizedBox(height: 16),
            Text(
              "Chargement du contenu de l'article",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
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

class _LoadingSummarizedContent extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: Color(0xFF8B4513),
            ),
            SizedBox(height: 16),
            Text(
              "Création du résumé",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
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

class _TranslatingWidget extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: Color(0xFF8B4513),
            ),
            SizedBox(height: 16),
            Text(
              "Traduction du résumé",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
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

class _AddingGoodVibesWidget extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: Color(0xFF8B4513),
            ),
            SizedBox(height: 16),
            Text(
              "Injection d'ondes positives",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
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

enum PositiveNewsStep {
  LOADING_CONTENT,
  SUMMURAZING_CONTENT,
  TRANSLATING,
  ADDING_GOOD_VIBES,
  READY,
}