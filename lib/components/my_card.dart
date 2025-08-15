import 'package:flutter/material.dart';

class MyCard extends StatelessWidget {
  final Color borderColor;
  final double borderRadius;
  final double borderWidth;
  final double boxShadowOffsetX;
  final double boxShadowOffsetY;
  final double boxShadowBlurRadius;
  final Color boxShadowColor;
  final Color backgroundColor;
  final double? width;
  final double? height;
  final double padding;
  final Widget child;

  const MyCard({
    super.key,
    this.borderColor = Colors.transparent,
    this.borderRadius = 0.0,
    this.borderWidth = 0.0,
    this.boxShadowOffsetX = 0.0,
    this.boxShadowOffsetY = 0.0,
    this.boxShadowBlurRadius = 0.0,
    this.boxShadowColor = Colors.transparent,
    this.backgroundColor = Colors.white,
    this.width,
    this.height,
    this.padding = 0.0, 
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      width: width,
      height: height,
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
        border: Border.all(
            color: borderColor,
            width: borderWidth,
        ),
        boxShadow: [BoxShadow(
          color: boxShadowColor,
          blurRadius: boxShadowBlurRadius,
          offset: Offset(boxShadowOffsetX, boxShadowOffsetY),
        )],
        color: backgroundColor,
      ),
      child: child,
    );
  }
}