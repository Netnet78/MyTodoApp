import 'dart:math';

import 'package:flutter/material.dart';

class SmoothCircularNotchedRectangle extends NotchedShape {
  final double notchRadius;
  final double borderRadius;

  SmoothCircularNotchedRectangle({
    this.notchRadius = 28.0,  // FAB radius + some margin
    this.borderRadius = 30.0, // Nav bar corner radius
  });

  @override
  Path getOuterPath(Rect host, Rect? guest) {
    if (guest == null || !host.overlaps(guest)) {
      // No FAB, just draw rounded rect
      return Path()
        ..addRRect(RRect.fromRectAndRadius(host, Radius.circular(borderRadius)));
    }

    final notchCenterX = guest.center.dx;
    final notchRadius = this.notchRadius;
    const s1 = 15.0;
    const s2 = 1.0;

    final r = notchRadius;
    final a = -1.0 * r - s2;
    final b = host.top - guest.center.dy;

    // Calculate control points for smooth Bezier curves
    final n2 = sqrt(b * b * (a * a - r * r)) / a;

    final p1 = Offset(notchCenterX + n2, host.top);
    final p2 = Offset(notchCenterX - n2, host.top);

    final path = Path();
    path.moveTo(host.left + borderRadius, host.top);
    path.arcToPoint(Offset(host.left, host.top + borderRadius),
        radius: Radius.circular(borderRadius));
    path.lineTo(host.left, host.bottom - borderRadius);
    path.arcToPoint(Offset(host.left + borderRadius, host.bottom),
        radius: Radius.circular(borderRadius));
    path.lineTo(host.right - borderRadius, host.bottom);
    path.arcToPoint(Offset(host.right, host.bottom - borderRadius),
        radius: Radius.circular(borderRadius));
    path.lineTo(host.right, host.top + borderRadius);
    path.arcToPoint(Offset(host.right - borderRadius, host.top),
        radius: Radius.circular(borderRadius));
    path.lineTo(p1.dx, host.top);

    // Draw smooth notch curve (concave)
    path.quadraticBezierTo(
      notchCenterX,
      guest.top - s1,
      p2.dx,
      host.top,
    );

    path.lineTo(host.left + borderRadius, host.top);
    path.close();

    return path;
  }
}
