import 'dart:convert';
import 'package:flutter/foundation.dart';

/// Unity Communication Protocol & Event Message Bridge
class UnityGameBridge {
  static final UnityGameBridge instance = UnityGameBridge._init();
  UnityGameBridge._init();

  bool isUnityLoaded = false;
  Function(String message)? onUnityMessageReceived;

  // --- Flutter -> Unity Commands ---

  /// Send stage start signal with enemy configs to Unity
  Map<String, dynamic> createStartStagePayload({
    required int stageId,
    required String stageName,
    required bool isBoss,
    required double heroAtk,
    required double heroHp,
    required double heroDef,
    required double heroMp,
  }) {
    return {
      'action': 'START_STAGE',
      'stageId': stageId,
      'stageName': stageName,
      'isBoss': isBoss,
      'heroStats': {
        'atk': heroAtk,
        'hp': heroHp,
        'def': heroDef,
        'mp': heroMp,
      },
    };
  }

  /// Send joystick vector to Unity 3D Spider-Man controller
  Map<String, dynamic> createJoystickPayload(double angle, double distance) {
    return {
      'action': 'MOVE_JOYSTICK',
      'angle': angle,
      'distance': distance,
    };
  }

  /// Send combat ability action to Unity
  Map<String, dynamic> createSkillPayload(String skillName) {
    return {
      'action': 'CAST_SKILL',
      'skill': skillName,
    };
  }

  /// Format payload to JSON string for Unity SendMessage
  String encodePayload(Map<String, dynamic> payload) {
    return jsonEncode(payload);
  }

  // --- Unity -> Flutter Event Handler ---

  /// Parse events sent from Unity (e.g. OnHit, OnScore, OnVictory)
  Map<String, dynamic>? parseUnityMessage(String rawMessage) {
    try {
      final decoded = jsonDecode(rawMessage) as Map<String, dynamic>;
      debugPrint('[UnityGameBridge] Received event from Unity: $decoded');
      return decoded;
    } catch (e) {
      debugPrint('[UnityGameBridge] Error parsing message from Unity: $e');
      return null;
    }
  }
}
