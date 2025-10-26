import 'dart:math';

/// Represents a musical note with its properties
class Note {
  final String name;
  final int octave;
  final double frequency;
  final double centsDeviation;
  
  Note({
    required this.name,
    required this.octave,
    required this.frequency,
    required this.centsDeviation,
  });
  
  bool get isInTune => centsDeviation.abs() <= 2.0;
  
  String get fullName => '$name$octave';
  
  @override
  String toString() => '$fullName (${frequency.toStringAsFixed(2)} Hz, ${centsDeviation >= 0 ? '+' : ''}${centsDeviation.toStringAsFixed(1)} cents)';
}

/// Detects musical notes from frequency
class NoteDetector {
  static const List<String> noteNamesSharp = [
    'C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B'
  ];
  
  static const List<String> noteNamesFlat = [
    'C', 'Db', 'D', 'Eb', 'E', 'F', 'Gb', 'G', 'Ab', 'A', 'Bb', 'B'
  ];
  
  double _a4Frequency;
  bool _useFlats;
  
  NoteDetector({
    double a4Frequency = 440.0,
    bool useFlats = false,
  })  : _a4Frequency = a4Frequency,
        _useFlats = useFlats;
  
  /// Update reference pitch (A4 frequency)
  void setA4Frequency(double frequency) {
    _a4Frequency = frequency;
  }
  
  /// Toggle between sharp and flat notation
  void setNotation({required bool useFlats}) {
    _useFlats = useFlats;
  }
  
  /// Detect note from frequency
  Note? detectNote(double frequency) {
    if (frequency < 20 || frequency > 4200) return null;
    
    // Calculate the number of semitones from A4
    final semitonesFromA4 = 12 * log(frequency / _a4Frequency) / ln2;
    
    // Round to nearest semitone
    final nearestSemitone = semitonesFromA4.round();
    
    // Calculate cents deviation (1 semitone = 100 cents)
    final centsDeviation = (semitonesFromA4 - nearestSemitone) * 100;
    
    // Calculate the note index (0-11) where A=9
    int noteIndex = (nearestSemitone + 9) % 12;
    if (noteIndex < 0) noteIndex += 12;
    
    // Calculate octave (A4 is in octave 4)
    // A4 = 0 semitones, A5 = 12 semitones, A3 = -12 semitones
    final octave = 4 + ((nearestSemitone + 9) / 12).floor();
    
    // Get note name based on notation preference
    final noteNames = _useFlats ? noteNamesFlat : noteNamesSharp;
    final noteName = noteNames[noteIndex];
    
    // Calculate the exact frequency of this note
    final noteFrequency = _a4Frequency * pow(2, nearestSemitone / 12);
    
    return Note(
      name: noteName,
      octave: octave,
      frequency: noteFrequency,
      centsDeviation: centsDeviation,
    );
  }
  
  /// Get frequency for a specific note
  double getNoteFrequency(String noteName, int octave) {
    final noteNames = _useFlats ? noteNamesFlat : noteNamesSharp;
    final noteIndex = noteNames.indexOf(noteName);
    if (noteIndex == -1) return 0;
    
    // Calculate semitones from A4
    final semitonesFromA4 = (octave - 4) * 12 + (noteIndex - 9);
    
    return _a4Frequency * pow(2, semitonesFromA4 / 12);
  }
}
