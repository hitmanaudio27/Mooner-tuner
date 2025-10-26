import 'dart:math';
import 'dart:typed_data';

/// YIN pitch detection algorithm implementation
/// More accurate than FFT for musical pitch detection, especially at low frequencies
class YinPitchDetector {
  final int sampleRate;
  final double threshold;
  
  YinPitchDetector({
    this.sampleRate = 44100,
    this.threshold = 0.15,
  });
  
  /// Detect pitch from audio buffer
  /// Returns frequency in Hz, or null if no pitch detected
  double? detectPitch(Float32List buffer) {
    if (buffer.length < 2048) return null;
    
    // Use a window of 2048 samples for good frequency resolution
    final windowSize = min(2048, buffer.length);
    final yinBuffer = Float32List(windowSize ~/ 2);
    
    // Step 1: Calculate difference function
    _differenceFunction(buffer, yinBuffer, windowSize);
    
    // Step 2: Calculate cumulative mean normalized difference function
    _cumulativeMeanNormalizedDifference(yinBuffer);
    
    // Step 3: Absolute threshold
    final tau = _absoluteThreshold(yinBuffer);
    
    if (tau == -1) return null;
    
    // Step 4: Parabolic interpolation for better accuracy
    double betterTau;
    if (tau < 1) {
      betterTau = tau.toDouble();
    } else if (tau >= yinBuffer.length - 1) {
      betterTau = tau.toDouble();
    } else {
      // Parabolic interpolation
      final s0 = yinBuffer[tau - 1];
      final s1 = yinBuffer[tau];
      final s2 = yinBuffer[tau + 1];
      betterTau = tau + (s2 - s0) / (2 * (2 * s1 - s2 - s0));
    }
    
    // Convert tau to frequency
    final frequency = sampleRate / betterTau;
    
    // Filter out unrealistic frequencies
    if (frequency < 20 || frequency > 4200) return null;
    
    return frequency;
  }
  
  /// Step 1: Difference function
  void _differenceFunction(Float32List buffer, Float32List yinBuffer, int windowSize) {
    for (int tau = 0; tau < yinBuffer.length; tau++) {
      double sum = 0;
      for (int i = 0; i < windowSize ~/ 2; i++) {
        final delta = buffer[i] - buffer[i + tau];
        sum += delta * delta;
      }
      yinBuffer[tau] = sum;
    }
  }
  
  /// Step 2: Cumulative mean normalized difference function
  void _cumulativeMeanNormalizedDifference(Float32List yinBuffer) {
    yinBuffer[0] = 1;
    
    double runningSum = 0;
    for (int tau = 1; tau < yinBuffer.length; tau++) {
      runningSum += yinBuffer[tau];
      yinBuffer[tau] *= tau / runningSum;
    }
  }
  
  /// Step 3: Absolute threshold
  int _absoluteThreshold(Float32List yinBuffer) {
    // Start from tau = 2 to avoid near-zero frequencies
    for (int tau = 2; tau < yinBuffer.length; tau++) {
      if (yinBuffer[tau] < threshold) {
        // Find the minimum in the valley
        while (tau + 1 < yinBuffer.length && yinBuffer[tau + 1] < yinBuffer[tau]) {
          tau++;
        }
        return tau;
      }
    }
    return -1;
  }
}
