import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../models/models.dart';

class LocationService {
  static Future<DeviceLocation?> detect() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return null;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever ||
        permission == LocationPermission.denied) {
      return null;
    }

    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    final placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );

    final place = placemarks.isNotEmpty ? placemarks.first : null;
    final state = place?.administrativeArea;
    final district = place?.subAdministrativeArea ?? place?.locality;

    return DeviceLocation(
      latitude: position.latitude,
      longitude: position.longitude,
      state: state,
      district: district,
      locality: place?.locality,
    );
  }
}

