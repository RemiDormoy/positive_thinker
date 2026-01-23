import 'package:flutter/material.dart';

class WritingImprovementPage extends StatefulWidget {
  const WritingImprovementPage({super.key});

  @override
  State<WritingImprovementPage> createState() => _WritingImprovementPageState();
}

class _WritingImprovementPageState extends State<WritingImprovementPage> {
  final TextEditingController _textController = TextEditingController();
  int _wordCount = 0;
  static const int _maxWords = 150;

  @override
  void initState() {
    super.initState();
    _textController.addListener(_updateWordCount);
  }

  @override
  void dispose() {
    _textController.removeListener(_updateWordCount);
    _textController.dispose();
    super.dispose();
  }

  void _updateWordCount() {
    final text = _textController.text.trim();
    if (text.isEmpty) {
      setState(() {
        _wordCount = 0;
      });
    } else {
      final words = text.split(RegExp(r'\s+'));
      setState(() {
        _wordCount = words.length;
      });
    }
  }

  void _onCorrectPressed() {
    // Pour le moment, ne fait rien
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Fonctionnalité de correction en développement'),
        duration: Duration(seconds: 2),
      ),
    );
  }

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
          child: Column(
            children: [
              // Header avec bouton retour
              _HeaderWidget(
                onBackPressed: () => Navigator.of(context).pop(),
              ),
              
              // Contenu principal
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Description
                      _InstructionWidget(),
                      
                      const SizedBox(height: 30),
                      
                      // Champ de texte
                      _TextFieldWidget(
                        controller: _textController,
                        wordCount: _wordCount,
                        maxWords: _maxWords,
                      ),
                      
                      const SizedBox(height: 30),
                      
                      // Bouton corriger
                      _CorrectButtonWidget(
                        onPressed: _wordCount > 0 && _wordCount <= _maxWords ? _onCorrectPressed : null,
                        isEnabled: _wordCount > 0 && _wordCount <= _maxWords,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Widget privé pour le header
class _HeaderWidget extends StatelessWidget {
  final VoidCallback onBackPressed;

  const _HeaderWidget({required this.onBackPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          IconButton(
            onPressed: onBackPressed,
            icon: const Icon(
              Icons.arrow_back,
              color: Color(0xFF8B4513),
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Text(
              'Mon écriture en mieux',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF8B4513),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Widget privé pour les instructions
class _InstructionWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.science_outlined,
                color: Color(0xFFD2691E),
                size: 24,
              ),
              const SizedBox(width: 12),
              const Text(
                'Le correcteur fou !',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF8B4513),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            "Balance moi n'importe quoi, ça ressortira propre",
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF8B4513),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

// Widget privé pour le champ de texte
class _TextFieldWidget extends StatelessWidget {
  final TextEditingController controller;
  final int wordCount;
  final int maxWords;

  const _TextFieldWidget({
    required this.controller,
    required this.wordCount,
    required this.maxWords,
  });

  @override
  Widget build(BuildContext context) {
    final isOverLimit = wordCount > maxWords;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Votre message à corriger :',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF8B4513),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isOverLimit ? Colors.red : Colors.white,
              width: 2,
            ),
          ),
          child: TextField(
            controller: controller,
            maxLines: 8,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF8B4513),
            ),
            decoration: InputDecoration(
              hintText: 'Collez votre message ici...',
              hintStyle: TextStyle(
                color: Color(0xFF8B4513).withValues(alpha: 0.6),
                fontSize: 16,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '$wordCount / $maxWords mots',
              style: TextStyle(
                fontSize: 14,
                color: isOverLimit ? Colors.red : Color(0xFF8B4513),
                fontWeight: isOverLimit ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            if (isOverLimit)
              const Text(
                'Limite dépassée !',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
      ],
    );
  }
}

// Widget privé pour le bouton corriger
class _CorrectButtonWidget extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isEnabled;

  const _CorrectButtonWidget({
    required this.onPressed,
    required this.isEnabled,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isEnabled ? Color(0xFFD2691E) : Colors.grey,
          foregroundColor: Colors.white,
          elevation: isEnabled ? 4 : 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.auto_fix_high,
              size: 24,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            const Text(
              'Corriger',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
