import 'package:flutter/material.dart';

/**
 * 带图标Icon的文本，可调节
 */

class GSYIconText extends StatelessWidget {

  final String iconText;
  final IconData iconData;
  final TextStyle textStyle;
  final Color iconColor;
  final double padding;
  final double iconSize;
  final VoidCallback onPressed;
  final MainAxisAlignment mainAxisAlignment;
  final MainAxisSize mainAxisSize;
  final double textWidth;

  GSYIconText(
      this.iconData,
      this.iconText,
      this.textStyle,
      this.iconColor,
      this.iconSize, {
        this.padding = 0.0,
        this.onPressed,
        this.mainAxisAlignment = MainAxisAlignment.start,
        this.mainAxisSize = MainAxisSize.max,
        this.textWidth = -1,
      });

  @override
  Widget build(BuildContext context) {
    Widget showText = (textWidth == -1)
        ? Container(
            child: Text(
              iconText ?? "",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textStyle.merge(TextStyle(textBaseline: TextBaseline.alphabetic)),
            ),
          )
        : Container(
            width: textWidth,
            child: Text(
              iconText,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textStyle.merge(TextStyle(textBaseline: TextBaseline.alphabetic)),
            ),
          );

    return Container(
      child: Row(
        textBaseline: TextBaseline.alphabetic,
        mainAxisAlignment: mainAxisAlignment,
        mainAxisSize: mainAxisSize,
        crossAxisAlignment: CrossAxisAlignment.baseline,
        children: <Widget>[
          Icon(
            iconData,
            size: iconSize,
            color: iconColor,
          ),
          Padding(padding: EdgeInsets.all(padding)),
          showText
        ],
      ),
    );
  }
}
