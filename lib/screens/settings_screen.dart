import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/tuner_settings.dart';

/// Settings screen with lunar-tech aesthetic
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'SETTINGS',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            letterSpacing: 2,
            fontWeight: FontWeight.w300,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<TunerSettings>(
        builder: (context, settings, child) {
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Reference Pitch Section
              _buildSectionHeader('REFERENCE PITCH'),
              const SizedBox(height: 16),
              _buildFrequencyControl(context, settings),
              const SizedBox(height: 32),

              // Sensitivity Section
              _buildSectionHeader('SENSITIVITY'),
              const SizedBox(height: 16),
              _buildSensitivityControl(context, settings),
              const SizedBox(height: 32),

              // Notation Section
              _buildSectionHeader('NOTATION'),
              const SizedBox(height: 16),
              _buildNotationControl(context, settings),
              const SizedBox(height: 32),

              // Reset Button
              Center(
                child: _buildResetButton(context, settings),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Color(0xFF2196F3),
        fontSize: 14,
        letterSpacing: 2,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildFrequencyControl(BuildContext context, TunerSettings settings) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF2196F3).withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'A4 Frequency',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
              Text(
                '${settings.a4Frequency.toStringAsFixed(1)} Hz',
                style: const TextStyle(
                  color: Color(0xFF2196F3),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              IconButton(
                onPressed: () {
                  if (settings.a4Frequency > 430) {
                    settings.setA4Frequency(settings.a4Frequency - 1);
                  }
                },
                icon: const Icon(Icons.remove_circle_outline),
                color: const Color(0xFF2196F3),
              ),
              Expanded(
                child: SliderTheme(
                  data: SliderThemeData(
                    activeTrackColor: const Color(0xFF2196F3),
                    inactiveTrackColor: Colors.white.withValues(alpha: 0.1),
                    thumbColor: const Color(0xFF2196F3),
                    overlayColor: const Color(0xFF2196F3).withValues(alpha: 0.2),
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                  ),
                  child: Slider(
                    value: settings.a4Frequency,
                    min: 430,
                    max: 450,
                    divisions: 200,
                    onChanged: (value) {
                      settings.setA4Frequency(value);
                    },
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  if (settings.a4Frequency < 450) {
                    settings.setA4Frequency(settings.a4Frequency + 1);
                  }
                },
                icon: const Icon(Icons.add_circle_outline),
                color: const Color(0xFF2196F3),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Range: 430 - 450 Hz',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSensitivityControl(BuildContext context, TunerSettings settings) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF2196F3).withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Noise Gate',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF2196F3).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  settings.sensitivityLabel,
                  style: const TextStyle(
                    color: Color(0xFF2196F3),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: const Color(0xFF2196F3),
              inactiveTrackColor: Colors.white.withValues(alpha: 0.1),
              thumbColor: const Color(0xFF2196F3),
              overlayColor: const Color(0xFF2196F3).withValues(alpha: 0.2),
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
            ),
            child: Slider(
              value: settings.sensitivity,
              min: 0,
              max: 1,
              divisions: 2,
              onChanged: (value) {
                settings.setSensitivity(value);
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Low',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 12,
                ),
              ),
              Text(
                'Medium',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 12,
                ),
              ),
              Text(
                'High',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNotationControl(BuildContext context, TunerSettings settings) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF2196F3).withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Use Flat Notation',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
          Switch(
            value: settings.useFlats,
            onChanged: (value) {
              settings.setNotation(useFlats: value);
            },
            activeTrackColor: const Color(0xFF2196F3).withValues(alpha: 0.5),
          ),
        ],
      ),
    );
  }

  Widget _buildResetButton(BuildContext context, TunerSettings settings) {
    return OutlinedButton(
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: const Color(0xFF1A1F3A),
            title: const Text(
              'Reset Settings',
              style: TextStyle(color: Colors.white),
            ),
            content: const Text(
              'Reset all settings to default values?',
              style: TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('CANCEL'),
              ),
              TextButton(
                onPressed: () {
                  settings.resetToDefaults();
                  Navigator.pop(context);
                },
                child: const Text(
                  'RESET',
                  style: TextStyle(color: Color(0xFFFF5252)),
                ),
              ),
            ],
          ),
        );
      },
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: Color(0xFF2196F3)),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
      ),
      child: const Text(
        'RESET TO DEFAULTS',
        style: TextStyle(
          color: Color(0xFF2196F3),
          letterSpacing: 1,
        ),
      ),
    );
  }
}
