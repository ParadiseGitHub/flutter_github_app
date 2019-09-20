import 'package:bezier/bezier.dart';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math.dart';

class CurveBezier extends Curve {
  final quadraticCurve = QuadraticBezier([
     Vector2(-4.0, 1.0),
     Vector2(-2.0, -1.0),
     Vector2(1.0, 1.0)
  ]);

  @override
  double transformInternal(double t) {
    return quadraticCurve.pointAt(t).s;
  }
}