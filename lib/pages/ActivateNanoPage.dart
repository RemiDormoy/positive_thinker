import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class ActivateNanoPage extends StatelessWidget {
  const ActivateNanoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Activer Gemini Nano',
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
            colors: [Color(0xFFF5E6D3), Color(0xFFE8B4A0)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 30),
                _InstructionStepWidget(
                  stepNumber: 1,
                  title:
                      'Mettez à jour votre navigateur si il n\'est pas à jour',
                  description:
                      'Assurez-vous d\'avoir Chrome 127 ou plus récent',
                  actionText: null,
                  chromeUrl: null,
                ),
                const SizedBox(height: 20),
                _InstructionStepWidget(
                  stepNumber: 2,
                  title: 'Activer le flags Optimization Guide On Device',
                  description:
                      'Mettre la valeur à "Enabled BypassPerfRequirement"',
                  actionText: 'Ouvrir le flag',
                  chromeUrl:
                      'chrome://flags/#optimization-guide-on-device-model',
                  additionalSteps: [],
                ),
                const SizedBox(height: 20),
                _InstructionStepWidget(
                  stepNumber: 3,
                  title: 'Activer le flag Prompt API for Gemini Nano',
                  description: 'Sélectionnez "Enabled"',
                  actionText: 'Ouvrir le flag',
                  chromeUrl: 'chrome://flags/#prompt-api-for-gemini-nano',
                  additionalSteps: [],
                ),
                const SizedBox(height: 20),
                _InstructionStepWidget(
                  stepNumber: 4,
                  title: '(Pour pouvoir manipuler des images) Activer le flag Experimental JavaScript',
                  description: 'Sélectionnez "Enabled"',
                  actionText: 'Ouvrir le flag',
                  chromeUrl: 'chrome://flags/#enable-javascript-harmony',
                  additionalSteps: [],
                ),
                const SizedBox(height: 20),
                _InstructionStepWidget(
                  stepNumber: 5,
                  title: '(Pour pouvoir manipuler des images) Activer le flag Experimental WebAssembly',
                  description: 'Sélectionnez "Enabled"',
                  actionText: 'Ouvrir le flag',
                  chromeUrl: 'chrome://flags/#enable-experimental-webassembly-features',
                  additionalSteps: [],
                ),
                const SizedBox(height: 20),
                _InstructionStepWidget(
                  stepNumber: 6,
                  title: 'Redémarrer Chrome',
                  description:
                  'Relancez complètement votre navigateur pour appliquer les modifications',
                  actionText: 'Plus d\'infos',
                  isRestartStep: true,
                ),
                const SizedBox(height: 20),
                _InstructionStepWidget(
                  stepNumber: 7,
                  title: 'Activer le flag Rewriter pour Gemini Nano',
                  description: 'Sélectionnez "Enabled"',
                  actionText: 'Ouvrir le flag',
                  chromeUrl: 'chrome://flags/#rewriter-api-for-gemini-nano',
                  additionalSteps: [
                    'Vous pouvez ignorer les étapes 7 à 10 si vous activer tous les flags ayant "Gemini Nano" dans le nom',
                  ],
                ),
                const SizedBox(height: 20),
                _InstructionStepWidget(
                  stepNumber: 8,
                  title: 'Activer le flag Summarization pour Gemini Nano',
                  description: 'Sélectionnez "Enabled"',
                  actionText: 'Ouvrir le flag',
                  chromeUrl: 'chrome://flags/#summarization-api-for-gemini-nano',
                  additionalSteps: [],
                ),
                const SizedBox(height: 20),
                _InstructionStepWidget(
                  stepNumber: 9,
                  title: 'Activer le flag Proofreader pour Gemini Nano',
                  description: 'Sélectionnez "Enabled"',
                  actionText: 'Ouvrir le flag',
                  chromeUrl: 'chrome://flags/#proofreader-api-for-gemini-nano',
                  additionalSteps: [],
                ),
                const SizedBox(height: 20),
                _InstructionStepWidget(
                  stepNumber: 10,
                  title: 'Activer le flag Prompt API for Gemini Nano with Multimodal Input',
                  description: 'Sélectionnez "Enabled"',
                  actionText: 'Ouvrir le flag',
                  chromeUrl: 'chrome://flags/#prompt-api-for-gemini-nano-multimodal-input',
                  additionalSteps: [],
                ),

                const SizedBox(height: 20),
                _InstructionStepWidget(
                  stepNumber: 11,
                  title: 'Redémarrer Chrome',
                  description:
                  'Relancez complètement votre navigateur pour appliquer les modifications',
                  actionText: 'Plus d\'infos',
                  isRestartStep: true,
                ),
                const SizedBox(height: 20),
                _InstructionStepWidget(
                  stepNumber: 12,
                  title: "Essayez d'utiliser le modèle depuis la console",
                  description:
                      'Ça ne marchera pas mais ça déclenchera le téléchargement du modèle',
                  actionText: 'Activez le modèle',
                  isCodeStep: true,
                  chromeUrl: """
await LanguageModel.create({
  monitor(m) {
    m.addEventListener("downloadprogress", e => {
      console.log(`Downloaded \${e.loaded * 100}%`);
    });
  }
});
                  """,
                  additionalSteps: [],
                ),
                const SizedBox(height: 20),
                _InstructionStepWidget(
                  stepNumber: 13,
                  title: 'Forcer le téléchargement du modèle',
                  description:
                      'Clickez sur "Rechercher des mises à jour" pour "Optimization Guide On Device Model"',
                  actionText: 'Ouvrir les composants',
                  chromeUrl: 'chrome://components/',
                  additionalSteps: [
                    'Recherchez "Optimization Guide On Device Model"',
                    'Cliquez sur "Vérifier les mises à jour"',
                    'Attendez que le statut devienne "À jour"',
                  ],
                ),
                const SizedBox(height: 20),
                _InstructionStepWidget(
                  stepNumber: 14,
                  title: 'Attendez la fin du téléchargement',
                  description:
                  'Cela peut prendre entre 5 et 10 minutes',
                  additionalSteps: [
                    '(Optionel) Faites un baby foot en attendant',
                    '(Optionel) Faites une pause café en attendant',
                  ],
                ),
                const SizedBox(height: 20),
                _InstructionStepWidget(
                  stepNumber: 15,
                  title: 'Vérifier l\'activation',
                  description:
                      'Testez si Gemini Nano est disponible dans la console',
                  actionText: 'Tester maintenant',
                  chromeUrl: 'await LanguageModel.availability()',
                  isCodeStep: true,
                  additionalSteps: [
                    'Ouvrez la console développeur (F12)',
                    'Tapez : await LanguageModel.availability()',
                    'Si "available": "readily" s\'affiche, c\'est activé !',
                  ],
                ),
                const SizedBox(height: 40),
                _TroubleshootingWidget(),
                const SizedBox(height: 30),
                _FooterWidget(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InstructionStepWidget extends StatelessWidget {
  final int stepNumber;
  final String title;
  final String description;
  final String? actionText;
  final String? chromeUrl;
  final List<String>? additionalSteps;
  final bool isRestartStep;
  final bool isCodeStep;

  const _InstructionStepWidget({
    required this.stepNumber,
    required this.title,
    required this.description,
    this.actionText,
    this.chromeUrl,
    this.additionalSteps,
    this.isRestartStep = false,
    this.isCodeStep = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _StepNumberWidget(stepNumber: stepNumber),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
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

            if (additionalSteps != null) ...[
              const SizedBox(height: 16),
              ...additionalSteps!.map(
                (step) => _AdditionalStepWidget(step: step),
              ),
            ],

            if (actionText != null) ...[
              const SizedBox(height: 16),
              _ActionButtonWidget(
                text: actionText!,
                onPressed: () => _handleAction(context),
                isRestartStep: isRestartStep,
                isCodeStep: isCodeStep,
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _handleAction(BuildContext context) async {

    if (isCodeStep) {
      _showCodeDialog(context, chromeUrl!);
      return;
    }

    if (chromeUrl != null) {
      try {
        final Uri uri = Uri.parse(chromeUrl!);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri);
        } else {
          _showUrlDialog(context, chromeUrl!);
        }
      } catch (e) {
        _showUrlDialog(context, chromeUrl!);
      }
    }
  }

  void _showUrlDialog(BuildContext context, String url) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text(
          'Copier l\'URL',
          style: TextStyle(
            color: Color(0xFF8B4513),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Copiez cette URL dans votre barre d\'adresse Chrome :',
              style: TextStyle(color: Color(0xFF8B4513)),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF5E6D3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: SelectableText(
                      url,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                        color: Color(0xFF8B4513),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () async {
                      await Clipboard.setData(ClipboardData(text: url));
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('URL copiée dans le presse-papiers'),
                            backgroundColor: Color(0xFFD2691E),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                    icon: const Icon(
                      Icons.copy,
                      color: Color(0xFFD2691E),
                      size: 20,
                    ),
                    tooltip: 'Copier l\'URL',
                    padding: const EdgeInsets.all(4),
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Fermer',
              style: TextStyle(color: Color(0xFFD2691E)),
            ),
          ),
        ],
      ),
    );
  }

  void _showCodeDialog(BuildContext context, String url) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text(
          'Ouvrez la console développeur avec F12',
          style: TextStyle(
            color: Color(0xFF8B4513),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Copiez cette commande dans la console',
              style: TextStyle(color: Color(0xFF8B4513)),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF5E6D3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: SelectableText(
                      url,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                        color: Color(0xFF8B4513),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () async {
                      await Clipboard.setData(ClipboardData(text: url));
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Code copié dans le presse-papiers'),
                            backgroundColor: Color(0xFFD2691E),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                    icon: const Icon(
                      Icons.copy,
                      color: Color(0xFFD2691E),
                      size: 20,
                    ),
                    tooltip: 'Copier l\'URL',
                    padding: const EdgeInsets.all(4),
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Fermer',
              style: TextStyle(color: Color(0xFFD2691E)),
            ),
          ),
        ],
      ),
    );
  }
}

