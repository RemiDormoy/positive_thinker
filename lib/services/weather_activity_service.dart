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

  Future<List<String>> getSuggestedActivities(
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
    return [await geminiNanoService.generateResponse(prompt)];
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
