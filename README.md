# 🌙 Mooner Tuner

A professional chromatic tuner app with a stunning lunar-tech aesthetic, built with Flutter.

## ✨ Features

### 🎵 Core Functionality
- **High-Accuracy Pitch Detection**: Uses the YIN algorithm for superior accuracy, especially at low frequencies
- **No Octave Errors**: Advanced algorithm prevents common octave confusion issues
- **Real-Time Processing**: Instant pitch detection and visual feedback
- **12-Tone Equal Temperament**: Recognizes all notes in the chromatic scale
- **Cents Deviation Display**: Shows precise tuning within ±50 cents

### 🌌 Lunar-Tech Aesthetic
- **Animated Space Background**: Twinkling stars and holographic grid lines
- **Moon Phase Indicator**: 
  - Full moon = perfectly in tune
  - Waning crescent (left) = flat
  - Waxing crescent (right) = sharp
- **Dynamic Color System**:
  - 🟢 Green glow = in tune (within ±2 cents)
  - 🔵 Blue = slightly out of tune
  - 🟠 Orange = moderately out of tune
  - 🔴 Red = very out of tune
- **Precision Cents Meter**: Needle-style indicator with colored zones
- **Pulsing Effects**: Visual feedback when notes lock in tune

### ⚙️ Settings & Calibration
- **Reference Pitch Adjustment**: A4 = 430-450 Hz (default 440 Hz)
- **Sensitivity Control**: Low, Medium, High noise gate settings
- **Notation Toggle**: Switch between sharp (C#, D#) and flat (Db, Eb) notation
- **Persistent Settings**: All preferences saved automatically

## 🎯 Technical Specifications

### Pitch Detection Engine
- **Algorithm**: YIN (not FFT) for musical instrument accuracy
- **Sample Rate**: 44,100 Hz
- **Buffer Size**: 4,096 samples
- **Frequency Range**: 20 Hz - 4,200 Hz
- **Accuracy**: Sub-cent precision with parabolic interpolation

### Audio Processing
- **Input**: Device microphone (16-bit PCM)
- **Permission Handling**: Automatic microphone permission request
- **Noise Gate**: Adjustable RMS-based filtering
- **Real-Time Streaming**: Low-latency audio capture

### UI/UX Design
- **Color Palette**: Deep space black, midnight blue, electric blue, neon purple
- **Typography**: Clean sans-serif tech fonts with monospace for values
- **Animation**: 60fps smooth animations and transitions
- **Responsive Design**: Optimized for mobile portrait orientation

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.35.4 or higher
- Dart 3.9.2 or higher
- Android Studio / Xcode for mobile development
- Microphone access permission

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd mooner_tuner
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

### Building for Production

**Android APK:**
```bash
flutter build apk --release
```

**iOS:**
```bash
flutter build ios --release
```

**Web:**
```bash
flutter build web --release
```

## 📱 Platform Support

- ✅ Android (API 21+)
- ✅ iOS (11.0+)
- ✅ Web (Chrome, Safari, Firefox)

## 🎮 Usage

1. **Start Tuning**: Tap the play button to begin listening
2. **Play Your Instrument**: The app will detect the pitch and display:
   - Note name (C, C#, D, etc.)
   - Octave number
   - Frequency in Hz
   - Cents deviation
   - Moon phase indicator
3. **Adjust Settings**: Tap the settings icon to:
   - Calibrate reference pitch
   - Adjust sensitivity
   - Change notation style
4. **Get In Tune**: Watch the moon become full when perfectly tuned!

## 🔧 Architecture

```
lib/
├── main.dart                      # App entry point
├── models/
│   └── tuner_settings.dart       # Settings state management
├── screens/
│   ├── tuner_screen.dart         # Main tuner interface
│   └── settings_screen.dart      # Settings UI
├── services/
│   ├── audio_service.dart        # Audio capture & processing
│   ├── note_detector.dart        # Musical note detection
│   └── yin_pitch_detector.dart   # YIN algorithm implementation
└── widgets/
    ├── space_background.dart     # Animated background
    ├── moon_tuning_indicator.dart # Moon phase visual
    └── cents_meter.dart          # Precision meter widget
```

## 📚 Key Dependencies

- **provider**: State management
- **permission_handler**: Microphone permissions
- **mic_stream**: Real-time audio input
- **shared_preferences**: Settings persistence

## 🌟 Design Philosophy

Mooner Tuner combines professional-grade tuning accuracy with an immersive visual experience:

1. **Accuracy First**: YIN algorithm ensures reliable pitch detection without octave errors
2. **Instant Feedback**: Real-time visual indicators guide tuning process
3. **Intuitive Design**: Moon phase metaphor makes tuning status immediately clear
4. **Aesthetic Excellence**: Lunar-tech theme creates a unique, engaging experience
5. **Customizable**: Settings allow personalization without compromising simplicity

## 🎨 Color Reference

```
Background:       #0A0E27 (Deep space black)
Secondary BG:     #1A1F3A (Midnight blue)
Primary Accent:   #2196F3 (Electric blue)
In-Tune:          #00FF88 (Neon green)
Warning:          #FF9800 (Orange)
Error:            #FF5252 (Red)
```

## 📝 License

This project is licensed under the MIT License.

## 🙏 Acknowledgments

- YIN algorithm paper by Alain de Cheveigné and Hideki Kawahara
- Flutter team for the amazing framework
- The open-source community for excellent packages

---

**Made with 🌙 and Flutter**