class _StepNumberWidget extends StatelessWidget {
  final int stepNumber;

  const _StepNumberWidget({required this.stepNumber});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFD2691E), Color(0xFFFF8C00)],
        ),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          stepNumber.toString(),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class _AdditionalStepWidget extends StatelessWidget {
  final String step;

  const _AdditionalStepWidget({required this.step});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '• ',
            style: TextStyle(
              color: Color(0xFFD2691E),
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          Expanded(
            child: Text(
              step,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF8B4513),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButtonWidget extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isRestartStep;
  final bool isCodeStep;

  const _ActionButtonWidget({
    required this.text,
    required this.onPressed,
    this.isRestartStep = false,
    this.isCodeStep = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style:
            ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ).copyWith(
              backgroundColor: WidgetStateProperty.all(Colors.transparent),
            ),
        child: Ink(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFD2691E), Color(0xFFFF8C00)],
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isRestartStep ? Icons.refresh : Icons.open_in_new,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  text,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TroubleshootingWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      color: const Color(0xFFFFF8DC),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.help_outline, color: Color(0xFFD2691E), size: 24),
                SizedBox(width: 12),
                Text(
                  'Problèmes fréquents',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF8B4513),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _TroubleshootingItemWidget(
              problem: 'Le modèle ne se télécharge pas',
              solution:
                  'Vérifiez votre connexion internet et attendez quelques minutes. Le téléchargement peut prendre du temps.',
            ),
            _TroubleshootingItemWidget(
              problem: 'Les flags ne sont pas disponibles',
              solution:
                  'Votre version de Chrome est peut-être trop ancienne. Mettez à jour vers Chrome 127+.',
            ),
            _TroubleshootingItemWidget(
              problem: 'L\'API retourne "not-supported"',
              solution:
                  'Assurez-vous d\'avoir redémarré Chrome après avoir activé les flags.',
            ),
          ],
        ),
      ),
    );
  }
}

class _TroubleshootingItemWidget extends StatelessWidget {
  final String problem;
  final String solution;

  const _TroubleshootingItemWidget({
    required this.problem,
    required this.solution,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '❓ $problem',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF8B4513),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '💡 $solution',
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF8B4513),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _FooterWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 32),
          const SizedBox(height: 12),
          const Text(
            'Une fois ces étapes terminées',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF8B4513),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Vous pourrez profiter de toutes les fonctionnalités IA de Positive Thinker directement dans votre navigateur !',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF8B4513),
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
