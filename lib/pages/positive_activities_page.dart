import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/change_notifier.dart';
import 'package:genui_firebase_ai/genui_firebase_ai.dart';
import 'package:positive_thinker/gemini_api_key.dart';
import 'package:positive_thinker/models/chat_message.dart';
import 'package:genui/genui.dart';
import 'package:genui_google_generative_ai/genui_google_generative_ai.dart';
import 'package:json_schema_builder/json_schema_builder.dart';

part '../widgets/positive_activities_chat_widget.dart';

part 'genui_stuff.dart';
part 'local_content_generator.dart';

class PositiveActivitiesPage extends StatefulWidget {
  const PositiveActivitiesPage({super.key});

  @override
  State<PositiveActivitiesPage> createState() => _PositiveActivitiesPageState();
}

final catalog = CoreCatalogItems.asCatalog().copyWith([
  _moodCardWidget,
  _assistantMessageWidget,
  _activityCardWidget,
]);

class _PositiveActivitiesPageState extends State<PositiveActivitiesPage> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late GenUiConversation conversation;
  final _surfaceIds = <String>[];

  void _onSurfaceAdded(SurfaceAdded update) {
    setState(() {
      if (_surfaceIds.contains(update.surfaceId)) return;
      _surfaceIds.add(update.surfaceId);
    });
  }

  // A callback invoked by GenUiConversation when a UI surface is removed.
  void _onSurfaceDeleted(SurfaceRemoved update) {
    setState(() {
      _surfaceIds.remove(update.surfaceId);
    });
  }

  final messageProcessor = A2uiMessageProcessor(catalogs: [catalog]);
  final contentGeneratorLocal = LocalContentGenerator();
  /*final contentGenerator = FirebaseAiContentGenerator(
    catalog: catalog,
    systemInstruction: """
    Tu es un chien coach de vie. Ton but est d'analyser mon humeur pour ensuite trouver des activités pour m'aider à aller mieux.
    Je veux que tu analyse mon humeur en générant une MoodCard.
    Pour les autres messages, utilise un AssistantMessageCard et je voudrais que ces messages fassent moins de 100 mots.
    J'aimerais ensuite que tu me fasses trois propositions d'acitivités en utilisant ActivityCard.
    """,
  );*/
  final contentGenerator = GoogleGenerativeAiContentGenerator(
    catalog: catalog,
    systemInstruction: """
    Tu es un chien coach de vie. Ton but est d'analyser mon humeur pour ensuite trouver des activités pour m'aider à aller mieux.
    Je veux que tu analyse mon humeur en générant une MoodCard.
    Pour les autres messages, utilise un AssistantMessageCard et je voudrais que ces messages fassent moins de 100 mots.
    J'aimerais ensuite que tu me fasses trois propositions d'acitivités en utilisant ActivityCard.
    """,
    modelName: 'models/gemini-2.5-flash',
    apiKey: GEMINI_API_KEY,
  );

  @override
  void initState() {
    super.initState();
    conversation = GenUiConversation(
      contentGenerator: contentGenerator,
      a2uiMessageProcessor: messageProcessor,
      onSurfaceAdded: _onSurfaceAdded,
      onSurfaceDeleted: _onSurfaceDeleted,
      onError: (error) {
        print('Error: ${error.stackTrace?.toString()}');
        print('Error: ${error.error.toString()}');
      },
      onTextResponse: (reponse) => print("GenUI rewponse : $reponse"),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Positive Activities",
          style: TextStyle(
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
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                itemCount: _surfaceIds.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return _MessageWidget(
                      message: PositiveChatMessage(
                        text:
                            "Raconte moi ce qui se passe, et on va trouver ensemble comment changer ça",
                        isUser: false,
                        timestamp: DateTime.now(),
                      ),
                    );
                  }
                  final id = _surfaceIds[index - 1];
                  return GenUiSurface(host: conversation.host, surfaceId: id);
                },
              ),
            ),
          ),
          _ChatInputWidget(
            controller: _textController,
            isGenerating: false,
            onSendMessage: _handleSendMessage,
          ),
        ],
      ),
    );
  }

  Future<void> _handleSendMessage(String text) async {
    if (text.trim().isEmpty) return;

    // Ajouter le message utilisateur
    print("Je lance un conversation.request");
    conversation.sendRequest(UserMessage.text(text));
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
