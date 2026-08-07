import 'package:flutter/material.dart';
import '../models/models.dart';

class ResultScreen extends StatelessWidget {
  final RecommendResponse response;
  const ResultScreen({super.key, required this.response});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Results", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green.shade700,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Detected Soil
            Card(
              color: Colors.brown.shade50,
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Icon(Icons.landscape, size: 40, color: Colors.brown.shade700),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        "Detected Soil Type:\n${response.detectedSoil}",
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            const Text("Top Recommended Crops", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),

            // Top 3 Crops
            ...response.top3.asMap().entries.map((entry) {
              final crop = entry.value;
              final rank = entry.key + 1;
              final imageUrl = "http://10.0.2.2:8000${crop.imageUrl}"; // Change IP if needed

              return Card(
                margin: const EdgeInsets.only(bottom: 20),
                elevation: 6,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Column(
                  children: [
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                          child: Image.network(
                            imageUrl,
                            height: 280,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              height: 280,
                              color: Colors.grey.shade300,
                              child: const Icon(Icons.image_not_supported, size: 80),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 12,
                          left: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.green.shade700,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Text("Rank $rank", style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(crop.plant, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Text("Score: ${crop.score.toStringAsFixed(1)}", style: const TextStyle(fontSize: 16)),
                          Text("Expected Profit: ₹${crop.expectedProfit.toStringAsFixed(0)}", style: const TextStyle(fontSize: 16)),
                          const SizedBox(height: 12),
                          Text(crop.reasonForDemand, style: const TextStyle(fontSize: 15, fontStyle: FontStyle.italic, color: Colors.black87)),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}