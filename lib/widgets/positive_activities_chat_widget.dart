part of '../pages/positive_activities_page.dart';

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

class _MessageWidget extends StatelessWidget {
  final ChatMessage message;

  const _MessageWidget({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Row(
        mainAxisAlignment: message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
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

class _UserAvatarWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(200),
        border: Border.all(color: const Color(0xFF5D4037)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(200),
        child: Image.asset(
          'images/user_chat.png',
          height: 80,
          width: 80,
        ),
      ),
    );
  }
}

class _AssistantAvatarWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(200),
        border: Border.all(color: Color(0xFF5D4037)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(200),
        child: Image.asset('images/coach_gnocchi.png', fit: BoxFit.fitHeight, height: 80, width: 80),
      ),
    );
  }
}

class _UserMessageWidget extends StatelessWidget {
  final ChatMessage message;

  const _UserMessageWidget({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF8B4513)),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF8B4513), Color(0xFF5D4037)],
        ),
        borderRadius: BorderRadius.circular(18.0),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      child: Text(
        message.text,
        style: const TextStyle(color: Colors.white, fontSize: 16.0),
      ),
    );
  }
}

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
        border: Border.all(color: Colors.white),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            Color(0xFFF5E6D3),
          ],
        ),
        borderRadius: BorderRadius.circular(18.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      child: Text(
        message.text,
        style: const TextStyle(
          color: Color(0xFF5D4037),
          fontSize: 16.0,
          height: 1.4,
        ),
      ),
    );
  }
}

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
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFF5E6D3).withValues(alpha: 0.7),
            const Color(0xFFE8B4A0).withValues(alpha: 0.5),
          ],
        ),
        borderRadius: BorderRadius.circular(18.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'En train de réfléchir',
            style: TextStyle(
              color: Color(0xFF5D4037),
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
                  color: const Color(0xFF5D4037).withValues(
                    alpha: 0.5 + (_animationController.value * 0.5),
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

class _ChatInputWidget extends StatelessWidget {
  final TextEditingController controller;
  final bool isGenerating;
  final Function(String) onSendMessage;

  const _ChatInputWidget({
    required this.controller,
    required this.isGenerating,
    required this.onSendMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFFDF8F3),
            Color(0xFFF5E6D3),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE8B4A0).withValues(alpha: 0.3),
            blurRadius: 8.0,
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
                textInputAction: TextInputAction.send,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: 'Raconte moi ce qui ne va pas...',
                  hintStyle: TextStyle(
                    color: const Color(0xFF5D4037).withValues(alpha: 0.6),
                  ),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.8),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24.0),
                    borderSide: BorderSide(
                      color: const Color(0xFFE8B4A0).withValues(alpha: 0.5),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24.0),
                    borderSide: BorderSide(
                      color: const Color(0xFFE8B4A0).withValues(alpha: 0.5),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24.0),
                    borderSide: const BorderSide(
                      color: Color(0xFF8B4513),
                      width: 2.0,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 12.0,
                  ),
                ),
                style: const TextStyle(color: Color(0xFF5D4037)),
                onSubmitted: (text) {
                  if (!isGenerating && text.trim().isNotEmpty) {
                    onSendMessage(text.trim());
                  }
                },
              ),
            ),
            const SizedBox(width: 8.0),
            _SendButton(
              onPressed: isGenerating
                  ? null
                  : () => onSendMessage(controller.text),
              isEnabled: !isGenerating,
            ),
          ],
        ),
      ),
    );
  }
}

class _SendButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isEnabled;

  const _SendButton({
    required this.onPressed,
    required this.isEnabled,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: isEnabled
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFFF5E6D3).withValues(alpha: 0.2),
                  const Color(0xFF8B4513).withValues(alpha: 0.4),
                ],
              )
            : null,
        color: isEnabled ? null : Colors.grey.withValues(alpha: 0.1),
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFF8B4513)),
        boxShadow: isEnabled
            ? [
                BoxShadow(
                  color: const Color(0xFF8B4513).withValues(alpha: 0.2),
                  blurRadius: 4.0,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(
          Icons.send,
          color: isEnabled ? const Color(0xFF8B4513) : Colors.grey,
          size: 24.0,
        ),
        tooltip: 'Envoyer',
        splashRadius: 24.0,
      ),
    );
  }
}
