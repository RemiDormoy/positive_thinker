class WeatherActivityService {
  Future<List<String>> getSuggestedActivities(
    String weatherDescription,
    double temperatureMin,
    double temperatureMax,
  ) async {
    // Simuler un délai d'API (optionnel)
    await Future.delayed(const Duration(milliseconds: 300));
    
    // Logique basée sur la description météo
    switch (weatherDescription.toLowerCase()) {
      case 'ciel dégagé':
        return _getSunnyActivities(temperatureMin, temperatureMax);
      
      case 'partiellement nuageux':
        return _getPartlyCloudyActivities(temperatureMin, temperatureMax);
      
      case 'pluie':
      case 'averses de pluie':
        return _getRainyActivities(temperatureMin, temperatureMax);
      
      case 'neige':
      case 'averses de neige':
        return _getSnowyActivities(temperatureMin, temperatureMax);
      
      case 'brouillard':
        return _getFoggyActivities(temperatureMin, temperatureMax);
      
      case 'orage':
      case 'orage avec grêle':
        return _getStormyActivities(temperatureMin, temperatureMax);
      
      default:
        return _getDefaultActivities(temperatureMin, temperatureMax);
    }
  }
  
  List<String> _getSunnyActivities(double tempMin, double tempMax) {
    if (tempMax > 25) {
      return [
        '🌞 Promenade au soleil',
        '🚴‍♀️ Balade à vélo',
        '🧺 Pique-nique au parc',
        '🏊‍♀️ Baignade ou piscine',
        '📚 Lecture en terrasse',
      ];
    } else if (tempMax > 15) {
      return [
        '🌞 Promenade au soleil',
        '🚴‍♀️ Balade à vélo',
        '🧺 Pique-nique au parc',
        '📚 Lecture en terrasse',
      ];
    } else {
      return [
        '🌞 Promenade matinale',
        '☕ Café au soleil',
        '📚 Lecture près d\'une fenêtre',
        '🧥 Sortie bien emmitouflé',
      ];
    }
  }
  
  List<String> _getPartlyCloudyActivities(double tempMin, double tempMax) {
    if (tempMax > 20) {
      return [
        '🚶‍♀️ Promenade tranquille',
        '☕ Café en terrasse couverte',
        '🎨 Dessin en plein air',
        '🌸 Visite d\'un jardin',
      ];
    } else {
      return [
        '🚶‍♀️ Promenade tranquille',
        '☕ Café en intérieur près d\'une fenêtre',
        '🎨 Activité créative',
        '📚 Lecture confortable',
      ];
    }
  }
  
  List<String> _getRainyActivities(double tempMin, double tempMax) {
    if (tempMax > 15) {
      return [
        '☔ Promenade sous la pluie avec un parapluie',
        '📖 Lecture douillette',
        '🎵 Écouter la pluie tomber',
        '☕ Boisson chaude réconfortante',
        '🎬 Film ou série cosy',
      ];
    } else {
      return [
        '📖 Lecture au chaud',
        '🎵 Musique relaxante',
        '☕ Thé ou chocolat chaud',
        '🧶 Activité manuelle créative',
        '🎬 Cinéma à la maison',
      ];
    }
  }
  
  List<String> _getSnowyActivities(double tempMin, double tempMax) {
    return [
      '❄️ Admirer la neige depuis l\'intérieur',
      '☕ Chocolat chaud près du chauffage',
      '📖 Lecture au coin du feu',
      '🧶 Tricot ou activité manuelle',
      '⛄ Construction de bonhomme de neige (si sûr)',
    ];
  }
  
  List<String> _getFoggyActivities(double tempMin, double tempMax) {
    return [
      '🌫️ Contemplation mystique du brouillard',
      '☕ Boisson chaude apaisante',
      '📖 Lecture atmosphérique',
      '🧘‍♀️ Méditation et introspection',
      '🎨 Activité créative inspirée',
    ];
  }
  
  List<String> _getStormyActivities(double tempMin, double tempMax) {
    return [
      '⛈️ Observer l\'orage en sécurité',
      '📖 Lecture captivante à l\'intérieur',
      '🎵 Musique pour couvrir le tonnerre',
      '☕ Boisson réconfortante',
      '🧘‍♀️ Méditation et relaxation',
    ];
  }
  
  List<String> _getDefaultActivities(double tempMin, double tempMax) {
    if (tempMax > 20) {
      return [
        '🌤️ Activités de plein air',
        '☕ Pause café agréable',
        '📚 Moment lecture',
        '🧘‍♀️ Méditation en nature',
      ];
    } else {
      return [
        '🏠 Activités à l\'intérieur',
        '📚 Moment lecture',
        '🧘‍♀️ Méditation',
        '☕ Pause détente',
      ];
    }
  }
}
