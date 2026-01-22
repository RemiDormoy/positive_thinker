class GuardianArticleDetail {
  final String id;
  final String webTitle;
  final String webUrl;
  final String apiUrl;
  final String webPublicationDate;
  final String sectionName;
  final String headline;
  final String standfirst;
  final String bodyText;
  final String byline;
  final String thumbnail;

  GuardianArticleDetail({
    required this.id,
    required this.webTitle,
    required this.webUrl,
    required this.apiUrl,
    required this.webPublicationDate,
    required this.sectionName,
    required this.headline,
    required this.standfirst,
    required this.bodyText,
    required this.byline,
    required this.thumbnail,
  });

  factory GuardianArticleDetail.fromJson(Map<String, dynamic> json) {
    final content = json['content'] as Map<String, dynamic>? ?? {};
    final fields = content['fields'] as Map<String, dynamic>? ?? {};
    
    return GuardianArticleDetail(
      id: content['id'] ?? '',
      webTitle: content['webTitle'] ?? '',
      webUrl: content['webUrl'] ?? '',
      apiUrl: content['apiUrl'] ?? '',
      webPublicationDate: content['webPublicationDate'] ?? '',
      sectionName: content['sectionName'] ?? '',
      headline: fields['headline'] ?? content['webTitle'] ?? '',
      standfirst: fields['standfirst'] ?? '',
      bodyText: fields['bodyText'] ?? '',
      byline: fields['byline'] ?? '',
      thumbnail: fields['thumbnail'] ?? '',
    );
  }
}

class GuardianArticleDetailResponse {
  final GuardianArticleDetail content;

  GuardianArticleDetailResponse({required this.content});

  factory GuardianArticleDetailResponse.fromJson(Map<String, dynamic> json) {
    final response = json['response'] as Map<String, dynamic>;
    return GuardianArticleDetailResponse(
      content: GuardianArticleDetail.fromJson(response),
    );
  }
}
