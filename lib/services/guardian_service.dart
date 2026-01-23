import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import '../models/guardian_article.dart';
import '../models/guardian_article_detail.dart';

class GuardianService {
  static const String _baseUrl = 'https://content.guardianapis.com';
  static const String _apiKey = '9965b337-2c1f-4888-81d9-9ebbef3e63d5';

  Future<List<GuardianArticle>> fetchPositiveNews() async {
    try {
      final uri = Uri.parse(
        '$_baseUrl/search?api-key=$_apiKey&q=france'
      );

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final body = response.body;
        final guardianResponse = GuardianResponse.fromJson(
          json.decode(body)
        );
        return guardianResponse.results;
      } else {
        debugPrint('Failed to load articles: ${response.statusCode}');
        throw Exception('Failed to load articles: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Failed to load articles: $e}');
      throw Exception('Error fetching articles: $e');
    }
  }

  Future<List<GuardianArticle>> searchArticles(String query) async {
    try {
      final uri = Uri.parse(
        '$_baseUrl/search?api-key=$_apiKey&q=$query'
      );

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final body = response.body;
        final guardianResponse = GuardianResponse.fromJson(
          json.decode(body)
        );
        return guardianResponse.results;
      } else {
        debugPrint('Failed to search articles: ${response.statusCode}');
        throw Exception('Failed to search articles: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Failed to search articles: $e');
      throw Exception('Error searching articles: $e');
    }
  }

  Future<GuardianArticleDetail> fetchArticleDetail(String apiUrl) async {
    try {
      final uri = Uri.parse(
        '$apiUrl?api-key=$_apiKey&show-fields=bodyText'
      );

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final body = response.body;
        final articleDetailResponse = GuardianArticleDetailResponse.fromJson(
          json.decode(body)
        );
        return articleDetailResponse.content;
      } else {
        debugPrint('Failed to load article detail: ${response.statusCode}');
        throw Exception('Failed to load article detail: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Failed to load article detail: $e');
      throw Exception('Error fetching article detail: $e');
    }
  }
}
