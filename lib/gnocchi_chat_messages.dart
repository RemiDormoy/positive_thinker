part of 'coach_page.dart';

// Classe pour représenter un message de chat
class ChatMessage extends Equatable {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final bool isLoading;
  final File? image;

  const ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.isLoading = false,
    this.image,
  });

  @override
  List<Object?> get props => [text, isUser, timestamp, isLoading, image];
}

// Widget privé pour la liste des messages
class _ChatMessagesListWidget extends StatelessWidget {
  final List<ChatMessage> messages;
  final ScrollController scrollController;

  const _ChatMessagesListWidget({
    required this.messages,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    if (messages.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        return _MessageWidget(message: message);
      },
    );
  }
}

// Widget privé pour un message individuel
class _MessageWidget extends StatelessWidget {
  final ChatMessage message;

  const _MessageWidget({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Row(
        mainAxisAlignment: message.isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            _AssistantAvatarWidget(),
            const SizedBox(width: 8.0),
          ],
          Flexible(
            child: message.isUser
                ? _UserMessageWidget(message: message)
                : _AssistantMessageWidget(message: message),
          ),
          if (message.isUser) ...[
            const SizedBox(width: 8.0),
            _UserAvatarWidget(),
          ],
        ],
      ),
    );
  }
}

// Widget privé pour l'avatar utilisateur
class _UserAvatarWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(200),
      child: Image.asset('images/user_chat.png', height: 80, width: 80),
    );
  }
}

// Widget privé pour l'avatar de l'assistant
class _AssistantAvatarWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(200),
      child: Image.asset(
        'images/coach_gnocchi.png',
        fit: BoxFit.fitHeight,
        height: 80,
        width: 80,
      ),
    );
  }
}

// Widget privé pour les messages utilisateur
class _UserMessageWidget extends StatelessWidget {
  final ChatMessage message;

  const _UserMessageWidget({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.deepPurple,
        borderRadius: BorderRadius.circular(18.0),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (message.image != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(12.0),
              child: Image.file(
                message.image!,
                height: 300,
                fit: BoxFit.contain,
              ),
            ),
            if (message.text.isNotEmpty) const SizedBox(height: 8.0),
          ],
          if (message.text.isNotEmpty)
            Text(
              message.text,
              style: const TextStyle(color: Colors.white, fontSize: 16.0),
            ),
        ],
      ),
    );
  }
}

// Widget privé pour les messages de l'assistant
class _AssistantMessageWidget extends StatelessWidget {
  final ChatMessage message;

  const _AssistantMessageWidget({required this.message});

  @override
  Widget build(BuildContext context) {
    if (message.isLoading) {
      return _TypingIndicatorWidget();
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(18.0),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      child: Text(
        message.text,
        style: const TextStyle(color: Colors.black87, fontSize: 16.0),
      ),
    );
  }
}

// Widget privé pour l'indicateur de frappe
class _TypingIndicatorWidget extends StatefulWidget {
  @override
  State<_TypingIndicatorWidget> createState() => _TypingIndicatorWidgetState();
}

class _TypingIndicatorWidgetState extends State<_TypingIndicatorWidget>
    with TickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animationController.repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(18.0),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Coach Gnocchi écrit',
            style: TextStyle(
              color: Colors.black54,
              fontSize: 16.0,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(width: 8.0),
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Text(
                '...',
                style: TextStyle(
                  color: Colors.black54.withValues(
                    alpha: _animationController.value,
                  ),
                  fontSize: 16.0,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// Widget privé pour l'entrée de texte
class _ChatInputWidget extends StatelessWidget {
  final TextEditingController controller;
  final bool isGenerating;
  final Function(String) onSendMessage;
  final VoidCallback? onImageTap;

  const _ChatInputWidget({
    required this.controller,
    required this.isGenerating,
    required this.onSendMessage,
    this.onImageTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 4.0,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                enabled: !isGenerating,
                maxLines: null,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: 'Écrit à gnogno',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24.0),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 12.0,
                  ),
                ),
                onSubmitted: (text) {
                  if (!isGenerating) {
                    onSendMessage(text);
                  }
                },
              ),
            ),
            const SizedBox(width: 8.0),
            IconButton(
              onPressed: isGenerating ? null : onImageTap,
              icon: Icon(
                Icons.image,
                color: isGenerating ? Colors.grey : Colors.deepPurple,
              ),
              tooltip: 'Ajouter une image',
            ),
            const SizedBox(width: 8.0),
            IconButton(
              onPressed: isGenerating
                  ? null
                  : () => onSendMessage(controller.text),
              icon: Icon(
                Icons.send,
                color: isGenerating ? Colors.grey : Colors.deepPurple,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
