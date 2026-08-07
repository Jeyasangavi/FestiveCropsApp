import 'package:flutter/material.dart';
import '../models/models.dart';
import '../widgets/projected_outcome_card.dart';

class ResultScreen extends StatelessWidget {
  final RecommendResponse response;
  const ResultScreen({super.key, required this.response});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Crop Recommendations"),
        backgroundColor: Colors.green.shade700,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SoilSummary(
              soil: response.detectedSoil,
              confidence: response.soilConfidence,
            ),
            if (response.weather != null) ...[
              const SizedBox(height: 12),
              _WeatherCard(weather: response.weather!),
            ],
            const SizedBox(height: 20),
            const Text(
              "Top Recommended Crops",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ...response.top3.asMap().entries.map(
              (entry) => ProjectedOutcomeCard(
                crop: entry.value,
                rank: entry.key + 1,
                weather: response.weather,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SoilSummary extends StatelessWidget {
  final String soil;
  final double confidence;
  const _SoilSummary({required this.soil, required this.confidence});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.brown.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.landscape, color: Colors.brown, size: 32),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  soil,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text("Confidence ${(confidence * 100).toStringAsFixed(1)}%"),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _WeatherCard extends StatelessWidget {
  final WeatherSnapshot weather;
  const _WeatherCard({required this.weather});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.cloud, color: Colors.blue.shade700, size: 32),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    weather.summary,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Temp ${weather.temperatureC.toStringAsFixed(1)}°C  |  Humidity ${weather.humidityPct.toStringAsFixed(0)}%",
                  ),
                  Text(
                    "Wind ${weather.windSpeed.toStringAsFixed(1)} m/s  •  Rain ${weather.precipMm.toStringAsFixed(1)} mm",
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
