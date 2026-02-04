import 'package:flutter/material.dart';
import 'package:positive_thinker/models/activite_suggestion.dart';
import 'package:positive_thinker/services/gemini_nano_service_with_metrics.dart';
import 'package:positive_thinker/widgets/performance_metrics_widget.dart';

import '../models/weather_data.dart';
import '../services/weather_activity_service.dart';
import '../services/weather_service.dart';

class WeatherActivityPage extends StatefulWidget {
  const WeatherActivityPage({super.key});

  @override
  State<WeatherActivityPage> createState() => _WeatherActivityPageState();
}

class _WeatherActivityPageState extends State<WeatherActivityPage> {
  final WeatherService _weatherService = WeatherService();
  final GeminiNanoServiceWithMetrics _geminiNanoServiceWithMetrics = GeminiNanoServiceWithMetrics();
  Future<WeatherData>? _weatherFuture;
  bool _isEditingWeather = false;
  WeatherData? _customWeatherData;

  @override
  void initState() {
    super.initState();
    _weatherFuture = _weatherService.fetchWeatherData();
    _geminiNanoServiceWithMetrics.initialize();
  }

  void _refreshWeather() {
    setState(() {
      _weatherFuture = _weatherService.fetchWeatherData();
      _customWeatherData = null;
    });
  }

  void _toggleWeatherEdit() {
    setState(() {
      _isEditingWeather = !_isEditingWeather;
    });
  }

  void _applyCustomWeather(String weatherDescription, double temperature) {
    setState(() {
      _customWeatherData = WeatherData(
        temperatureMax: temperature,
        temperatureMin: temperature,
        weatherCode: _getWeatherCodeFromDescription(weatherDescription),
        date: DateTime.now().toString().split(' ')[0],
      );
      _isEditingWeather = false;
    });
  }

  int _getWeatherCodeFromDescription(String description) {
    switch (description.toLowerCase()) {
      case 'ciel dégagé':
        return 0;
      case 'partiellement nuageux':
        return 2;
      case 'pluie':
        return 63;
      case 'neige':
        return 73;
      case 'brouillard':
        return 45;
      case 'orage':
        return 95;
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Regarde comme il fait beau dehors',
          style: TextStyle(color: Color(0xFF8B4513), fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFFF5E6D3),
        iconTheme: const IconThemeData(color: Color(0xFF8B4513)),
        elevation: 0,
        actions: [
          IconButton(icon: Icon(_isEditingWeather ? Icons.close : Icons.edit), onPressed: _toggleWeatherEdit),
          if (!_isEditingWeather) IconButton(icon: const Icon(Icons.refresh), onPressed: _refreshWeather),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF5E6D3), Color(0xFFE8B4A0)],
          ),
        ),
        child: _isEditingWeather
            ? _WeatherEditForm(onApply: _applyCustomWeather)
            : FutureBuilder<WeatherData>(
                future: _weatherFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const _LoadingWidget();
                  }

                  if (snapshot.hasError) {
                    return _ErrorWidget(error: snapshot.error.toString(), onRetry: _refreshWeather);
                  }

                  if (!snapshot.hasData) {
                    return const _EmptyStateWidget();
                  }

                  final weatherToUse = _customWeatherData ?? snapshot.data!;
                  return _WeatherContent(
                    weatherData: weatherToUse,
                    geminiNanoServiceWithMetrics: _geminiNanoServiceWithMetrics,
                  );
                },
              ),
      ),
    );
  }
}

class _WeatherContent extends StatelessWidget {
  final WeatherData weatherData;
  final GeminiNanoServiceWithMetrics geminiNanoServiceWithMetrics;

  const _WeatherContent({required this.weatherData, required this.geminiNanoServiceWithMetrics});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          const SizedBox(height: 20),

          PerformanceMetricsWidget(tracker: geminiNanoServiceWithMetrics.tracker),

          const SizedBox(height: 20),

          _MainWeatherCard(weatherData: weatherData),

          const SizedBox(height: 30),

          _ActivitySuggestionsWidget(
            weatherData: weatherData,
            geminiNanoServiceWithMetrics: geminiNanoServiceWithMetrics,
          ),

          const SizedBox(height: 30),

          _MotivationalMessageWidget(weatherData: weatherData),
        ],
      ),
    );
  }
}

class _MainWeatherCard extends StatelessWidget {
  final WeatherData weatherData;

  const _MainWeatherCard({required this.weatherData});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 8,
      child: Container(
        padding: const EdgeInsets.all(32.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, Color(0xFFF8F8F8)],
          ),
        ),
        child: Column(
          children: [
            // Emoji et description météo
            Text(weatherData.weatherEmoji, style: const TextStyle(fontSize: 80)),

            const SizedBox(height: 16),

            Text(
              weatherData.weatherDescription,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF8B4513)),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 24),

            // Températures
            _TemperatureRow(weatherData: weatherData),
          ],
        ),
      ),
    );
  }
}

