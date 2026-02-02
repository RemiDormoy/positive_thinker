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
      final String jsonString = await rootBundle.loadString('assets/activites.json');
      final List<dynamic> jsonData = json.decode(jsonString);
      _listeActivites = jsonData.map((json) => Activite.fromJson(json)).toList();
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
    final activitesString = activites.map((a) => 
        '- ${a.titre}: ${a.description} (${a.conditions})'
    ).join('\n');

    final prompt = """ 
    Il fait entre ${temperatureMin.round()}°C er ${temperatureMax.round()}°C aujourd'hui. Et le temps est à $weatherDescription.
    Choisit moi entre 1 et 3 activités à faire aujourd'hui parmis la liste suivante: 
    
    $activitesString
    
    Ne renvoie que le titre des activités, et rien d'autre. Juste le titre des activités. 
    """;
    return [await geminiNanoService.generateResponse(prompt)];
  }
}
