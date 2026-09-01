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
  String? _currentBgmTrack;

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
      _currentBgmTrack = null;
    }
  }

  /// Play background music with intelligent track switching (doesn't restart if already playing)
  Future<void> _playBgmFile(String assetPath) async {
    if (!_musicEnabled) return;
    if (_currentBgmTrack == assetPath) return; // Already playing

    try {
      _currentBgmTrack = assetPath;
      await _bgmPlayer.stop();
      await _bgmPlayer.setVolume(0.45);
      await _bgmPlayer.setReleaseMode(ReleaseMode.loop);
      await _bgmPlayer.play(AssetSource(assetPath));
    } catch (e) {
      debugPrint('AudioService playBgm error: $e');
    }
  }

  /// Menu & Stage Select Ambient Theme
  Future<void> playMenuBgm() async {
    await _playBgmFile('audio/bgm_menu.wav');
  }

  /// District Combat Theme (Stages 1-5)
  Future<void> playActionBgm() async {
    await _playBgmFile('audio/bgm_action.wav');
  }

  /// Venom Boss Apex Theme (Stage 6)
  Future<void> playBossBgm() async {
    await _playBgmFile('audio/bgm_boss.wav');
  }

  /// Context-aware stage BGM
  Future<void> playStageBgm(int stageId, bool isBoss) async {
    if (isBoss || stageId == 6) {
      await playBossBgm();
    } else {
      await playActionBgm();
    }
  }

  Future<void> stopBgm() async {
    try {
      _currentBgmTrack = null;
      await _bgmPlayer.stop();
    } catch (e) {
      debugPrint('AudioService stopBgm error: $e');
    }
  }

  // SFX helper
  Future<void> _playSfx(String assetPath, {VoidCallback? haptic}) async {
    if (!_soundEnabled) return;
    try {
      haptic?.call();
      final player = AudioPlayer();
      await player.setVolume(0.85);
      await player.play(AssetSource(assetPath));
      player.onPlayerComplete.listen((_) => player.dispose());
    } catch (_) {
      haptic?.call();
    }
  }

  // --- UI Interactions SFX ---

  Future<void> playButtonClick() async {
    await _playSfx('audio/sfx_click.wav', haptic: () => HapticFeedback.selectionClick());
  }

  Future<void> playScreenTransition() async {
    await _playSfx('audio/sfx_nav.wav', haptic: () => HapticFeedback.lightImpact());
  }

  Future<void> playUpgrade() async {
    await _playSfx('audio/sfx_upgrade.wav', haptic: () => HapticFeedback.mediumImpact());
  }

  // --- Superhero Combat SFX ---

  Future<void> playSlash() async {
    await _playSfx('audio/sfx_slash.wav', haptic: () => HapticFeedback.lightImpact());
  }

  Future<void> playWebShooter() async {
    await _playSfx('audio/sfx_web.wav', haptic: () => HapticFeedback.mediumImpact());
  }

  Future<void> playSymbioteSurge() async {
    await _playSfx('audio/sfx_symbiote.wav', haptic: () => HapticFeedback.heavyImpact());
  }

  Future<void> playFrostNova() async => playWebShooter();
  Future<void> playInfernoComet() async => playSymbioteSurge();
  Future<void> playVoidDash() async => playWebShooter();

  Future<void> playUltimate() async {
    await _playSfx('audio/sfx_symbiote.wav', haptic: () {
      HapticFeedback.heavyImpact();
      Future.delayed(const Duration(milliseconds: 150), () => HapticFeedback.heavyImpact());
      Future.delayed(const Duration(milliseconds: 300), () => HapticFeedback.heavyImpact());
    });
  }

  Future<void> playHit() async {
    await _playSfx('audio/sfx_slash.wav', haptic: () => HapticFeedback.mediumImpact());
  }

  Future<void> playBossRoar() async {
    await _playSfx('audio/sfx_symbiote.wav', haptic: () {
      HapticFeedback.heavyImpact();
      Future.delayed(const Duration(milliseconds: 200), () => HapticFeedback.heavyImpact());
    });
  }

  Future<void> playVictory() async {
    await _playSfx('audio/sfx_victory.wav', haptic: () => HapticFeedback.heavyImpact());
  }

  Future<void> playDefeat() async {
    await _playSfx('audio/sfx_defeat.wav', haptic: () => HapticFeedback.vibrate());
  }

  void dispose() {
    _bgmPlayer.dispose();
    _sfxPlayer.dispose();
  }
}
