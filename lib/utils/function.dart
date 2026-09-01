import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';

class GameUtils {
  // --- Math & Vector Calculations ---

  /// Calculates Euclidean distance between two 2D points
  static double getDistance(double x1, double y1, double x2, double y2) {
    final dx = x1 - x2;
    final dy = y1 - y2;
    return sqrt(dx * dx + dy * dy);
  }

  /// Calculates angle from point 1 to point 2 in radians
  static double calculateAngle(double x1, double y1, double x2, double y2) {
    return atan2(y2 - y1, x2 - x1);
  }

  /// Normalizes angle difference to [-pi, pi]
  static double normalizeAngleDifference(double angle1, double angle2) {
    final diff = (angle1 - angle2).abs() % (2 * pi);
    return diff > pi ? 2 * pi - diff : diff;
  }

  /// Clamps a 2D position within world boundaries
  static (double, double) clampToWorld(
    double x,
    double y, {
    required double minX,
    required double maxX,
    required double minY,
    required double maxY,
  }) {
    return (x.clamp(minX, maxX), y.clamp(minY, maxY));
  }

  // --- Combat & Formula Utilities ---

  /// Calculates damage after defense mitigation
  static double calculateMitigatedDamage(double rawDamage, double defense) {
    return max(1.0, rawDamage - defense);
  }

  /// Rolls for critical strike given a crit chance (0.0 to 1.0)
  static bool rollCritical(double critChance, [Random? random]) {
    final rand = random ?? Random();
    return rand.nextDouble() < critChance;
  }

  /// Calculates required XP for next hero level
  static int calculateRequiredXp(int level) {
    return level * 500;
  }

  /// Calculates star rating based on battle performance
  static int calculateStars({
    required bool isVictory,
    required double hpPercent,
    required int timeSeconds,
    int timeThresholdSeconds = 120,
  }) {
    if (!isVictory) return 0;
    int stars = 1;
    if (hpPercent >= 0.5) stars++;
    if (timeSeconds <= timeThresholdSeconds) stars++;
    return stars;
  }

  // --- Formatting Utilities ---

  /// Formats time in seconds to mm:ss string
  static String formatDuration(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Formats large numbers with commas (e.g. 1,500,000)
  static String formatNumber(int number) {
    return number.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }

  /// Compact formatting for gold and XP (e.g. 1.2k, 4.5M)
  static String formatCompactNumber(num number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}k';
    }
    return number.toString();
  }

  // --- Cryptography & Security ---

  /// Generates a cryptographically secure random base64 salt
  static String generateSalt([int length = 16]) {
    final random = Random.secure();
    final values = List<int>.generate(length, (_) => random.nextInt(256));
    return base64Url.encode(values);
  }

  /// Hashes a password with SHA-256 and salt
  static String hashPassword(String password, String salt) {
    final bytes = utf8.encode(password + salt);
    return sha256.convert(bytes).toString();
  }

  // --- Haptic Feedback Helpers ---

  static void hapticLight() {
    try {
      HapticFeedback.lightImpact();
    } catch (_) {}
  }

  static void hapticMedium() {
    try {
      HapticFeedback.mediumImpact();
    } catch (_) {}
  }

  static void hapticHeavy() {
    try {
      HapticFeedback.heavyImpact();
    } catch (_) {}
  }

  static void hapticSelection() {
    try {
      HapticFeedback.selectionClick();
    } catch (_) {}
  }

  // --- Validation Helpers ---

  static String? validateUsername(String? val) {
    if (val == null || val.trim().isEmpty) {
      return 'Please enter username';
    }
    if (val.trim().length < 3) {
      return 'Username must be at least 3 characters';
    }
    return null;
  }

  static String? validatePassword(String? val) {
    if (val == null || val.isEmpty) {
      return 'Please enter password';
    }
    if (val.length < 5) {
      return 'Password must be at least 5 characters';
    }
    return null;
  }
}