class _TemperatureRow extends StatelessWidget {
  final WeatherData weatherData;

  const _TemperatureRow({required this.weatherData});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _TemperatureWidget(
          label: 'Min',
          temperature: weatherData.temperatureMin,
          icon: Icons.thermostat,
          color: Colors.blue,
        ),
        Container(height: 60, width: 2, color: const Color(0xFFE0E0E0)),
        _TemperatureWidget(
          label: 'Max',
          temperature: weatherData.temperatureMax,
          icon: Icons.wb_sunny,
          color: Colors.orange,
        ),
      ],
    );
  }
}

class _TemperatureWidget extends StatelessWidget {
  final String label;
  final double temperature;
  final IconData icon;
  final Color color;

  const _TemperatureWidget({required this.label, required this.temperature, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 16, color: Color(0xFF8B4513), fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 4),
        Text(
          '${temperature.round()}°C',
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF8B4513)),
        ),
      ],
    );
  }
}

class _ActivitySuggestionsWidget extends StatelessWidget {
  final WeatherData weatherData;
  final GeminiNanoServiceWithMetrics geminiNanoServiceWithMetrics;

  const _ActivitySuggestionsWidget({required this.weatherData, required this.geminiNanoServiceWithMetrics});

  @override
  Widget build(BuildContext context) {
    final weatherActivityService = WeatherActivityService(geminiNanoService: geminiNanoServiceWithMetrics);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Container(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              '✨ Activités suggérées',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF8B4513)),
            ),

            const SizedBox(height: 16),

            FutureBuilder<List<ActiviteSuggestion>>(
              future: weatherActivityService.getSuggestedActivities(
                weatherData.weatherDescription,
                weatherData.temperatureMin,
                weatherData.temperatureMax,
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8B4513))),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Container(
                    padding: const EdgeInsets.all(16.0),
                    child: const Text(
                      'Erreur lors du chargement des activités',
                      style: TextStyle(fontSize: 14, color: Color(0xFF8B4513), fontStyle: FontStyle.italic),
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(16.0),
                    child: const Text(
                      'Aucune activité disponible pour le moment',
                      style: TextStyle(fontSize: 14, color: Color(0xFF8B4513), fontStyle: FontStyle.italic),
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                return Column(
                  children: [
                    ...snapshot.data!.map((activity) => _ActivitySuggestionItem(activiteSuggestion: activity)).toList(),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivitySuggestionItem extends StatelessWidget {
  final ActiviteSuggestion activiteSuggestion;

  const _ActivitySuggestionItem({required this.activiteSuggestion});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5E6D3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD2691E), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(color: Color(0xFFD2691E), shape: BoxShape.circle),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  activiteSuggestion.titre,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF8B4513)),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Text(
            activiteSuggestion.description,
            style: const TextStyle(fontSize: 14, color: Color(0xFF8B4513), height: 1.4),
          ),

          const SizedBox(height: 8),

          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: const Color(0xFFFFE4B5), borderRadius: BorderRadius.circular(8)),
            child: Row(
              children: [
                const Icon(Icons.lightbulb_outline, size: 16, color: Color(0xFFD2691E)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    activiteSuggestion.explication,
                    style: const TextStyle(fontSize: 13, color: Color(0xFF8B4513), fontStyle: FontStyle.italic),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MotivationalMessageWidget extends StatelessWidget {
  final WeatherData weatherData;

  const _MotivationalMessageWidget({required this.weatherData});

  String _getMotivationalMessage() {
    switch (weatherData.weatherCode) {
      case 0: // Ciel dégagé
        return 'Le soleil brille aujourd\'hui, tout comme votre potentiel ! ☀️\nProfitez de cette belle journée pour faire le plein d\'énergie positive.';
      case 1:
      case 2:
      case 3: // Partiellement nuageux
        return 'Entre les nuages, le soleil trouve toujours son chemin ⛅\nComme vous, qui savez trouver la beauté même dans les moments mitigés.';
      case 61:
      case 63:
      case 65: // Pluie
        return 'La pluie nourrit la terre pour faire pousser de belles choses 🌧️\nTout comme les défis nourrissent votre croissance personnelle.';
      default:
        return 'Chaque temps a sa beauté et chaque jour ses opportunités 🌤️\nVotre attitude positive peut illuminer n\'importe quelle journée !';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Container(
        padding: const EdgeInsets.all(24.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFFE4B5), Color(0xFFFFF8DC)],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.favorite, color: Color(0xFFD2691E), size: 32),

            const SizedBox(height: 16),

            Text(
              _getMotivationalMessage(),
              style: const TextStyle(fontSize: 16, color: Color(0xFF8B4513), height: 1.5, fontStyle: FontStyle.italic),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadingWidget extends StatelessWidget {
  const _LoadingWidget();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8B4513))),
          SizedBox(height: 16),
          Text('Récupération de la météo...', style: TextStyle(fontSize: 16, color: Color(0xFF8B4513))),
        ],
      ),
    );
  }
}

class _ErrorWidget extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const _ErrorWidget({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off, size: 64, color: Color(0xFF8B4513)),

            const SizedBox(height: 16),

            const Text(
              'Oops ! Impossible de récupérer la météo',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF8B4513)),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 8),

            const Text(
              'Vérifiez votre connexion internet et réessayez.',
              style: TextStyle(fontSize: 14, color: Color(0xFF8B4513)),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 24),

            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD2691E),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyStateWidget extends StatelessWidget {
  const _EmptyStateWidget();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.wb_cloudy_outlined, size: 64, color: Color(0xFF8B4513)),
            SizedBox(height: 16),
            Text(
              'Aucune donnée météo disponible',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF8B4513)),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              'Revenez plus tard pour découvrir le temps qu\'il fait !',
              style: TextStyle(fontSize: 14, color: Color(0xFF8B4513)),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _WeatherEditForm extends StatefulWidget {
  final Function(String weatherDescription, double temperature) onApply;

  const _WeatherEditForm({required this.onApply});

  @override
  State<_WeatherEditForm> createState() => _WeatherEditFormState();
}

