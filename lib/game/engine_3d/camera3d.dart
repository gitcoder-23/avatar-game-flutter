import 'dart:math';
import 'vector3d.dart';

class Camera3D {
  Vector3D position = Vector3D(0, 180, -320);
  Vector3D target = Vector3D.zero();

  double yaw = 0.0; // Horizontal rotation
  double pitch = 0.28; // Vertical downward tilt (radians)
  double distance = 340.0; // Distance behind Spider-Man
  double heightOffset = 120.0; // Elevation above player
  double focalLength = 520.0; // Perspective FOV strength

  double shakeIntensity = 0.0;
  double shakeDuration = 0.0;
  final Random _random = Random();

  void update(Vector3D heroPos, double heroFacingAngle, double dt) {
    // 1. Decay Screen Shake
    if (shakeDuration > 0) {
      shakeDuration -= dt;
      if (shakeDuration <= 0) {
        shakeIntensity = 0.0;
      }
    }

    // 2. Smoothly align camera yaw with Spider-Man's orientation (smooth over-the-shoulder view)
    final targetYaw = heroFacingAngle - (pi / 2);
    final diff = _normalizeAngle(targetYaw - yaw);
    yaw += diff * min(1.0, dt * 4.5);

    // 3. Smooth Target Tracking
    target.x += (heroPos.x - target.x) * min(1.0, dt * 10.0);
    target.y += (heroPos.y - target.y) * min(1.0, dt * 10.0);
    target.z += (heroPos.z - target.z) * min(1.0, dt * 10.0);

    // 4. Compute 3D Camera Orbit Position
    final cosP = cos(pitch);
    final sinP = sin(pitch);
    final sinY = sin(yaw);
    final cosY = cos(yaw);

    double camX = target.x - (sinY * cosP * distance);
    double camY = target.y + heightOffset + (sinP * distance);
    double camZ = target.z - (cosY * cosP * distance);

    if (shakeDuration > 0) {
      camX += (_random.nextDouble() * 2 - 1) * shakeIntensity;
      camY += (_random.nextDouble() * 2 - 1) * shakeIntensity;
      camZ += (_random.nextDouble() * 2 - 1) * shakeIntensity;
    }

    position.x = camX;
    position.y = camY;
    position.z = camZ;
  }

  void triggerShake({required double intensity, required double duration}) {
    shakeIntensity = intensity;
    shakeDuration = duration;
  }

  double _normalizeAngle(double a) {
    while (a < -pi) {
      a += 2 * pi;
    }
    while (a > pi) {
      a -= 2 * pi;
    }
    return a;
  }
}
