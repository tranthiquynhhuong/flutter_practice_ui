
import 'package:flutter/material.dart';
import 'package:flutter_practice_ui/ui/fortune_wheel/circle_fortune_wheel/flutter_fortune_wheel/core/core.dart';

class FortuneBarItem extends StatelessWidget {
  final Widget child;
  final FortuneItemStyle style;

  const FortuneBarItem({
    Key key,
    @required this.child,
    @required this.style,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.symmetric(
          horizontal: BorderSide(
            color: style.borderColor,
            width: style.borderWidth / 2,
          ),
          vertical: BorderSide(
            color: style.borderColor,
            width: style.borderWidth / 4,
          ),
        ),
        color: style.color,
      ),
      child: Center(
        child: DefaultTextStyle(
          textAlign: style.textAlign,
          style: style?.textStyle ?? TextStyle(),
          child: child,
        ),
      ),
    );
  }
}
