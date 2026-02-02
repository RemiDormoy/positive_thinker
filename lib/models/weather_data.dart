class WeatherData {
  final double temperatureMax;
  final double temperatureMin;
  final int weatherCode;
  final String date;

  const WeatherData({
    required this.temperatureMax,
    required this.temperatureMin,
    required this.weatherCode,
    required this.date,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    final daily = json['daily'];
    return WeatherData(
      temperatureMax: daily['temperature_2m_max'][0].toDouble(),
      temperatureMin: daily['temperature_2m_min'][0].toDouble(),
      weatherCode: daily['weather_code'][0],
      date: daily['time'][0],
    );
  }

  String get weatherDescription {
    switch (weatherCode) {
      case 0:
        return 'Ciel dégagé';
      case 1:
      case 2:
      case 3:
        return 'Partiellement nuageux';
      case 45:
      case 48:
        return 'Brouillard';
      case 51:
      case 53:
      case 55:
        return 'Bruine légère';
      case 61:
      case 63:
      case 65:
        return 'Pluie';
      case 71:
      case 73:
      case 75:
        return 'Neige';
      case 77:
        return 'Grains de neige';
      case 80:
      case 81:
      case 82:
        return 'Averses de pluie';
      case 85:
      case 86:
        return 'Averses de neige';
      case 95:
        return 'Orage';
      case 96:
      case 99:
        return 'Orage avec grêle';
      default:
        return 'Météo inconnue';
    }
  }

  String get weatherEmoji {
    switch (weatherCode) {
      case 0:
        return '☀️';
      case 1:
      case 2:
      case 3:
        return '⛅';
      case 45:
      case 48:
        return '🌫️';
      case 51:
      case 53:
      case 55:
        return '🌦️';
      case 61:
      case 63:
      case 65:
        return '🌧️';
      case 71:
      case 73:
      case 75:
        return '❄️';
      case 77:
        return '🌨️';
      case 80:
      case 81:
      case 82:
        return '🌦️';
      case 85:
      case 86:
        return '🌨️';
      case 95:
        return '⛈️';
      case 96:
      case 99:
        return '⛈️';
      default:
        return '🌤️';
    }
  }
}
