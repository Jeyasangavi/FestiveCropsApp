// lib/services/api_service.dart
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../models/models.dart';
import 'dart:convert';

class ApiService {
  static const String baseUrl = "http://10.0.2.2:8000"; // Android emulator
  // For real device on same WiFi → use your PC IP: http://192.168.x.x:8000

  static String mediaUrl(String relativePath) {
    if (relativePath.isEmpty) return relativePath;
    if (relativePath.startsWith("http")) return relativePath;
    return "$baseUrl$relativePath";
  }

  static Future<RecommendResponse> getRecommendations({
    required String state,
    String? district,
    required String dateIso,
    Uint8List? imageBytes,
    double? latitude,
    double? longitude,
  }) async {
    final uri = Uri.parse("$baseUrl/recommend");

    var request = http.MultipartRequest('POST', uri)
      ..fields['state'] = state
      ..fields['district'] = district ?? ''
      ..fields['date_iso'] = dateIso;

    if (latitude != null) {
      request.fields['latitude'] = latitude.toString();
    }
    if (longitude != null) {
      request.fields['longitude'] = longitude.toString();
    }

    if (imageBytes != null && imageBytes.isNotEmpty) {
      request.files.add(http.MultipartFile.fromBytes(
        'image',
        imageBytes,
        filename: 'soil.jpg',
      ));
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return RecommendResponse.fromJson(json);
    } else {
      throw Exception("Server error: ${response.statusCode}\n${response.body}");
    }
  }

  static Future<LocationCatalog> fetchLocations() async {
    final uri = Uri.parse("$baseUrl/locations");
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      return LocationCatalog.fromJson(jsonDecode(response.body));
    }
    throw Exception("Failed to load location index");
  }

  static Future<CropInsight> getCropInsight({
    required String crop,
    String? state,
    String? district,
  }) async {
    final params = {
      'crop': crop,
      if (state != null && state.isNotEmpty) 'state': state,
      if (district != null && district.isNotEmpty) 'district': district,
    };
    final uri = Uri.parse("$baseUrl/crop-insight").replace(queryParameters: params);
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      return CropInsight.fromJson(jsonDecode(response.body));
    }
    throw Exception(
      "Unable to fetch insight: ${response.statusCode}",
    );
  }
}