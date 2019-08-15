import 'package:flutter/material.dart';
import 'package:flutter_github_app/widget/gsy_tabbar_widget.dart';
import 'package:flutter_github_app/common/style/gsy_style.dart';
import 'package:flutter_github_app/widget/gsy_title_bar.dart';
import 'package:flutter_github_app/common/utils/common_utils.dart';
import 'package:flutter_github_app/widget/home_drawer.dart';
import 'dynamic_page.dart';
import 'trend_page.dart';
import 'my_page.dart';

class HomePage extends StatelessWidget {
  static const String sName = 'home';

  _renderTab(icon, text) {
    return Tab(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[Icon(icon, size: 16.0), Text(text)],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> tabs = [
      _renderTab(GSYICons.MAIN_DT, CommonUtils.getLocale(context).home_dynamic),
      _renderTab(GSYICons.MAIN_QS, CommonUtils.getLocale(context).home_trend),
      _renderTab(GSYICons.MAIN_MY, CommonUtils.getLocale(context).home_my),
    ];

    return GSYTabBarWidget(
      drawer: HomeDrawer(),
      type: GSYTabBarWidget.BOTTOM_TAB,
      tabItems: tabs,
      tabViews: [
        DynamicPage(),
        TrendPage(),
        MyPage(),
      ],
      backgroundColor: GSYColors.primarySwatch,
      indicatorColor: Color(GSYColors.white),
      title: GSYTitleBar(
        'Flutter Github App',
        iconData: GSYICons.MAIN_SEARCH,
        needRightLocalIcon: true,
        onPressed: () {
          print('tap title bar');
        },
      ),
    );
  }
}
