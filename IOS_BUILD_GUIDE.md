# 🍎 iOS Build Guide - Mooner Tuner

## Prerequisites

### Required Hardware & Software
- **Mac computer** (macOS 11.0 or later recommended)
- **Xcode 14.0+** (download from Mac App Store)
- **Flutter SDK 3.35.4+** (already configured in this project)
- **CocoaPods** (for iOS dependency management)
- **Apple Developer Account** (free for testing, $99/year for App Store)

### Installation Steps

1. **Install Xcode** (if not already installed):
   ```bash
   # Download from Mac App Store or:
   xcode-select --install
   ```

2. **Install CocoaPods**:
   ```bash
   sudo gem install cocoapods
   ```

3. **Verify Flutter iOS setup**:
   ```bash
   flutter doctor
   # Should show ✓ for Xcode and CocoaPods
   ```

## 📱 Building the iOS App

### Step 1: Navigate to Project Directory
```bash
cd /path/to/mooner_tuner
```

### Step 2: Install iOS Dependencies
```bash
cd ios
pod install
cd ..
```

### Step 3: Open in Xcode (Optional, for configuration)
```bash
open ios/Runner.xcworkspace
```

**In Xcode, configure:**
- **Bundle Identifier**: Change to your unique identifier (e.g., `com.yourname.moonertuner`)
- **Team**: Select your Apple Developer account
- **Signing**: Enable automatic signing or configure manual signing
- **Deployment Target**: iOS 11.0 or later

### Step 4: Build for Device/Simulator

**For iOS Simulator:**
```bash
flutter run -d "iPhone 15 Pro"  # or any available simulator
```

**For Physical Device (Debug):**
```bash
# Connect iPhone via USB, unlock, and trust computer
flutter run -d "Your iPhone Name"
```

**For Release Build (TestFlight/App Store):**
```bash
flutter build ios --release
```

**For Ad-Hoc Distribution (no App Store):**
```bash
flutter build ipa --release
# IPA file will be at: build/ios/ipa/mooner_tuner.ipa
```

## 🔧 iOS-Specific Configuration

### Microphone Permission (✅ Already Configured)
The app requires microphone access. We've added this to `Info.plist`:
```xml
<key>NSMicrophoneUsageDescription</key>
<string>Mooner Tuner needs access to your microphone to detect musical pitch and provide real-time tuning feedback.</string>
```

### Supported Orientations
Currently configured for:
- ✅ Portrait (primary)
- ✅ Landscape Left
- ✅ Landscape Right

To lock to portrait only, edit `ios/Runner/Info.plist`:
```xml
<key>UISupportedInterfaceOrientations</key>
<array>
    <string>UIInterfaceOrientationPortrait</string>
</array>
```

### App Display Name
- **Current**: "Mooner Tuner"
- **To change**: Edit `CFBundleDisplayName` in `ios/Runner/Info.plist`

