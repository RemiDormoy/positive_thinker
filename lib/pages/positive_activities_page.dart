import 'dart:io';

import 'package:flutter/material.dart';
import 'package:positive_thinker/models/chat_message.dart';

part '../widgets/positive_activities_chat_widget.dart';

class PositiveActivitiesPage extends StatefulWidget {
  const PositiveActivitiesPage({super.key});

  @override
  State<PositiveActivitiesPage> createState() => _PositiveActivitiesPageState();
}

class _PositiveActivitiesPageState extends State<PositiveActivitiesPage> {
  final List<ChatMessage> _messages = [];
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isGenerating = false;

  @override
  void initState() {
    super.initState();
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
          text: "Raconte moi ce qui se passe, et on va trouver ensemble comment changer ça",
          isUser: false,
          timestamp: DateTime.now(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Positive Activities",
          style: TextStyle(color: Color(0xFF8B4513), fontWeight: FontWeight.bold),
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
          ),
        ],
      ),
    );
  }

  Future<void> _handleSendMessage(String text) async {
    if (text.trim().isEmpty || _isGenerating) return;

    // Ajouter le message utilisateur
    setState(() {
      _messages.add(ChatMessage(
        text: text.trim(),
        isUser: true,
        timestamp: DateTime.now(),
      ));
      _isGenerating = true;
    });

    _textController.clear();
    _scrollToBottom();

    // Ajouter un message de chargement pour l'IA
    setState(() {
      _messages.add(ChatMessage(
        text: "",
        isUser: false,
        timestamp: DateTime.now(),
        isLoading: true,
      ));
    });

    // TODO: Implement service call here
    // For now, just simulate a delay
    await Future.delayed(const Duration(seconds: 2));

    // Remplacer le message de chargement par une réponse temporaire
    setState(() {
      _messages.removeLast();
      _messages.add(ChatMessage(
        text: "Je comprends. Laisse-moi réfléchir à des activités positives qui pourraient t'aider...",
        isUser: false,
        timestamp: DateTime.now(),
      ));
      _isGenerating = false;
    });

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
}
