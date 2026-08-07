// lib/models/models.dart
class WeatherSnapshot {
  final double temperatureC;
  final double windSpeed;
  final double humidityPct;
  final double precipMm;
  final String summary;
  final String? timestamp;

  const WeatherSnapshot({
    required this.temperatureC,
    required this.windSpeed,
    required this.humidityPct,
    required this.precipMm,
    required this.summary,
    this.timestamp,
  });

  factory WeatherSnapshot.fromJson(Map<String, dynamic> json) {
    return WeatherSnapshot(
      temperatureC: (json['temperature_c'] ?? 0).toDouble(),
      windSpeed: (json['wind_speed'] ?? 0).toDouble(),
      humidityPct: (json['humidity_pct'] ?? 0).toDouble(),
      precipMm: (json['precip_mm'] ?? 0).toDouble(),
      summary: json['summary'] ?? 'Field conditions',
      timestamp: json['timestamp'],
    );
  }
}

class CropResult {
  final String plant;
  final double score;
  final double expectedProfit;
  final double projectedYield;
  final double weatherSuitability;
  final double timingSuitability;
  final String reasonForDemand;
  final String projectionSummary;
  final String scenarioImageUrl;
  final int imageStage;
  final String imageStageLabel;

  CropResult({
    required this.plant,
    required this.score,
    required this.expectedProfit,
    required this.projectedYield,
    required this.weatherSuitability,
    required this.timingSuitability,
    required this.reasonForDemand,
    required this.projectionSummary,
    required this.scenarioImageUrl,
    required this.imageStage,
    required this.imageStageLabel,
  });

  factory CropResult.fromJson(Map<String, dynamic> json) {
    return CropResult(
      plant: json['plant'] ?? '',
      score: (json['score'] ?? 0).toDouble(),
      expectedProfit: (json['expected_profit'] ?? 0).toDouble(),
      projectedYield: (json['projected_yield'] ?? 0).toDouble(),
      weatherSuitability: (json['weather_suitability'] ?? 0).toDouble(),
      timingSuitability: (json['timing_suitability'] ?? 0).toDouble(),
      reasonForDemand: json['reason_for_demand'] ?? '',
      projectionSummary: json['projection_summary'] ?? '',
      scenarioImageUrl: json['scenario_image_url'] ?? '',
      imageStage: json['image_stage'] ?? 3,
      imageStageLabel: json['image_stage_label'] ?? 'Normal',
    );
  }
}

class RecommendResponse {
  final String detectedSoil;
  final double soilConfidence;
  final WeatherSnapshot? weather;
  final List<CropResult> top3;

  RecommendResponse({
    required this.detectedSoil,
    required this.soilConfidence,
    required this.weather,
    required this.top3,
  });

  factory RecommendResponse.fromJson(Map<String, dynamic> json) {
    final top3Json = (json['top3'] as List? ?? [])
        .map((e) => CropResult.fromJson(e as Map<String, dynamic>))
        .toList();

    return RecommendResponse(
      detectedSoil: json['detected_soil'] ?? 'Unknown Soil',
      soilConfidence: (json['soil_confidence'] ?? 0).toDouble(),
      weather: json['weather'] != null
          ? WeatherSnapshot.fromJson(json['weather'])
          : null,
      top3: top3Json,
    );
  }
}

class StateDistrict {
  final String state;
  final List<String> districts;

  StateDistrict({required this.state, required this.districts});

  factory StateDistrict.fromJson(Map<String, dynamic> json) {
    return StateDistrict(
      state: json['state'] ?? '',
      districts: (json['districts'] as List? ?? [])
          .map((e) => e.toString())
          .toList(),
    );
  }
}

class LocationCatalog {
  final List<StateDistrict> states;
  final List<String> crops;

  LocationCatalog({required this.states, required this.crops});

  factory LocationCatalog.fromJson(Map<String, dynamic> json) {
    return LocationCatalog(
      states: (json['states'] as List? ?? [])
          .map((e) => StateDistrict.fromJson(e))
          .toList(),
      crops: (json['crops'] as List? ?? [])
          .map((e) => e.toString())
          .toList(),
    );
  }
}

class CropInsight {
  final String crop;
  final double score;
  final double expectedProfit;
  final String reasonForDemand;
  final double growthScore;
  final double demandLevel;
  final double priceIndex;
  final String scenarioImageUrl;
  final int imageStage;
  final String imageStageLabel;

  CropInsight({
    required this.crop,
    required this.score,
    required this.expectedProfit,
    required this.reasonForDemand,
    required this.growthScore,
    required this.demandLevel,
    required this.priceIndex,
    required this.scenarioImageUrl,
    required this.imageStage,
    required this.imageStageLabel,
  });

  factory CropInsight.fromJson(Map<String, dynamic> json) {
    return CropInsight(
      crop: json['crop'] ?? '',
      score: (json['score'] ?? 0).toDouble(),
      expectedProfit: (json['expected_profit'] ?? 0).toDouble(),
      reasonForDemand: json['reason_for_demand'] ?? '',
      growthScore: (json['growth_score'] ?? 0).toDouble(),
      demandLevel: (json['demand_level'] ?? 0).toDouble(),
      priceIndex: (json['price_index'] ?? 0).toDouble(),
      scenarioImageUrl: json['scenario_image_url'] ?? '',
      imageStage: json['image_stage'] ?? 3,
      imageStageLabel: json['image_stage_label'] ?? 'Normal',
    );
  }
}

class DeviceLocation {
  final double latitude;
  final double longitude;
  final String? state;
  final String? district;
  final String? locality;

  const DeviceLocation({
    required this.latitude,
    required this.longitude,
    this.state,
    this.district,
    this.locality,
  });
}