### App Icon
1. Create icon images (1024x1024 base, plus required sizes)
2. Place in `ios/Runner/Assets.xcassets/AppIcon.appiconset/`
3. Or use a tool like [App Icon Generator](https://appicon.co/)

### Launch Screen
- Default launch screen is at `ios/Runner/Base.lproj/LaunchScreen.storyboard`
- Customize in Xcode for branded splash screen

## 📤 Distribution Options

### Option 1: TestFlight (Internal Testing)
1. Build release IPA: `flutter build ipa --release`
2. Open `build/ios/archive/Runner.xcarchive` in Xcode
3. Window → Organizer → Distribute App
4. Choose "TestFlight & App Store"
5. Upload to App Store Connect
6. Add internal testers in App Store Connect

### Option 2: App Store
1. Complete TestFlight testing
2. Create App Store listing in App Store Connect
3. Submit for review
4. Wait for approval (typically 1-3 days)
5. Release to public

### Option 3: Ad-Hoc (Direct Install, no App Store)
1. Build IPA: `flutter build ipa --release --export-options-plist=ios/ExportOptions.plist`
2. Register device UDIDs in Apple Developer Portal
3. Create Ad-Hoc provisioning profile
4. Distribute IPA file to users
5. Install via Xcode or TestFlight alternatives

### Option 4: Enterprise Distribution
- Requires Apple Developer Enterprise Program ($299/year)
- Allows distribution outside App Store
- For organizations with 100+ employees

## 🐛 Common iOS Build Issues

### Issue 1: Pod Install Fails
```bash
cd ios
pod deintegrate
pod install
cd ..
```

### Issue 2: Code Signing Error
- Open Xcode: `open ios/Runner.xcworkspace`
- Select Runner → Signing & Capabilities
- Enable "Automatically manage signing"
- Select your team

### Issue 3: Build Failed - Architecture
```bash
# Clean build
flutter clean
cd ios
rm -rf Pods Podfile.lock
pod install
cd ..
flutter build ios --release
```

### Issue 4: Microphone Permission Not Working
- Verify `NSMicrophoneUsageDescription` in `Info.plist`
- Reset permissions: Settings → Privacy → Microphone
- Reinstall app

### Issue 5: Audio Not Working on Physical Device
- Check device volume
- Check silent mode switch
- Verify microphone permission granted
- Test with different audio source

## 📊 Performance Optimization for iOS

### Recommended Settings (Already Applied)
- ✅ Release mode compilation
- ✅ Dart AOT compilation
- ✅ Tree shaking enabled
- ✅ Obfuscation for release builds

### Additional Optimizations
```bash
# Build with additional optimizations
flutter build ios --release \
  --tree-shake-icons \
  --split-debug-info=build/ios/symbols \
  --obfuscate
```

## 🔍 Testing on iOS

### Audio Testing Checklist
- [ ] Microphone permission prompt appears
- [ ] Permission granted/denied handling works
- [ ] Audio input detected from built-in mic
- [ ] Audio input detected from external mic (if available)
- [ ] No audio feedback/echo
- [ ] Low latency response (<100ms)
- [ ] Works in background (if needed)
- [ ] Silent mode respected
- [ ] Interruption handling (calls, alarms)

### UI Testing Checklist
- [ ] All screens render correctly
- [ ] Animations run at 60fps
- [ ] No layout issues on different iPhone models
- [ ] Safe area respected (notch, home indicator)
- [ ] Dark mode compatible (if applicable)
- [ ] Dynamic type scaling works
- [ ] Landscape orientation works (if enabled)

### Device Testing Matrix
- iPhone SE (2022) - Smallest screen
- iPhone 14/15 - Standard size
- iPhone 14/15 Pro Max - Largest screen
- iPad (if supporting tablets)

## 📱 iOS App Store Requirements

### App Information
- **Name**: Mooner Tuner
- **Subtitle**: Professional Chromatic Tuner
- **Category**: Music
- **Age Rating**: 4+ (no restricted content)

### Required Assets
- App Icon (1024x1024)
- Screenshots (6.5", 5.5" displays)
- App Preview video (optional, recommended)
- Privacy Policy URL
- Support URL

### App Store Description (Suggested)
```
🌙 MOONER TUNER - Professional Chromatic Tuner with Lunar-Tech Aesthetic

Accurate, beautiful, and easy to use. Mooner Tuner helps musicians of all levels achieve perfect pitch with:

✨ FEATURES
• High-accuracy YIN pitch detection algorithm
• Real-time tuning with visual feedback
• Beautiful lunar-themed interface
• Customizable reference pitch (430-450 Hz)
• Sharp/flat notation toggle
• Adjustable sensitivity
• No ads, no subscriptions

🎵 PERFECT FOR
• Guitar, bass, ukulele
• Piano, keyboard
• Violin, cello, viola
• Brass and woodwind instruments
• Vocals and singing

🌌 UNIQUE DESIGN
Watch the moon phase change as you tune - full moon means perfect pitch!

Download now and tune with the moon! 🌙
```

### Keywords (iOS App Store)
```
tuner, chromatic tuner, guitar tuner, pitch detection, instrument tuner, 
music tuner, bass tuner, violin tuner, tuning, pitch
```

## 🚀 Quick Start Commands

**Test on Simulator:**
```bash
flutter run
```

**Build for Device:**
```bash
flutter build ios --release
```

**Create IPA for Distribution:**
```bash
flutter build ipa --release
```

**Run Tests:**
```bash
flutter test
```

**Check for Issues:**
```bash
flutter analyze
```

## 📞 Support Resources

- **Flutter iOS Documentation**: https://docs.flutter.dev/deployment/ios
- **Apple Developer Portal**: https://developer.apple.com/
- **App Store Connect**: https://appstoreconnect.apple.com/
- **TestFlight**: https://developer.apple.com/testflight/

## 🎯 Next Steps After Building

1. ✅ Test thoroughly on physical iOS devices
2. ✅ Gather beta tester feedback
3. ✅ Create App Store assets (icon, screenshots, description)
4. ✅ Submit for TestFlight review
5. ✅ Conduct beta testing phase
6. ✅ Fix any reported issues
7. ✅ Submit to App Store for review
8. ✅ Launch and celebrate! 🎉

---

**Note**: This project is iOS-ready and all configurations are in place. You just need a Mac with Xcode to build and deploy!
