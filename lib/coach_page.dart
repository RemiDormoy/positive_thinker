import 'dart:io';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:positive_thinker/gemini_nano_service.dart';

part 'gnocchi_chat_messages.dart';


class SmartCoachAssistantPage extends StatefulWidget {
  const SmartCoachAssistantPage({super.key});

  @override
  State<SmartCoachAssistantPage> createState() =>
      _SmartCoachAssistantPageState();
}

class _SmartCoachAssistantPageState extends State<SmartCoachAssistantPage> {
  final List<ChatMessage> _messages = [];
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isGenerating = false;
  final GeminiNanoService geminiNanoService = GeminiNanoService();
  final ImagePicker _imagePicker = ImagePicker();


  @override
  void initState() {
    super.initState();
    _initializeGeminiNano();
    _addWelcomeMessage();
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _addWelcomeMessage() {
    setState(() {
      _messages.add(
        ChatMessage(
          text:
              "Salut ! Je suis Coach Gnocchi, ton assistant de vie pour t'aider à être heureux comme moi quand je cours après un lapin !",
          isUser: false,
          timestamp: DateTime.now(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
      AppBar(
        title: Text(
          "Coach Gnocchi",
          style: const TextStyle(
            color: Color(0xFF8B4513),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFFF5E6D3),
        iconTheme: const IconThemeData(color: Color(0xFF8B4513)),
        elevation: 0,
      ),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
            child: DecoratedBox(
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
              child: _ChatMessagesListWidget(
                messages: _messages,
                scrollController: _scrollController,
              ),
            ),
          ),
          _ChatInputWidget(
            controller: _textController,
            isGenerating: _isGenerating,
            onSendMessage: _handleSendMessage,
            onImageTap: _handleImageSelection,
          ),
        ],
      ),
    );
  }


  Future<String> _generateResponse(String prompt) async {
      return _generateResponseWithGemini(prompt);
  }

  Future<void> _handleSendMessage(String text) async {
    if (text.trim().isEmpty || _isGenerating) return;

    // Ajouter le message utilisateur
    setState(() {
      _messages.add(
        ChatMessage(text: text.trim(), isUser: true, timestamp: DateTime.now()),
      );
      _isGenerating = true;
    });

    _textController.clear();
    _scrollToBottom();

    // Ajouter un message de chargement pour l'IA
    setState(() {
      _messages.add(
        ChatMessage(
          text: "",
          isUser: false,
          timestamp: DateTime.now(),
          isLoading: true,
        ),
      );
    });

    try {
      final response = await _generateResponse(text.trim());

      // Remplacer le message de chargement par la réponse
      setState(() {
        _messages.removeLast();
        _messages.add(
          ChatMessage(text: response, isUser: false, timestamp: DateTime.now()),
        );
        _isGenerating = false;
      });
    } catch (e) {
      // Remplacer le message de chargement par une erreur
      setState(() {
        _messages.removeLast();
        _messages.add(
          ChatMessage(
            text: "Désolé, j'ai rencontré un problème. Peux-tu réessayer ?",
            isUser: false,
            timestamp: DateTime.now(),
          ),
        );
        _isGenerating = false;
      });
    }

    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _initializeGeminiNano() async {
    await geminiNanoService.initialize();
  }

  Future<String> _generateResponseWithGemini(String prompt) async {
    final result = await geminiNanoService.generateResponse(
      """Imagine que tu es un chien dont le rôle est de me faire comprendre que ma vie est super bien. 
       J'ai dit le message suivant : $prompt
       Je voudrais que tu me montres, en tant que chien qui parle français, le bon côté des choses dans ce que j'ai dit, en moins de 100 mots""",

    );
    return result.trim();
  }

  Future<void> _handleImageSelection() async {
    if (_isGenerating) return;

    final ImageSource? source = await _showImageSourceDialog();
    if (source != null) {
      await _pickImageFromSource(source);
    }
  }

  Future<ImageSource?> _showImageSourceDialog() async {
    return await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 8),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _ImageSourceButton(
                      icon: Icons.photo_library,
                      label: 'Galerie',
                      color: Colors.deepPurple,
                      onTap: () => Navigator.of(context).pop(ImageSource.gallery),
                    ),
                    _ImageSourceButton(
                      icon: Icons.camera_alt,
                      label: 'Caméra',
                      color: Colors.deepPurple,
                      onTap: () => Navigator.of(context).pop(ImageSource.camera),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickImageFromSource(ImageSource source) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        final File imageFile = File(image.path);
        await _handleSendImageMessage(imageFile);
      }
    } catch (e) {
      if (mounted) {
        final String sourceText = source == ImageSource.camera ? 'caméra' : 'galerie';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de l\'accès à la $sourceText'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleSendImageMessage(File imageFile) async {
    if (_isGenerating) return;

    // Ajouter le message utilisateur avec image
    setState(() {
      _messages.add(
        ChatMessage(
          text: "",
          isUser: true,
          timestamp: DateTime.now(),
          image: imageFile,
        ),
      );
      _isGenerating = true;
    });


    // Ajouter un message de chargement pour l'IA
    setState(() {
      _messages.add(
        ChatMessage(
          text: "...",
          isUser: false,
          timestamp: DateTime.now(),
          isLoading: true,
        ),
      );
    });

    _scrollToBottom();
    
    _generateResponseWithImageGemini(imageFile);
  }

  Future<void> _generateResponseWithImageGemini(File imageFile) async {
    try {
      final result = await geminiNanoService.generateResponseWithImage(imageFile);
      
      // Remplacer le message de chargement par la réponse
      setState(() {
        _messages.removeLast();
        _messages.add(
          ChatMessage(text: result.trim(), isUser: false, timestamp: DateTime.now()),
        );
        _isGenerating = false;
      });
    } catch (e) {
      // Remplacer le message de chargement par une erreur
      setState(() {
        _messages.removeLast();
        _messages.add(
          ChatMessage(
            text: "Désolé, j'ai rencontré un problème pour analyser cette image. Peux-tu réessayer ?",
            isUser: false,
            timestamp: DateTime.now(),
          ),
        );
        _isGenerating = false;
      });
    }
    
    _scrollToBottom();
  }
}

class _ImageSourceButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ImageSourceButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 30,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
