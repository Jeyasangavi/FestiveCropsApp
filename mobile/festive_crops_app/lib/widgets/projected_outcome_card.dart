import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/api_service.dart';

class ProjectedOutcomeCard extends StatelessWidget {
  final CropResult crop;
  final int rank;
  final WeatherSnapshot? weather;

  const ProjectedOutcomeCard({
    super.key,
    required this.crop,
    required this.rank,
    this.weather,
  });

  Color _baseColor() {
    const palette = {
      "Banana": Colors.amber,
      "Cotton": Colors.blueGrey,
      "Groundnut": Colors.brown,
      "Marigold": Colors.orange,
      "Wheat": Colors.yellow,
      "Jasmine": Colors.pink,
      "Sugarcane": Colors.green,
      "Rice": Colors.lightGreen,
      "Turmeric": Colors.deepOrange,
      "Sesame": Colors.teal,
      "Millet": Colors.lime,
    };
    return palette[crop.plant] ?? Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    final baseColor = _baseColor();
    final imageUrl = ApiService.mediaUrl(crop.scenarioImageUrl);
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 220,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Positioned.fill(
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: baseColor.withOpacity(0.2),
                      alignment: Alignment.center,
                      child: const Icon(Icons.image_not_supported, size: 40),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.transparent, Colors.black54],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 16,
                  left: 16,
                  child: _tag("Rank $rank"),
                ),
                Positioned(
                  top: 16,
                  right: 16,
                  child: _tag("${crop.imageStageLabel} (${crop.imageStage}/5)"),
                ),
                if (weather != null)
                  Positioned(
                    bottom: 16,
                    right: 16,
                    child: _tag(
                      "${weather!.temperatureC.toStringAsFixed(1)}°C • ${weather!.summary}",
                    ),
                  ),
                Positioned(
                  left: 16,
                  bottom: 20,
                  right: 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        crop.plant,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        crop.projectionSummary,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    _pill("Score ${crop.score.toStringAsFixed(1)}", Icons.stacked_line_chart),
                    _pill("Profit ₹${crop.expectedProfit.toStringAsFixed(0)}", Icons.currency_rupee),
                    _pill("Weather +${crop.weatherSuitability.toStringAsFixed(1)}", Icons.cloud),
                    _pill("Timing ${crop.timingSuitability.toStringAsFixed(1)}", Icons.calendar_today),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  "Projected yield: ${crop.projectedYield.toStringAsFixed(0)} kg/acre",
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                Text(
                  crop.reasonForDemand,
                  style: const TextStyle(fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _pill(String label, IconData icon) {
    return Chip(
      backgroundColor: Colors.green.shade50,
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.green.shade800),
          const SizedBox(width: 4),
          Text(label),
        ],
      ),
    );
  }
}

Widget _tag(String text) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: Colors.black.withOpacity(0.65),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      text,
      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
    ),
  );
}