class _WeatherEditFormState extends State<_WeatherEditForm> {
  String _selectedWeather = 'Ciel dégagé';
  double _temperature = 20.0;

  final List<String> _weatherOptions = [
    'Ciel dégagé',
    'Partiellement nuageux',
    'Pluie',
    'Neige',
    'Brouillard',
    'Orage',
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          const SizedBox(height: 40),

          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            elevation: 8,
            child: Container(
              padding: const EdgeInsets.all(32.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.white, Color(0xFFF8F8F8)],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.tune, size: 48, color: Color(0xFF8B4513)),

                  const SizedBox(height: 16),

                  const Text(
                    'Personnaliser la météo',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF8B4513)),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 32),

                  // Sélecteur de météo
                  const Text(
                    'Type de météo',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF8B4513)),
                  ),

                  const SizedBox(height: 12),

                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFD2691E), width: 2),
                      borderRadius: BorderRadius.circular(12),
                      color: const Color(0xFFF5E6D3),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedWeather,
                        isExpanded: true,
                        style: const TextStyle(fontSize: 16, color: Color(0xFF8B4513)),
                        dropdownColor: const Color(0xFFF5E6D3),
                        icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF8B4513)),
                        items: _weatherOptions.map((String weather) {
                          return DropdownMenuItem<String>(value: weather, child: Text(weather));
                        }).toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setState(() {
                              _selectedWeather = newValue;
                            });
                          }
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Sélecteur de température
                  const Text(
                    'Température',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF8B4513)),
                  ),

                  const SizedBox(height: 12),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFD2691E), width: 2),
                      borderRadius: BorderRadius.circular(12),
                      color: const Color(0xFFF5E6D3),
                    ),
                    child: Column(
                      children: [
                        Text(
                          '${_temperature.round()}°C',
                          style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF8B4513)),
                        ),

                        const SizedBox(height: 16),

                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            activeTrackColor: const Color(0xFFD2691E),
                            inactiveTrackColor: const Color(0xFFD2691E).withValues(alpha: 0.3),
                            thumbColor: const Color(0xFF8B4513),
                            overlayColor: const Color(0xFFD2691E).withValues(alpha: 0.2),
                            valueIndicatorColor: const Color(0xFF8B4513),
                            valueIndicatorTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                          child: Slider(
                            value: _temperature,
                            min: -10,
                            max: 40,
                            divisions: 50,
                            label: '${_temperature.round()}°C',
                            onChanged: (double value) {
                              setState(() {
                                _temperature = value;
                              });
                            },
                          ),
                        ),

                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('-10°C', style: TextStyle(fontSize: 12, color: Color(0xFF8B4513))),
                            Text('40°C', style: TextStyle(fontSize: 12, color: Color(0xFF8B4513))),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Bouton Valider
                  ElevatedButton.icon(
                    onPressed: () {
                      widget.onApply(_selectedWeather, _temperature);
                    },
                    icon: const Icon(Icons.check),
                    label: const Text(
                      'Valider et générer les suggestions',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD2691E),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
