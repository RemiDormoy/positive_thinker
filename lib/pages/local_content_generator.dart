part of 'positive_activities_page.dart';

class LocalContentGenerator implements ContentGenerator {
  @override
  Stream<A2uiMessage> get a2uiMessageStream => throw UnimplementedError();

  @override
  void dispose() {

  }

  @override
  Stream<ContentGeneratorError> get errorStream => throw UnimplementedError();

  @override
  ValueListenable<bool> get isProcessing => throw UnimplementedError();

  @override
  Future<void> sendRequest(ChatMessage message, {Iterable<ChatMessage>? history, A2UiClientCapabilities? clientCapabilities}) {
    throw UnimplementedError();
  }

  @override
  Stream<String> get textResponseStream => throw UnimplementedError();

}
