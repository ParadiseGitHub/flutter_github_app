import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_github_app/page/home_page.dart';
import 'package:flutter_github_app/page/login_page.dart';
import 'package:flutter_github_app/page/my_page.dart';
import 'package:flutter_github_app/page/trend_page.dart';
import 'package:flutter_github_app/page/login_page.dart';

class NavigatorUtils {
  // 替换
  static pushReplacementNamed(BuildContext context, String routeName) {
    Navigator.pushReplacementNamed(context, routeName);
  }

  // 切换无参数页面
  static pushNamed(BuildContext context, String routeName) {
    Navigator.pushNamed(context, routeName);
  }

  // 主页
  static goHome(BuildContext context) {
    Navigator.pushReplacementNamed(context, HomePage.sName);
  }

  // 登录页
  static goLogin(BuildContext context) {
    Navigator.pushReplacementNamed(context, LoginPage.sName);
  }

  // Page页面的容器，做一次通用自定义
  static Widget pageContainer(widget) {
    return MediaQuery(
      data: MediaQueryData.fromWindow(WidgetsBinding.instance.window)
        .copyWith(textScaleFactor: 1),
      child: widget,
    );
  }

  static Future<T> showGSYDialog<T>({
    @required BuildContext context,
    bool barrierDismissible = true,
    WidgetBuilder builder,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) {
        return MediaQuery(
          ///不受系统字体缩放影响
          data: MediaQueryData.fromWindow(WidgetsBinding.instance.window)
                .copyWith(textScaleFactor: 1),
          child: SafeArea(child: builder(context)),
        );
      });
  }
}