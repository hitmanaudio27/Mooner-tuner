import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Settings model for the tuner app
class TunerSettings extends ChangeNotifier {
  double _a4Frequency = 440.0;
  double _sensitivity = 0.5; // 0.0 (low) to 1.0 (high)
  bool _useFlats = false;
  
  double get a4Frequency => _a4Frequency;
  double get sensitivity => _sensitivity;
  bool get useFlats => _useFlats;
  
  TunerSettings() {
    _loadSettings();
  }
  
  /// Load settings from shared preferences
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _a4Frequency = prefs.getDouble('a4_frequency') ?? 440.0;
    _sensitivity = prefs.getDouble('sensitivity') ?? 0.5;
    _useFlats = prefs.getBool('use_flats') ?? false;
    notifyListeners();
  }
  
  /// Set A4 reference frequency
  Future<void> setA4Frequency(double frequency) async {
    if (frequency < 430.0 || frequency > 450.0) return;
    _a4Frequency = frequency;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('a4_frequency', frequency);
    notifyListeners();
  }
  
  /// Set sensitivity (0.0 = low, 0.5 = medium, 1.0 = high)
  Future<void> setSensitivity(double sensitivity) async {
    if (sensitivity < 0.0 || sensitivity > 1.0) return;
    _sensitivity = sensitivity;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('sensitivity', sensitivity);
    notifyListeners();
  }
  
  /// Toggle notation between sharps and flats
  Future<void> setNotation({required bool useFlats}) async {
    _useFlats = useFlats;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('use_flats', useFlats);
    notifyListeners();
  }
  
  /// Reset to default settings
  Future<void> resetToDefaults() async {
    _a4Frequency = 440.0;
    _sensitivity = 0.5;
    _useFlats = false;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('a4_frequency', 440.0);
    await prefs.setDouble('sensitivity', 0.5);
    await prefs.setBool('use_flats', false);
    
    notifyListeners();
  }
  
  /// Get sensitivity label
  String get sensitivityLabel {
    if (_sensitivity < 0.33) return 'Low';
    if (_sensitivity < 0.67) return 'Medium';
    return 'High';
  }
}
