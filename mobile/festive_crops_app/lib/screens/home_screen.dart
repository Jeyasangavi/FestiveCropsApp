import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import '../services/location_service.dart';
import 'result_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Uint8List? _imageBytes;
  bool _loadingRecommendations = false;
  bool _loadingCatalog = true;
  bool _detectingLocation = false;
  bool _fetchingCropInsight = false;
  String? _locationError;
  List<StateDistrict> _stateDistricts = [];
  List<String> _availableCrops = [];
  List<String> _allDistricts = [];
  String? _selectedState = "Tamil Nadu";
  String? _selectedDistrict;
  DeviceLocation? _deviceLocation;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    try {
      final catalog = await ApiService.fetchLocations();
      if (!mounted) return;
      final crops = [...catalog.crops]..sort();
      setState(() {
        _stateDistricts = catalog.states;
        _availableCrops = crops;
        _allDistricts = catalog.states
            .expand((state) => state.districts)
            .toSet()
            .toList()
          ..sort();
        _loadingCatalog = false;
      });
      await _detectLocation();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadingCatalog = false;
        _locationError = "Failed to load location catalog";
      });
    }
  }

  Future<void> _detectLocation() async {
    setState(() {
      _detectingLocation = true;
      _locationError = null;
    });
    try {
      final location = await LocationService.detect();
      if (!mounted) return;
      if (location == null) {
        setState(() {
          _locationError = "Enable location services for automatic state & district selection.";
          _detectingLocation = false;
        });
        return;
      }

      final nextState = _normalize(location.state) ?? _selectedState;
      final nextDistrict = _matchDistrict(nextState, location.district ?? location.locality);

      setState(() {
        _deviceLocation = location;
        _selectedState = nextState;
        _selectedDistrict = nextDistrict ?? _selectedDistrict;
        _detectingLocation = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _locationError = "Unable to detect location: $e";
        _detectingLocation = false;
      });
    }
  }

  String? _normalize(String? value) {
    if (value == null) return null;
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;
    return trimmed
        .split(' ')
        .where((word) => word.isNotEmpty)
        .map((word) => word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
  }

  String? _matchDistrict(String? state, String? candidate) {
    if (state == null || candidate == null) return null;
    final normalized = _normalize(candidate);
    if (normalized == null) return null;
    final districts = _districtsForState(state);
    for (final district in districts) {
      if (district.toLowerCase() == normalized.toLowerCase()) {
        return district;
      }
    }
    return null;
  }

  List<String> _districtsForState(String? state) {
    if (state == null) return _allDistricts;
    final match = _stateDistricts.firstWhere(
      (element) => element.state == state,
      orElse: () => StateDistrict(state: state, districts: _allDistricts),
    );
    return match.districts.isEmpty ? _allDistricts : match.districts;
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source, imageQuality: 80);
    if (picked != null && mounted) {
      final bytes = await picked.readAsBytes();
      setState(() => _imageBytes = bytes);
    }
  }

  Future<void> _getRecommendations() async {
    if (_selectedState == null || _selectedState!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Select a state to continue.")),
      );
      return;
    }
    setState(() => _loadingRecommendations = true);

    try {
      final response = await ApiService.getRecommendations(
        state: _selectedState!,
        district: _selectedDistrict,
        dateIso: DateTime.now().toIso8601String(),
        imageBytes: _imageBytes,
        latitude: _deviceLocation?.latitude,
        longitude: _deviceLocation?.longitude,
      );
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ResultScreen(response: response)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      if (mounted) setState(() => _loadingRecommendations = false);
    }
  }

  Future<void> _openDistrictPicker() async {
    final options = _districtsForState(_selectedState);
    final selected = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        String query = '';
        return StatefulBuilder(
          builder: (context, setModalState) {
            final filtered = options
                .where((district) => district.toLowerCase().contains(query.toLowerCase()))
                .toList();
            final height = MediaQuery.of(context).size.height * 0.7;
            return SafeArea(
              child: SizedBox(
                height: height,
                child: Padding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: TextField(
                          decoration: const InputDecoration(
                            labelText: "Search district",
                            prefixIcon: Icon(Icons.search),
                          ),
                          onChanged: (value) => setModalState(() => query = value),
                        ),
                      ),
                      Expanded(
                        child: filtered.isEmpty
                            ? const Center(child: Text("No districts match your search"))
                            : ListView.builder(
                                itemCount: filtered.length,
                                itemBuilder: (context, index) {
                                  final district = filtered[index];
                                  return ListTile(
                                    title: Text(district),
                                    onTap: () => Navigator.of(context).pop(district),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    if (selected != null && mounted) {
      setState(() => _selectedDistrict = selected);
    }
  }

  Future<void> _openCropChooser() async {
    if (_availableCrops.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Crop list not ready. Please try again shortly.")),
      );
      return;
    }

    final crop = await showModalBottomSheet<String>(
      context: context,
      builder: (context) {
        final height = MediaQuery.of(context).size.height * 0.6;
        return SafeArea(
          child: SizedBox(
            height: height,
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    "Pick a crop to grow",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: _availableCrops.length,
                    itemBuilder: (context, index) {
                      final cropName = _availableCrops[index];
                      return ListTile(
                        leading: const Icon(Icons.eco),
                        title: Text(cropName),
                        onTap: () => Navigator.of(context).pop(cropName),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (crop != null) {
      await _showCropInsight(crop);
    }
  }

  Future<void> _showCropInsight(String crop) async {
    setState(() => _fetchingCropInsight = true);
    try {
      final insight = await ApiService.getCropInsight(
        crop: crop,
        state: _selectedState,
        district: _selectedDistrict,
      );
      if (!mounted) return;
      await showModalBottomSheet(
        context: context,
        builder: (context) {
          final imageUrl = ApiService.mediaUrl(insight.scenarioImageUrl);
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (insight.scenarioImageUrl.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(
                        imageUrl,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  if (insight.scenarioImageUrl.isNotEmpty) const SizedBox(height: 12),
                  Text(
                    insight.crop,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Text("Score: ${insight.score.toStringAsFixed(1)}"),
                  Text("Expected Profit: ₹${insight.expectedProfit.toStringAsFixed(0)}"),
                  Text("Growth Score: ${insight.growthScore.toStringAsFixed(1)}"),
                  Text("Demand Level: ${insight.demandLevel.toStringAsFixed(1)}"),
                  Text("Price Index: ${insight.priceIndex.toStringAsFixed(1)}"),
                  Text("Stage: ${insight.imageStageLabel} (${insight.imageStage}/5)"),
                  const SizedBox(height: 12),
                  Text(
                    insight.reasonForDemand,
                    style: const TextStyle(fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ),
          );
        },
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Could not load crop insight: $e")),
      );
    } finally {
      if (mounted) setState(() => _fetchingCropInsight = false);
    }
  }

  Widget _buildLocationTile() {
    return Card(
      child: ListTile(
        leading: _detectingLocation
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.my_location, color: Colors.green),
        title: Text(_selectedState ?? "State pending"),
        subtitle: Text(
          _selectedDistrict ?? "Tap to pick district",
        ),
        trailing: IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: _loadingCatalog ? null : _detectLocation,
        ),
        onTap: _openDistrictPicker,
      ),
    );
  }

  Widget _buildStateDropdown() {
    if (_stateDistricts.isEmpty) {
      return TextFormField(
        readOnly: true,
        decoration: InputDecoration(
          labelText: "State",
          hintText: _selectedState ?? "Loading states...",
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
    final values = _stateDistricts.map((e) => e.state).toList();
    final dropdownValue = values.contains(_selectedState) ? _selectedState : values.first;
    if (dropdownValue != _selectedState) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _selectedState = dropdownValue;
            _selectedDistrict = null;
          });
        }
      });
    }
    return DropdownButtonFormField<String>(
      value: dropdownValue,
      decoration: InputDecoration(
        labelText: "State",
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      items: _stateDistricts
          .map(
            (state) => DropdownMenuItem(
              value: state.state,
              child: Text(state.state),
            ),
          )
          .toList(),
      onChanged: (value) {
        setState(() {
          _selectedState = value;
          _selectedDistrict = null;
        });
      },
    );
  }

  Widget _buildPhotoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Soil photo (optional)",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _pickImage(ImageSource.camera),
                icon: const Icon(Icons.camera_alt),
                label: const Text("Camera"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: const EdgeInsets.all(14),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _pickImage(ImageSource.gallery),
                icon: const Icon(Icons.photo),
                label: const Text("Gallery"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.all(14),
                ),
              ),
            ),
          ],
        ),
        if (_imageBytes != null) ...[
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.memory(_imageBytes!, height: 220, width: double.infinity, fit: BoxFit.cover),
          ),
          TextButton(
            onPressed: () => setState(() => _imageBytes = null),
            child: const Text("Remove photo"),
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final disabled = _loadingCatalog;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Festive Crop Recommender", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green.shade700,
        centerTitle: true,
      ),
      body: _loadingCatalog
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildLocationTile(),
                  if (_locationError != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        _locationError!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  const SizedBox(height: 12),
                  _buildStateDropdown(),
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: _openDistrictPicker,
                    borderRadius: BorderRadius.circular(12),
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: "District",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        suffixIcon: const Icon(Icons.expand_more),
                      ),
                      child: Text(
                        _selectedDistrict ?? "Tap to select a district",
                        style: TextStyle(
                          color: _selectedDistrict == null ? Colors.grey : Colors.black,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildPhotoSection(),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: disabled || _loadingRecommendations ? null : _getRecommendations,
                    icon: _loadingRecommendations
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Icon(Icons.auto_awesome),
                    label: Text(_loadingRecommendations ? "Generating..." : "Recommend crops"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade700,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: disabled || _fetchingCropInsight ? null : _openCropChooser,
                    icon: _fetchingCropInsight
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.spa),
                    label: const Text("Choose a crop you want to grow"),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 56),
                      foregroundColor: Colors.green.shade700,
                      side: BorderSide(color: Colors.green.shade700),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}