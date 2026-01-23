import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';
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
  String originalContent = "";
  String originalSummary = "";
  String firstTranslation = "";
  String beforeEmoji = "";
  GuardianArticleDetail? articleDetail;
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
        articleDetail = articles;
      });
      _summarizeArticles(articles);
    });
  }

  _summarizeArticles(GuardianArticleDetail article) {
    debugPrint("Texte complet de l'article : ${article.bodyText}");
    geminiNanoService.summarize(article.bodyText).then((summary) {
      setState(() {
        originalContent = article.bodyText;
        originalSummary = summary;
        step = PositiveNewsStep.TRANSLATING;
      });
      _translateArticles(summary);
    });
  }

  _translateArticles(String article) {
    debugPrint("Résumé de l'article : $article");
    final prompt =
        "Traduit de l'anglais vers le français le texte suivant : $article";
    geminiNanoService.reformulate(prompt, GeminiReformulate.REFORMULATE).then((traduction) {
      setState(() {
        step = PositiveNewsStep.ADDING_GOOD_VIBES;
        firstTranslation = traduction;
      });
      _injectGoodVibes(traduction);
    });
  }

  _injectGoodVibes(String article) {
    debugPrint("Traduction du résumé : $article");
    final prompt =
        """Le texte suivant est un résumé d'article en quelques points : $article.
        Je veux que tu gardes la même struture et que pour chacun des points tu les présentes comme des supers nouvelles.
        Le résultat doit faire moins de 100 mots et être super enthousiaste""";
    geminiNanoService.generateResponse(prompt).then((tadaaaa) {
      setState(() {
        step = PositiveNewsStep.READY;
        //beforeEmoji = tadaaaa;
        finalContent = tadaaaa;
      });
      //_injectEmojis(tadaaaa);
    });
  }

  _injectEmojis(String tadaa) {
    geminiNanoService.reformulate(tadaa, GeminiReformulate.EMOJIFY).then((emojis) {
      setState(() {
        step = PositiveNewsStep.READY;
        finalContent = emojis;
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
          "Résumé de l'article",
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
            colors: [Color(0xFFF5E6D3), Color(0xFFE8B4A0)],
          ),
        ),
        child: step == PositiveNewsStep.LOADING_CONTENT
            ? _LoadingContentFromInternetWidget()
            : step == PositiveNewsStep.SUMMURAZING_CONTENT
            ? _LoadingSummarizedContent()
            : step == PositiveNewsStep.TRANSLATING
            ? _TranslatingWidget()
            : step == PositiveNewsStep.EMOJIFICATION
            ? _EmojificationWidget()
            : step == PositiveNewsStep.ADDING_GOOD_VIBES
            ? _AddingGoodVibesWidget()
            : _Content(
                finalContent, 
                articleDetail!, 
                originalContent, 
                originalSummary, 
                firstTranslation,
                beforeEmoji,
              ),
      ),
    );
  }
}

class _Content extends StatelessWidget {
  final String content;
  final GuardianArticleDetail articleDetail;
  final String originalContent;
  final String originalSummary;
  final String firstTranslation;
  final String beforeEmoji;

  const _Content(
    this.content, 
    this.articleDetail, 
    this.originalContent, 
    this.originalSummary, 
    this.firstTranslation,
    this.beforeEmoji,
  );

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.platformDefault)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _ContentWidget(content: content),
          _LinkWidget(
            webUrl: articleDetail.webUrl,
            onLinkTap: () => _launchUrl(articleDetail.webUrl),
          ),
          _WarningWidget(),
          ExpandableContentWidget(
            title: 'Contenu original (en anglais)',
            content: originalContent,
            icon: Icons.article,
          ),
          ExpandableContentWidget(
            title: 'Premier résumé',
            content: originalSummary,
            icon: Icons.summarize,
          ),
          ExpandableContentWidget(
            title: 'Première traduction',
            content: firstTranslation,
            icon: Icons.translate,
          ),
          ExpandableContentWidget(
            title: 'Ajout des bonnes ondes',
            content: beforeEmoji,
            icon: Icons.sunny,
          ),
          const SizedBox(height: 30)
        ],
      ),
    );
  }
}

class _LinkWidget extends StatelessWidget {
  final String webUrl;
  final VoidCallback onLinkTap;

  const _LinkWidget({
    required this.webUrl,
    required this.onLinkTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: ElevatedButton.icon(
        onPressed: onLinkTap,
        icon: const Icon(Icons.open_in_new, color: Colors.white),
        label: const Text(
          'Lire l\'article complet',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF8B4513),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}

class _ContentWidget extends StatelessWidget {
  final String content;

  const _ContentWidget({required this.content});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: MarkdownBody(
        data: content,
        styleSheet: MarkdownStyleSheet(
          p: const TextStyle(
            fontSize: 16,
            height: 1.6,
            color: Color(0xFF2C1810),
          ),
          h1: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF8B4513),
          ),
          h2: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF8B4513),
          ),
          h3: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF8B4513),
          ),
          strong: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF8B4513),
          ),
          em: const TextStyle(
            fontStyle: FontStyle.italic,
            color: Color(0xFF6B4423),
          ),
        ),
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
            CircularProgressIndicator(color: Color(0xFF8B4513)),
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
            CircularProgressIndicator(color: Color(0xFF8B4513)),
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
            CircularProgressIndicator(color: Color(0xFF8B4513)),
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

class _EmojificationWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Color(0xFF8B4513)),
            SizedBox(height: 16),
            Text(
              "Pose de la touche finale !",
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
            CircularProgressIndicator(color: Color(0xFF8B4513)),
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

class _WarningWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange, width: 2),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.warning,
            color: Colors.orange.shade900,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Attention, les faits sont légèrement modifiés à l\'aide de l\'IA pour leur donner un aspect positif, vérifiez-les sur internet avant de les partager',
              style: TextStyle(
                fontSize: 14,
                color: Colors.orange.shade900,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ExpandableContentWidget extends StatefulWidget {
  final String title;
  final String content;
  final IconData icon;
  final bool withPadding;

  const ExpandableContentWidget({
    required this.title,
    required this.content,
    required this.icon,
    this.withPadding = true,
  });

  @override
  State<ExpandableContentWidget> createState() => _ExpandableContentWidgetState();
}

class _ExpandableContentWidgetState extends State<ExpandableContentWidget> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: widget.withPadding? 20 : 0, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: ExpansionTile(
        leading: Icon(
          widget.icon,
          color: const Color(0xFF8B4513),
        ),
        title: Text(
          widget.title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF8B4513),
          ),
        ),
        onExpansionChanged: (expanded) {
          setState(() {
            isExpanded = expanded;
          });
        },
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              widget.content.isNotEmpty ? widget.content : 'Contenu vide',
              style: const TextStyle(
                fontSize: 14,
                height: 1.5,
                color: Color(0xFF2C1810),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum PositiveNewsStep {
  LOADING_CONTENT,
  SUMMURAZING_CONTENT,
  TRANSLATING,
  ADDING_GOOD_VIBES,
  EMOJIFICATION,
  READY,
}
