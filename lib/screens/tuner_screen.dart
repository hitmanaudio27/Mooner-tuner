import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/tuner_settings.dart';
import '../services/audio_service.dart';
import '../services/note_detector.dart';
import '../widgets/space_background.dart';
import '../widgets/moon_tuning_indicator.dart';
import '../widgets/cents_meter.dart';
import '../widgets/floating_particles.dart';
import '../widgets/orbital_rings.dart';
import '../widgets/chromatic_scale_display.dart';
import 'settings_screen.dart';

/// Main tuner screen with lunar-tech aesthetic
class TunerScreen extends StatefulWidget {
  const TunerScreen({super.key});

  @override
  State<TunerScreen> createState() => _TunerScreenState();
}

class _TunerScreenState extends State<TunerScreen> {
  late AudioService _audioService;
  Note? _currentNote;
  bool _isListening = false;
  String _statusMessage = 'Tap to start tuning';

  @override
  void initState() {
    super.initState();
    _initializeAudioService();
  }

  void _initializeAudioService() {
    final settings = Provider.of<TunerSettings>(context, listen: false);
    _audioService = AudioService(
      a4Frequency: settings.a4Frequency,
      useFlats: settings.useFlats,
    );
    _audioService.setSensitivity(settings.sensitivity);

    _audioService.noteStream.listen((note) {
      if (mounted) {
        setState(() {
          _currentNote = note;
        });
      }
    });
  }

  @override
  void dispose() {
    _audioService.dispose();
    super.dispose();
  }

  Future<void> _toggleListening() async {
    if (_isListening) {
      await _audioService.stopListening();
      setState(() {
        _isListening = false;
        _currentNote = null;
        _statusMessage = 'Tap to start tuning';
      });
    } else {
      try {
        setState(() {
          _statusMessage = 'Requesting microphone access...';
        });

        await _audioService.startListening();
        
        setState(() {
          _isListening = true;
          _statusMessage = 'Listening...';
        });
      } catch (e) {
        setState(() {
          _statusMessage = 'Microphone access denied';
          _isListening = false;
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Microphone permission required for tuner'),
              backgroundColor: const Color(0xFFFF5252),
              action: SnackBarAction(
                label: 'OK',
                textColor: Colors.white,
                onPressed: () {},
              ),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Animated space background
          const Positioned.fill(
            child: SpaceBackground(),
          ),
          
          // Main content
          SafeArea(
            child: Column(
              children: [
                // App bar
                _buildAppBar(),
                
                const Spacer(),
                
                // Main tuning display
                _buildMainTuningDisplay(),
                
                const Spacer(),
                
                // Control button
                _buildControlButton(),
                
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // App title
          const Text(
            'MOONER TUNER',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              letterSpacing: 3,
              fontWeight: FontWeight.w300,
            ),
          ),
          
          // Settings button
          IconButton(
            onPressed: () async {
              final wasListening = _isListening;
              if (wasListening) {
                await _audioService.stopListening();
                setState(() {
                  _isListening = false;
                });
              }

              if (!mounted) return;
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );

              if (!mounted) return;
              // Update audio service with new settings
              final settings = Provider.of<TunerSettings>(context, listen: false);
              _audioService.setA4Frequency(settings.a4Frequency);
              _audioService.setNotation(useFlats: settings.useFlats);
              _audioService.setSensitivity(settings.sensitivity);

              if (wasListening) {
                await _audioService.startListening();
                setState(() {
                  _isListening = true;
                });
              }
            },
            icon: const Icon(Icons.settings, color: Colors.white, size: 28),
          ),
        ],
      ),
    );
  }

  Widget _buildMainTuningDisplay() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Frequency display
        if (_currentNote != null)
          Text(
            '${_currentNote!.frequency.toStringAsFixed(2)} Hz',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 14,
              fontFamily: 'monospace',
              letterSpacing: 2,
            ),
          ),
        
        const SizedBox(height: 20),
        
        // Moon tuning indicator with orbital rings and particles
        SizedBox(
          width: 320,
          height: 320,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Orbital rings (background)
              Positioned.fill(
                child: OrbitalRings(
                  isActive: _isListening,
                  isInTune: _currentNote?.isInTune ?? false,
                ),
              ),
              
              // Floating iridescent particles
              if (_isListening)
                const Positioned.fill(
                  child: FloatingParticles(particleCount: 30),
                ),
              
              // Moon indicator (foreground)
              Center(
                child: MoonTuningIndicator(
                  centsDeviation: _currentNote?.centsDeviation,
                  isInTune: _currentNote?.isInTune ?? false,
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 30),
        
        // Note name display
        Container(
          height: 80,
          alignment: Alignment.center,
          child: _currentNote != null
              ? Text(
                  _currentNote!.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 72,
                    fontWeight: FontWeight.w300,
                    letterSpacing: 4,
                    fontFamily: 'monospace',
                  ),
                )
              : Text(
                  _isListening ? '---' : '',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.3),
                    fontSize: 72,
                    fontWeight: FontWeight.w300,
                    letterSpacing: 4,
                  ),
                ),
        ),
        
