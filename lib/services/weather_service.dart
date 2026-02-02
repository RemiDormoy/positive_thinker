import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import '../models/weather_data.dart';

class WeatherService {
  static const String _baseUrl = 'https://api.open-meteo.com/v1/forecast';
  
  Future<WeatherData> fetchWeatherData() async {
    try {
      final uri = Uri.parse(
        '$_baseUrl?latitude=48.8534&longitude=2.3488&daily=weather_code,temperature_2m_max,temperature_2m_min&forecast_days=1'
      );

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final body = response.body;
        final weatherJson = json.decode(body);
        return WeatherData.fromJson(weatherJson);
      } else {
        debugPrint('Failed to load weather data: ${response.statusCode}');
        throw Exception('Failed to load weather data: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Failed to load weather data: $e');
      throw Exception('Error fetching weather data: $e');
    }
  }
}
