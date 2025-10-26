import 'package:flutter/material.dart';

/// Visual chromatic scale showing all 12 notes
class ChromaticScaleDisplay extends StatelessWidget {
  final String? currentNote;
  final bool useFlats;

  const ChromaticScaleDisplay({
    super.key,
    this.currentNote,
    this.useFlats = false,
  });

  static const List<String> notesSharp = [
    'C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B'
  ];

  static const List<String> notesFlat = [
    'C', 'Db', 'D', 'Eb', 'E', 'F', 'Gb', 'G', 'Ab', 'A', 'Bb', 'B'
  ];

  @override
  Widget build(BuildContext context) {
    final notes = useFlats ? notesFlat : notesSharp;

    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: notes.map((note) {
          final isActive = currentNote == note;
          return _buildNoteIndicator(note, isActive);
        }).toList(),
      ),
    );
  }

  Widget _buildNoteIndicator(String note, bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: isActive ? 40 : 24,
      height: isActive ? 40 : 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive
            ? const Color(0xFF00FF88)
            : Colors.white.withValues(alpha: 0.1),
        border: Border.all(
          color: isActive
              ? const Color(0xFF00FF88)
              : Colors.white.withValues(alpha: 0.2),
          width: isActive ? 2 : 1,
        ),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: const Color(0xFF00FF88).withValues(alpha: 0.5),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: Center(
        child: Text(
          note,
          style: TextStyle(
            color: isActive ? Colors.black : Colors.white.withValues(alpha: 0.5),
            fontSize: isActive ? 14 : 10,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
