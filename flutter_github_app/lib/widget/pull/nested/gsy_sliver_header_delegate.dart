import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

typedef Widget Builder(
    BuildContext context, double shrinkOffset, bool overlapsContent);

///动态头部处理
class GSYSliverHeaderDelegate extends SliverPersistentHeaderDelegate {

  final double minHeight;
  final double maxHeight;
  final Widget child;
  final Builder builder;
  final bool changeSize;
  final FloatingHeaderSnapConfiguration snapConfig;

  GSYSliverHeaderDelegate({
    @required this.minHeight,
    @required this.maxHeight,
    @required this.snapConfig,
    this.child,
    this.builder,
    this.changeSize = false,
  });

  AnimationController animationController;

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => math.max(minHeight, maxHeight);

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }

  @override
  FloatingHeaderSnapConfiguration get snapConfiguration => snapConfig;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    if (builder != null) {
      return builder(context, shrinkOffset, overlapsContent);
    }
    return child;
  }

}