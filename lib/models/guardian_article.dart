class GuardianArticle {
  final String id;
  final String webTitle;
  final String webUrl;
  final String apiUrl;
  final String webPublicationDate;
  final String sectionName;

  GuardianArticle({
    required this.id,
    required this.webTitle,
    required this.webUrl,
    required this.apiUrl,
    required this.webPublicationDate,
    required this.sectionName,
  });

  factory GuardianArticle.fromJson(Map<String, dynamic> json) {
    return GuardianArticle(
      id: json['id'] ?? '',
      webTitle: json['webTitle'] ?? '',
      webUrl: json['webUrl'] ?? '',
      apiUrl: json['apiUrl'] ?? '',
      webPublicationDate: json['webPublicationDate'] ?? '',
      sectionName: json['sectionName'] ?? '',
    );
  }
}

class GuardianResponse {
  final List<GuardianArticle> results;

  GuardianResponse({required this.results});

  factory GuardianResponse.fromJson(Map<String, dynamic> json) {
    final response = json['response'] as Map<String, dynamic>;
    final results = (response['results'] as List)
        .map((article) => GuardianArticle.fromJson(article))
        .toList();

    return GuardianResponse(results: results);
  }
}
