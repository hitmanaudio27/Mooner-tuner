import 'dart:async';
import 'dart:typed_data';
import 'package:record/record.dart';
import 'package:permission_handler/permission_handler.dart';
import 'yin_pitch_detector.dart';
import 'note_detector.dart';

/// Audio processing service with real-time pitch detection
class AudioService {
  final AudioRecorder _audioRecorder = AudioRecorder();
  StreamSubscription? _recordStream;
  final YinPitchDetector _pitchDetector;
  final NoteDetector _noteDetector;
  
  final StreamController<Note?> _noteStreamController = StreamController<Note?>.broadcast();
  Stream<Note?> get noteStream => _noteStreamController.stream;
  
  bool _isListening = false;
  bool get isListening => _isListening;
  
  // Audio configuration
  static const int sampleRate = 44100;
  static const int bufferSize = 4096;
  
  // Noise gate
  double _noiseThreshold = 0.01; // Medium sensitivity
  
  // Buffer for accumulating samples
  final List<int> _buffer = [];
  
  AudioService({
    double a4Frequency = 440.0,
    bool useFlats = false,
  })  : _pitchDetector = YinPitchDetector(sampleRate: sampleRate),
        _noteDetector = NoteDetector(a4Frequency: a4Frequency, useFlats: useFlats);
  
  /// Request microphone permission
  Future<bool> requestPermission() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }
  
  /// Check if microphone permission is granted
  Future<bool> hasPermission() async {
    final status = await Permission.microphone.status;
    return status.isGranted;
  }
  
  /// Start listening to microphone
  Future<void> startListening() async {
    if (_isListening) return;
    
    final hasPermission = await this.hasPermission();
    if (!hasPermission) {
      final granted = await requestPermission();
      if (!granted) {
        throw Exception('Microphone permission not granted');
      }
    }
    
    try {
      // Check if recording is supported
      if (!await _audioRecorder.hasPermission()) {
        throw Exception('Microphone permission denied');
      }
      
      // Start recording with stream
      final stream = await _audioRecorder.startStream(
        const RecordConfig(
          encoder: AudioEncoder.pcm16bits,
          sampleRate: sampleRate,
          numChannels: 1,
        ),
      );
      
      _isListening = true;
      _buffer.clear();
      
      // Listen to audio stream
      _recordStream = stream.listen((data) {
        _buffer.addAll(data);
        
        // Process when we have enough samples
        if (_buffer.length >= bufferSize * 2) { // *2 because 16-bit = 2 bytes per sample
          final processData = _buffer.sublist(0, bufferSize * 2);
          _processAudioBuffer(processData);
          _buffer.removeRange(0, bufferSize * 2);
        }
      });
    } catch (e) {
      _isListening = false;
      rethrow;
    }
  }
  
  /// Stop listening to microphone
  Future<void> stopListening() async {
    await _recordStream?.cancel();
    _recordStream = null;
    await _audioRecorder.stop();
    _isListening = false;
    _buffer.clear();
    _noteStreamController.add(null);
  }
  
  /// Process audio buffer and detect pitch
  void _processAudioBuffer(List<int> rawData) {
    // Convert 16-bit PCM to normalized float samples (-1.0 to 1.0)
    final samples = Float32List(rawData.length ~/ 2);
    for (int i = 0; i < samples.length; i++) {
      final int16 = (rawData[i * 2 + 1] << 8) | rawData[i * 2];
      final signed = int16 > 32767 ? int16 - 65536 : int16;
      samples[i] = signed / 32768.0;
    }
    
    // Apply noise gate
    final rms = _calculateRMS(samples);
    if (rms < _noiseThreshold) {
      _noteStreamController.add(null);
      return;
    }
    
    // Detect pitch using YIN algorithm
    final frequency = _pitchDetector.detectPitch(samples);
    
    if (frequency == null) {
      _noteStreamController.add(null);
      return;
    }
    
    // Detect note from frequency
    final note = _noteDetector.detectNote(frequency);
    _noteStreamController.add(note);
  }
  
  /// Calculate RMS (Root Mean Square) for volume detection
  double _calculateRMS(Float32List samples) {
    double sum = 0;
    for (final sample in samples) {
      sum += sample * sample;
    }
    return (sum / samples.length).abs();
  }
  
  /// Update reference pitch (A4 frequency)
  void setA4Frequency(double frequency) {
    _noteDetector.setA4Frequency(frequency);
  }
  
  /// Toggle between sharp and flat notation
  void setNotation({required bool useFlats}) {
    _noteDetector.setNotation(useFlats: useFlats);
  }
  
  /// Set noise gate sensitivity
  /// sensitivity: 0.0 (low) to 1.0 (high)
  void setSensitivity(double sensitivity) {
    // Map 0-1 to threshold values
    // Low sensitivity = high threshold (0.05)
    // High sensitivity = low threshold (0.001)
    _noiseThreshold = 0.05 - (sensitivity * 0.049);
  }
  
  /// Dispose resources
  void dispose() {
    stopListening();
    _audioRecorder.dispose();
    _noteStreamController.close();
  }
}
