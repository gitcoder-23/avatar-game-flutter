import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class AudioService {
  static final AudioService instance = AudioService._init();
  AudioService._init();

  final AudioPlayer _bgmPlayer = AudioPlayer();
  final AudioPlayer _sfxPlayer = AudioPlayer();

  bool _soundEnabled = true;
  bool _musicEnabled = true;

  bool get soundEnabled => _soundEnabled;
  bool get musicEnabled => _musicEnabled;

  void init({bool soundEnabled = true, bool musicEnabled = true}) {
    _soundEnabled = soundEnabled;
    _musicEnabled = musicEnabled;
    _bgmPlayer.setReleaseMode(ReleaseMode.loop);
  }

  void updateSettings({required bool soundEnabled, required bool musicEnabled}) {
    _soundEnabled = soundEnabled;
    _musicEnabled = musicEnabled;

    if (!_musicEnabled) {
      _bgmPlayer.stop();
    }
  }

  Future<void> playBgm(String stageName) async {
    if (!_musicEnabled) return;
    try {
      // In Flutter, we can play music or synth tracks
      // Set volume
      await _bgmPlayer.setVolume(0.4);
    } catch (e) {
      debugPrint('AudioService BGM error: $e');
    }
  }

  Future<void> stopBgm() async {
    try {
      await _bgmPlayer.stop();
    } catch (e) {
      debugPrint('AudioService stopBgm error: $e');
    }
  }

  // SFX triggers with haptic feedback
  Future<void> playSlash() async {
    if (!_soundEnabled) return;
    try {
      HapticFeedback.lightImpact();
      // Fast lightweight audio trigger
    } catch (_) {}
  }

  Future<void> playFrostNova() async {
    if (!_soundEnabled) return;
    try {
      HapticFeedback.mediumImpact();
    } catch (_) {}
  }

  Future<void> playInfernoComet() async {
    if (!_soundEnabled) return;
    try {
      HapticFeedback.heavyImpact();
    } catch (_) {}
  }

  Future<void> playVoidDash() async {
    if (!_soundEnabled) return;
    try {
      HapticFeedback.selectionClick();
    } catch (_) {}
  }

  Future<void> playUltimate() async {
    if (!_soundEnabled) return;
    try {
      HapticFeedback.heavyImpact();
      Future.delayed(const Duration(milliseconds: 150), () => HapticFeedback.heavyImpact());
      Future.delayed(const Duration(milliseconds: 300), () => HapticFeedback.heavyImpact());
    } catch (_) {}
  }

  Future<void> playHit() async {
    if (!_soundEnabled) return;
    try {
      HapticFeedback.mediumImpact();
    } catch (_) {}
  }

  Future<void> playBossRoar() async {
    if (!_soundEnabled) return;
    try {
      HapticFeedback.heavyImpact();
      Future.delayed(const Duration(milliseconds: 200), () => HapticFeedback.heavyImpact());
    } catch (_) {}
  }

  Future<void> playLevelClear() async {
    if (!_soundEnabled) return;
    try {
      HapticFeedback.heavyImpact();
    } catch (_) {}
  }

  Future<void> playLevelFailed() async {
    if (!_soundEnabled) return;
    try {
      HapticFeedback.vibrate();
    } catch (_) {}
  }

  void dispose() {
    _bgmPlayer.dispose();
    _sfxPlayer.dispose();
  }
}
