import 'package:flutter/material.dart';
import 'package:positive_thinker/pages/article_detail_page.dart';
import 'package:positive_thinker/services/gemini_nano_service.dart';
import 'package:positive_thinker/services/gemini_nano_service_with_metrics.dart';

class BetterReadingPage extends StatefulWidget {
  const BetterReadingPage({super.key});

  @override
  State<BetterReadingPage> createState() => _BetterReadingPageState();
}

class _BetterReadingPageState extends State<BetterReadingPage> {
  final TextEditingController _textController = TextEditingController();
  int _wordCount = 0;
  static const int _maxWords = 150;
  final GeminiNanoServiceWithMetrics geminiNanoService = GeminiNanoServiceWithMetrics();
  EnjolivationSteps step = EnjolivationSteps.WAITING_FOR_INPUT;
  String userInput = "";
  String developpedIteration = "";
  String dynamisedText = "";
  String finalContent = "";

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

  void _onEnjoliver() {
    setState(() {
      userInput = _textController.text.trim();
      step = EnjolivationSteps.DEVELOPPING;
    });
    geminiNanoService.reformulate(userInput, GeminiReformulate.DEVELOP).then((firstIteration) {
      setState(() {
        developpedIteration = firstIteration;
        step = EnjolivationSteps.DYNAMISING;
      });
      _dynamising(firstIteration);
    });
  }

  void _dynamising(String firstIteration) {
    geminiNanoService.reformulate(firstIteration, GeminiReformulate.DYNAMISE).then((dynamised) {
      setState(() {
        dynamisedText = dynamised;
        step = EnjolivationSteps.ADDING_EMOJIS;
      });
      _emojify(dynamised);
    });
  }

  void _emojify(String dynamised) {
    geminiNanoService.reformulate(dynamised, GeminiReformulate.EMOJIFY).then((emojiText) {
      setState(() {
        finalContent = emojiText;
        step = EnjolivationSteps.READY;
      });
    });
  }

  void _resetToInitialState() {
    setState(() {
      step = EnjolivationSteps.WAITING_FOR_INPUT;
      userInput = "";
      developpedIteration = "";
      dynamisedText = "";
      finalContent = "";
    });
    _textController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final isOverLimit = _wordCount > _maxWords;

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
              // En-tête avec bouton retour
              _HeaderWidget(onBack: () => Navigator.of(context).pop()),

              // Contenu principal
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 20),

                      // Instructions
                      _InstructionWidget(),

                      const SizedBox(height: 30),

                      if (step == EnjolivationSteps.READY) ...[
                        Text(finalContent),
                        const SizedBox(height: 30),
                        _RestartButton(onPressed: _resetToInitialState),
                        const SizedBox(height: 30),
                      ],

                      if (step != EnjolivationSteps.READY) ...[
                        // Champ de texte
                        _TextInputWidget(
                          controller: _textController,
                          wordCount: _wordCount,
                          maxWords: _maxWords,
                          isOverLimit: isOverLimit,
                          enabled: step == EnjolivationSteps.WAITING_FOR_INPUT,
                        ),

                        const SizedBox(height: 30),

                        // Bouton Enjoliver
                        _EnjolliverButton(
                          loading: step == EnjolivationSteps.DEVELOPPING,
                          onPressed: _textController.text.trim().isNotEmpty && !isOverLimit ? _onEnjoliver : null,
                        ),
                      ],

                      if (userInput.isNotEmpty) ...[
                        const SizedBox(height: 30),
                        ExpandableContentWidget(
                          title: 'Ce que vous avez écrit',
                          content: userInput,
                          icon: Icons.edit_note,
                          withPadding: false,
                        ),
                        const SizedBox(height: 30),
                      ],
                      if (developpedIteration.isNotEmpty) ...[
                        ExpandableContentWidget(
                          title: 'Augmentation du texte',
                          content: developpedIteration,
                          icon: Icons.model_training_outlined,
                          withPadding: false,
                        ),
                        const SizedBox(height: 30),
                      ],
                      if (dynamisedText.isNotEmpty) ...[
                        ExpandableContentWidget(
                          title: 'Dynamisation du texte',
                          content: dynamisedText,
                          icon: Icons.flash_on,
                          withPadding: false,
                        ),
                        const SizedBox(height: 30),
                      ],
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

// Widget privé pour l'en-tête
class _HeaderWidget extends StatelessWidget {
  final VoidCallback onBack;

