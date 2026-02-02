import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:positive_thinker/gemini_nano_service.dart';
import '../models/activite.dart';

class WeatherActivityService {
  List<Activite>? _listeActivites;

  Future<List<Activite>> get listeActivites async {
    if (_listeActivites != null) {
      return _listeActivites!;
    }

    try {
      final String jsonString = await rootBundle.loadString(
        'assets/activites.json',
      );
      final List<dynamic> jsonData = json.decode(jsonString);
      _listeActivites = jsonData
          .map((json) => Activite.fromJson(json))
          .toList();
      return _listeActivites!;
    } catch (e) {
      throw Exception('Erreur lors du chargement des activités: $e');
    }
  }

  Future<List<ActiviteSuggestion>> getSuggestedActivities(
    String weatherDescription,
    double temperatureMin,
    double temperatureMax,
  ) async {
    final geminiNanoService = GeminiNanoService();
    await geminiNanoService.initialize();

    final activites = await listeActivites;
    final activitesString = activites
        .map((a) => '- ${a.titre}: ${a.description} (${a.conditions})')
        .join('\n');

    final prompt =
        """ 
    Il fait entre ${temperatureMin.round()}°C er ${temperatureMax.round()}°C aujourd'hui. Et le temps est à $weatherDescription.
    Choisit moi entre 1 et 3 activités à faire aujourd'hui parmis la liste suivante: 
    
    $activitesString
    
    Pour chaque activité choisie, je voudrais que tu précises en une phrase pourquoi la météo pousse à faire cette activité.
     
    Je voudrais que tu renvoie la liste au format JSON suivant :  
    [{
      "titre": titre tel que présent dans la liste en entrée,
      "description": description tel que présent dans la liste en entrée,
      "explication": explication par rapport à la météo
    },
    ...
    ]
    Ne renvoie que le JSON, pour que je puisse le déserialiser. Rien d'autre que le JSON
    """;
    
    final response = await geminiNanoService.generateResponse(prompt);
    
    try {
      // Nettoyer la réponse pour extraire uniquement le JSON
      final cleanedResponse = _cleanJsonResponse(response);
      
      // Parser la réponse JSON nettoyée
      final List<dynamic> jsonList = json.decode(cleanedResponse);
      return jsonList.map((json) => ActiviteSuggestion(
        titre: json['titre'] as String,
        description: json['description'] as String,
        explication: json['explication'] as String,
      )).toList();
    } catch (e) {
      // En cas d'erreur de parsing, retourner une activité par défaut
      return [
        ActiviteSuggestion(
          titre: "Activité par défaut",
          description: "Une activité adaptée au temps",
          explication: "Suggestion par défaut en cas d'erreur: $response",
        ),
      ];
    }
  }
  
  String _cleanJsonResponse(String response) {
    // Trouver le premier "[" et le dernier "]"
    final firstBracket = response.indexOf('[');
    final lastBracket = response.lastIndexOf(']');
    
    // Si on ne trouve pas les crochets, retourner la réponse telle quelle
    if (firstBracket == -1 || lastBracket == -1 || firstBracket >= lastBracket) {
      return response;
    }
    
    // Extraire uniquement la partie JSON entre les crochets (inclus)
    return response.substring(firstBracket, lastBracket + 1);
  }
}

class ActiviteSuggestion {
  final String titre;
  final String description;
  final String explication;

  ActiviteSuggestion({
    required this.titre,
    required this.description,
    required this.explication,
  });
}
