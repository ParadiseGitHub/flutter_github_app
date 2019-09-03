import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:redux/redux.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_github_app/common/redux/locale_redux.dart';
import 'package:flutter_github_app/common/redux/gsy_state.dart';
import 'package:flutter_github_app/common/net/address.dart';
import 'package:flutter_github_app/common/redux/theme_redux.dart';
import 'package:flutter_github_app/widget/gsy_flex_button.dart';
import 'package:flutter_github_app/common/style/gsy_style.dart';
import 'package:flutter_github_app/common/utils/navigator_utils.dart';
import 'package:flutter_github_app/common/style/gsy_string_base.dart';
import 'package:flutter_github_app/common/localization/default_localizations.dart';

class CommonUtils {

  static final double MILLIS_LIMIT = 1000.0;

  static final double SECONDS_LIMIT = 60 * MILLIS_LIMIT;

  static final double MINUTES_LIMIT = 60 * SECONDS_LIMIT;

  static final double HOURS_LIMIT = 24 * MINUTES_LIMIT;

  static final double DAYS_LIMIT = 30 * HOURS_LIMIT;

  static String getDateStr(DateTime date) {
    if (date == null || date.toString() == null) {
      return "";
    } else if (date.toString().length < 10) {
      return date.toString();
    }
    return date.toString().substring(0, 10);
  }
  
  static String getUserChartAddress(String userName) {
    return Address.graphicHost + GSYColors.primaryValueString.replaceAll("#", "") + "/" + userName;
  }

  ///日期格式转换
  static String getNewsTimeStr(DateTime date) {
    int subTime = DateTime.now().millisecondsSinceEpoch - date.millisecondsSinceEpoch;

    if (subTime < MILLIS_LIMIT) {
      return "刚刚";
    } else if (subTime < SECONDS_LIMIT) {
      return (subTime / MILLIS_LIMIT).round().toString() + " 秒前";
    } else if (subTime < MINUTES_LIMIT) {
      return (subTime / SECONDS_LIMIT).round().toString() + " 分前";
    } else if (subTime < HOURS_LIMIT) {
      return (subTime / MINUTES_LIMIT).round().toString() + " 小时前";
    } else if (subTime < DAYS_LIMIT) {
      return (subTime / HOURS_LIMIT).round().toString() + " 天前";
    } else {
      return getDateStr(date);
    }
  }

  ///列表item dialog
  static Future<Null> showCommitOptionDialog(
    BuildContext context,
    List<String> commitMaps,
    ValueChanged<int> onTap, {
    width = 250.0,
    height = 360.0,
    List<Color> colorList,
    }) {
    return NavigatorUtils.showGSYDialog(
      context: context,
      builder: (BuildContext context) {
        return Center(
          child: Container(
            width: width,
            height: height,
            padding: EdgeInsets.all(5.0),
            margin: EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: Color(GSYColors.white),
              borderRadius: BorderRadius.circular(5.0),
            ),
            child: ListView.builder(
              itemCount: commitMaps.length,
              itemBuilder: (context, index) {
                return GSYFlexButton(
                  fontSize: 14.0,
                  color: colorList != null
                    ? colorList[index]
                    : Theme.of(context).primaryColor,
                  text: commitMaps[index],
                  textColor: Color(GSYColors.white),
                  onPress: () {
                    Navigator.pop(context);
                    onTap(index);
                  },
                );
              },
            ),
          ),
        );
      }
    );
  }

  static Future<Null> showLoadingDialog(BuildContext context) {
    return NavigatorUtils.showGSYDialog(
        context: context,
        builder: (BuildContext context) {
          return new Material(
              color: Colors.transparent,
              child: WillPopScope(
                onWillPop: () => new Future.value(false),
                child: Center(
                  child: new Container(
                    width: 200.0,
                    height: 200.0,
                    padding: new EdgeInsets.all(4.0),
                    decoration: new BoxDecoration(
                      color: Colors.transparent,
                      //用一个BoxDecoration装饰器提供背景图片
                      borderRadius: BorderRadius.all(Radius.circular(4.0)),
                    ),
                    child: new Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        new Container(
                            child:
                            SpinKitCubeGrid(color: Color(GSYColors.white))),
                        new Container(height: 10.0),
                        new Container(
                            child: new Text(
                                CommonUtils.getLocale(context).loading_text,
                                style: GSYConstant.normalTextWhite)),
                      ],
                    ),
                  ),
                ),
              ));
        });
  }

  static GSYStringBase getLocale(BuildContext context) {
    return GSYLocalizations.of(context).currentLocalized;
  }

  static changeLocale(Store<GSYState> store, int index) {
    Locale locale = store.state.platformLocale;
    switch (index) {
      case 1:
        locale = Locale('zh', 'CH');
        break;
      case 2:
        locale = Locale('en', 'US');
        break;
    }
    store.dispatch(RefreshLocaleAction(locale));
  }

  static List<Color> getThemeListColor() {
    return [
      GSYColors.primarySwatch,
      Colors.brown,
      Colors.blue,
      Colors.teal,
      Colors.amber,
      Colors.blueGrey,
      Colors.deepOrange,
    ];
  }

  static pushTheme(Store store, int index) {
    ThemeData themeData;
    List<Color> colors = getThemeListColor();
    themeData = getThemeData(colors[index]);
    store.dispatch(RefreshThemeDataAction(themeData));
  }

  static ThemeData getThemeData(Color color) {
    return ThemeData(primarySwatch: color, platform: TargetPlatform.iOS);
  }

}