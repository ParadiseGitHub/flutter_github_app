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
}