        // Octave display
        if (_currentNote != null)
          Text(
            'Octave ${_currentNote!.octave}',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 14,
              letterSpacing: 2,
            ),
          ),
        
        const SizedBox(height: 30),
        
        // Chromatic scale display
        Consumer<TunerSettings>(
          builder: (context, settings, child) {
            return ChromaticScaleDisplay(
              currentNote: _currentNote?.name,
              useFlats: settings.useFlats,
            );
          },
        ),
        
        const SizedBox(height: 30),
        
        // Cents meter
        CentsMeter(
          centsDeviation: _currentNote?.centsDeviation,
          isInTune: _currentNote?.isInTune ?? false,
        ),
        
        const SizedBox(height: 20),
        
        // Cents deviation text
        if (_currentNote != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: _getCentsDeviationColor().withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _getCentsDeviationColor().withValues(alpha: 0.5),
                width: 1,
              ),
            ),
            child: Text(
              _getCentsDeviationText(),
              style: TextStyle(
                color: _getCentsDeviationColor(),
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
                fontFamily: 'monospace',
              ),
            ),
          )
        else if (_isListening)
          Text(
            _statusMessage,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 14,
              letterSpacing: 1,
            ),
          ),
      ],
    );
  }

  Widget _buildControlButton() {
    return GestureDetector(
      onTap: _toggleListening,
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: _isListening
              ? const LinearGradient(
                  colors: [Color(0xFFFF5252), Color(0xFFFF9800)],
                )
              : const LinearGradient(
                  colors: [Color(0xFF2196F3), Color(0xFF00BCD4)],
                ),
          boxShadow: [
            BoxShadow(
              color: _isListening
                  ? const Color(0xFFFF5252).withValues(alpha: 0.5)
                  : const Color(0xFF2196F3).withValues(alpha: 0.5),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Icon(
          _isListening ? Icons.stop : Icons.play_arrow,
          color: Colors.white,
          size: 40,
        ),
      ),
    );
  }

  Color _getCentsDeviationColor() {
    if (_currentNote == null) return Colors.white;
    
    if (_currentNote!.isInTune) {
      return const Color(0xFF00FF88);
    } else if (_currentNote!.centsDeviation.abs() > 25) {
      return const Color(0xFFFF5252);
    } else if (_currentNote!.centsDeviation.abs() > 10) {
      return const Color(0xFFFF9800);
    } else {
      return const Color(0xFF2196F3);
    }
  }

  String _getCentsDeviationText() {
    if (_currentNote == null) return '';
    
    final cents = _currentNote!.centsDeviation;
    final sign = cents >= 0 ? '+' : '';
    
    if (_currentNote!.isInTune) {
      return '🎵 IN TUNE';
    } else {
      return '$sign${cents.toStringAsFixed(1)} cents';
    }
  }
}
