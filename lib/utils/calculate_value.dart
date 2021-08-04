import 'package:flutter/material.dart';
import 'package:interpolate/interpolate.dart';

double calculateInterpolate({List<double> lstInputRange, List<double> lstOutputRange, @required double val}) {
  Interpolate interpolate = Interpolate(
    inputRange: lstInputRange ?? [0, 1, 0],
    outputRange: lstOutputRange,
    extrapolate: Extrapolate.clamp,
  );
  return interpolate.eval(val);
}
