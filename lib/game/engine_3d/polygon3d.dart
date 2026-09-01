import 'package:flutter/material.dart';
import 'vector3d.dart';

class Polygon3D {
  final List<Vector3D> vertices;
  final Color baseColor;
  final Color? strokeColor;
  final double strokeWidth;
  final bool isGlowing;
  final Color? glowColor;
  final bool isDoubleSided;
  final bool isWireframe;

  double depthZ = 0.0;
  List<Offset> projectedPoints = [];
  Color renderedColor = Colors.white;
  bool isVisible = true;

  Polygon3D({
    required this.vertices,
    required this.baseColor,
    this.strokeColor,
    this.strokeWidth = 1.0,
    this.isGlowing = false,
    this.glowColor,
    this.isDoubleSided = true,
    this.isWireframe = false,
  });

  /// Calculate face normal for 3D lighting
  Vector3D get normal {
    if (vertices.length < 3) return Vector3D(0, 1, 0);
    final edge1 = vertices[1] - vertices[0];
    final edge2 = vertices[2] - vertices[0];
    return edge1.cross(edge2).normalized();
  }

  /// Transform and project 3D vertices to 2D screen coordinates with directional lighting
  void project({
    required Vector3D cameraPos,
    required double cameraYaw,
    required double cameraPitch,
    required double focalLength,
    required double screenWidth,
    required double screenHeight,
    required Vector3D lightDir,
  }) {
    projectedPoints.clear();
    double totalZ = 0.0;

    for (var vertex in vertices) {
      // 1. World to Camera Space translation
      final relX = vertex.x - cameraPos.x;
      final relY = vertex.y - cameraPos.y;
      final relZ = vertex.z - cameraPos.z;

      // 2. Rotate by Camera Yaw (around Y axis)
      final yawRot = Vector3D(relX, relY, relZ).rotateY(-cameraYaw);

      // 3. Rotate by Camera Pitch (around X axis)
      final camSpace = yawRot.rotateX(-cameraPitch);

      // Cull vertices behind camera
      if (camSpace.z <= 1.0) {
        isVisible = false;
        return;
      }

      totalZ += camSpace.z;

      // 4. Perspective Projection: (x * f / z, y * f / z)
      final scale = focalLength / camSpace.z;
      final screenX = (camSpace.x * scale) + (screenWidth / 2);
      final screenY = (camSpace.y * scale) + (screenHeight / 2);

      projectedPoints.add(Offset(screenX, screenY));
    }

    isVisible = true;
    depthZ = totalZ / vertices.length;

    // 5. Calculate Directional 3D Lighting & Shading
    final faceNormal = normal;
    final dotLight = faceNormal.dot(lightDir).clamp(0.0, 1.0);
    final lightIntensity = 0.45 + (dotLight * 0.55); // 45% ambient, 55% diffuse

    final r = (baseColor.r * 255.0 * lightIntensity).clamp(0.0, 255.0).toInt();
    final g = (baseColor.g * 255.0 * lightIntensity).clamp(0.0, 255.0).toInt();
    final b = (baseColor.b * 255.0 * lightIntensity).clamp(0.0, 255.0).toInt();
    renderedColor = Color.fromARGB((baseColor.a * 255.0).toInt(), r, g, b);
  }

  void render(Canvas canvas) {
    if (!isVisible || projectedPoints.length < 2) return;

    final path = Path()..moveTo(projectedPoints[0].dx, projectedPoints[0].dy);
    for (int i = 1; i < projectedPoints.length; i++) {
      path.lineTo(projectedPoints[i].dx, projectedPoints[i].dy);
    }
    if (projectedPoints.length > 2) {
      path.close();
    }

    if (isGlowing && glowColor != null) {
      final glowPaint = Paint()
        ..color = glowColor!.withValues(alpha: 0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth * 2.5
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
      canvas.drawPath(path, glowPaint);
    }

    if (!isWireframe && projectedPoints.length > 2) {
      final fillPaint = Paint()
        ..color = renderedColor
        ..style = PaintingStyle.fill;
      canvas.drawPath(path, fillPaint);
    }

    if (strokeColor != null) {
      final strokePaint = Paint()
        ..color = strokeColor!
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth;
      canvas.drawPath(path, strokePaint);
    }
  }
}