  const _HeaderWidget({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF8B4513)),
            onPressed: onBack,
          ),
          const Expanded(
            child: Text(
              'Enjolivation',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF8B4513)),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 48), // Pour centrer le titre
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
        color: Colors.white.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          const Icon(Icons.edit_note, size: 40, color: Color(0xFFD2691E)),
          const SizedBox(height: 16),
          const Text(
            'Racontez-nous un moment de votre journée',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF8B4513)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// Widget privé pour le champ de texte
class _TextInputWidget extends StatelessWidget {
  final TextEditingController controller;
  final int wordCount;
  final int maxWords;
  final bool isOverLimit;
  final bool enabled;

  const _TextInputWidget({
    required this.controller,
    required this.wordCount,
    required this.maxWords,
    required this.isOverLimit,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          decoration: BoxDecoration(
            color: enabled ? Colors.white : Colors.grey,
            borderRadius: BorderRadius.circular(15),
            boxShadow: enabled
                ? [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 4))]
                : [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 5, offset: const Offset(0, 2))],
          ),
          child: TextField(
            controller: controller,
            maxLines: 8,
            enabled: enabled,
            decoration: InputDecoration(
              hintText: enabled
                  ? 'Décrivez une expérience, une émotion, ou une réflexion. Je vous aiderai à voir les aspects positifs.'
                  : 'Traitement en cours...',
              hintStyle: TextStyle(
                color: enabled ? Colors.grey[500] : Colors.grey[400],
                fontSize: 16,
                fontStyle: enabled ? FontStyle.normal : FontStyle.italic,
              ),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.all(20),
              filled: true,
              fillColor: enabled ? Colors.white : Colors.grey[200],
            ),
            style: TextStyle(fontSize: 16, color: enabled ? const Color(0xFF8B4513) : Colors.grey[600], height: 1.5),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '$wordCount / $maxWords mots',
              style: TextStyle(
                fontSize: 14,
                color: isOverLimit ? Colors.red : const Color(0xFF8B4513),
                fontWeight: isOverLimit ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            if (isOverLimit)
              const Text(
                'Limite dépassée',
                style: TextStyle(fontSize: 14, color: Colors.red, fontWeight: FontWeight.bold),
              ),
          ],
        ),
      ],
    );
  }
}

// Widget privé pour le bouton Enjoliver
class _EnjolliverButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool loading;

  const _EnjolliverButton({required this.onPressed, required this.loading});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        gradient: onPressed != null ? const LinearGradient(colors: [Color(0xFFD2691E), Color(0xFFFF8C00)]) : null,
        color: onPressed == null ? Colors.grey[400] : null,
        boxShadow: onPressed != null
            ? [BoxShadow(color: Colors.orange.withValues(alpha: 0.4), blurRadius: 15, offset: const Offset(0, 6))]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(15),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                loading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Icon(Icons.auto_fix_high, color: Colors.white, size: 24),
                SizedBox(width: 12),
                Text(
                  loading ? 'Enjolivation en cours...' : 'Enjoliver',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

enum EnjolivationSteps { WAITING_FOR_INPUT, DEVELOPPING, DYNAMISING, ADDING_EMOJIS, READY }

// Widget privé pour le bouton Recommencer
class _RestartButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _RestartButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        gradient: const LinearGradient(colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)]),
        boxShadow: [BoxShadow(color: Colors.green.withValues(alpha: 0.4), blurRadius: 15, offset: const Offset(0, 6))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(15),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.refresh, color: Colors.white, size: 24),
                SizedBox(width: 12),
                Text(
                  'Recommencer',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
