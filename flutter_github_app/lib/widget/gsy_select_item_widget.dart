import 'package:flutter/material.dart';
import 'package:flutter_github_app/widget/gsy_card_item.dart';
import 'package:flutter_github_app/common/style/gsy_style.dart';

///详情issue列表头部，PreferredSizeWidget

typedef void SelectItemChanged<int>(int value);

class GSYSelectItemWidget extends StatefulWidget implements PreferredSizeWidget {

  final List<String> itemNames;

  final SelectItemChanged selectItemChanged;

  final RoundedRectangleBorder shape;

  final double elevation;

  final double height;

  final EdgeInsets margin;

  GSYSelectItemWidget(
    this.itemNames,
    this.selectItemChanged, {
    this.shape,
    this.height = 7.0,
    this.elevation = 5.0,
    this.margin = const EdgeInsets.all(10.0),
  });

  @override
  _GSYSelectItemWidgetState createState() => _GSYSelectItemWidgetState();

  @override
  Size get preferredSize {
    return Size.fromHeight(height);
  }
}

class _GSYSelectItemWidgetState extends State<GSYSelectItemWidget> {

  int selectIndex = 0;

  _GSYSelectItemWidgetState();

  _renderItem(String name, int index) {
    var style = index == selectIndex ? GSYConstant.middleTextWhite : GSYConstant.middleSubLightText;
    return Expanded(
      child: RawMaterialButton(
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        constraints: const BoxConstraints(minWidth: 0.0, minHeight: 0.0),
        padding: EdgeInsets.all(10.0),
        child: Text(name, style: style, textAlign: TextAlign.center),
        onPressed: () {
          if (selectIndex != index) {
            widget.selectItemChanged?.call(index);
          }
          setState(() {
            selectIndex = index;
          });
        },
      ),
    );
  }

  _renderList() {
    List<Widget> list = List();
    for (int i = 0; i < widget.itemNames.length; i++) {
      if (i == widget.itemNames.length - 1) {
        list.add(_renderItem(widget.itemNames[i], i));
      } else {
        list.add(_renderItem(widget.itemNames[i], i));
        list.add(Container(width: 1.0, height: 25.0, color: Color(GSYColors.subLightTextColor)));
      }
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return GSYCardItem(
      elevation: widget.elevation,
      margin: widget.margin,
      color: Theme.of(context).primaryColor,
      shape: widget.shape ?? RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4.0))),
      child: Row(
        children: _renderList(),
      ),
    );
  }
}
