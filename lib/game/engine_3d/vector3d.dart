import 'dart:math';

class Vector3D {
  double x;
  double y;
  double z;

  Vector3D(this.x, this.y, this.z);

  Vector3D.zero() : this(0.0, 0.0, 0.0);

  Vector3D copy() => Vector3D(x, y, z);

  Vector3D operator +(Vector3D v) => Vector3D(x + v.x, y + v.y, z + v.z);
  Vector3D operator -(Vector3D v) => Vector3D(x - v.x, y - v.y, z - v.z);
  Vector3D operator *(double scalar) => Vector3D(x * scalar, y * scalar, z * scalar);
  Vector3D operator /(double scalar) => Vector3D(x / scalar, y / scalar, z / scalar);

  double get length => sqrt(x * x + y * y + z * z);
  double get lengthSquared => x * x + y * y + z * z;

  Vector3D normalized() {
    final len = length;
    if (len == 0) return Vector3D.zero();
    return Vector3D(x / len, y / len, z / len);
  }

  double dot(Vector3D v) => x * v.x + y * v.y + z * v.z;

  Vector3D cross(Vector3D v) {
    return Vector3D(
      y * v.z - z * v.y,
      z * v.x - x * v.z,
      x * v.y - y * v.x,
    );
  }

  double distanceTo(Vector3D v) {
    final dx = x - v.x;
    final dy = y - v.y;
    final dz = z - v.z;
    return sqrt(dx * dx + dy * dy + dz * dz);
  }

  Vector3D rotateY(double angle) {
    final cosA = cos(angle);
    final sinA = sin(angle);
    return Vector3D(
      x * cosA + z * sinA,
      y,
      -x * sinA + z * cosA,
    );
  }

  Vector3D rotateX(double angle) {
    final cosA = cos(angle);
    final sinA = sin(angle);
    return Vector3D(
      x,
      y * cosA - z * sinA,
      y * sinA + z * cosA,
    );
  }

  Vector3D rotateZ(double angle) {
    final cosA = cos(angle);
    final sinA = sin(angle);
    return Vector3D(
      x * cosA - y * sinA,
      x * sinA + y * cosA,
      z,
    );
  }

  @override
  String toString() => 'Vector3D($x, $y, $z)';
}
