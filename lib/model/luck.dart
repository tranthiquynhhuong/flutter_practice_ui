import 'dart:ui';

class Luck {
  final String image;
  final Color color;
  int index;
  double start;
  double end;

  Luck(this.image, this.color, this.index, this.start, this.end);

  String get asset => "asset/image/$image.png";
}
