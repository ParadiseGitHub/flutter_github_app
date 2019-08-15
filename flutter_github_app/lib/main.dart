import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:redux/redux.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_github_app/page/welcome_page.dart';
import 'package:flutter_github_app/page/home_page.dart';
import 'package:flutter_github_app/page/login_page.dart';
import 'package:flutter_github_app/common/redux/gsy_state.dart';
import 'package:flutter_github_app/common/model/User.dart';
import 'package:flutter_github_app/common/utils/common_utils.dart';
import 'package:flutter_github_app/common/style/gsy_style.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_github_app/common/net/code.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_github_app/common/utils/navigator_utils.dart';
import 'package:flutter_github_app/common/event/event_bus.dart';
import 'package:flutter_github_app/common/event/http_error_event.dart';
import 'package:flutter_github_app/common/localization/gsy_localizations_delegate.dart';

void main() => runApp(FlutterReduxApp());

class FlutterReduxApp extends StatelessWidget {
  /// 创建Store，引用 GSYState 中的 appReducer 实现 Reducer 方法
  /// initialState 初始化 State
  final store = Store<GSYState>(
    appReudcer,

    ///初始化数据
    initialState: GSYState(
      userInfo: User.empty(),
      locale: Locale('zh', 'CH'),
      themeData: CommonUtils.getThemeData(GSYColors.primarySwatch),
    ),
  );

  FlutterReduxApp({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StoreProvider(
      store: store,
      child: StoreBuilder<GSYState>(builder: (context, store) {
        return MaterialApp(
          localizationsDelegates: [
            GlobalMaterialLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GSYLocalizationsDelegate.delegate,
          ],
          locale: store.state.locale,
          supportedLocales: [store.state.locale],
          theme: store.state.themeData,
          routes: {
            WelcomePage.sName: (context) {
              store.state.platformLocale = Localizations.localeOf(context);
              return WelcomePage();
            },
            HomePage.sName: (context) {
              return GSYLocalizations(child: NavigatorUtils.pageContainer(HomePage()));
            },
            LoginPage.sName: (context) {
              return GSYLocalizations(child: NavigatorUtils.pageContainer(LoginPage()));
            }
          },
        );
      }),
    );
  }
}

class GSYLocalizations extends StatefulWidget {
  final Widget child;

  GSYLocalizations({Key key, this.child}) : super(key: key);

  @override
  State<GSYLocalizations> createState() {
    return _GSYLocalizations();
  }
}

class _GSYLocalizations extends State<GSYLocalizations> {
  StreamSubscription stream;

  @override
  Widget build(BuildContext context) {
    return StoreBuilder<GSYState>(
      builder: (context, store) {
        ///通过 StoreBuilder 和 Localizations 实现实时多语言切换
        return Localizations.override(
          context: context,
          locale: store.state.locale,
          child: widget.child,
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();

    ///Stream演示event bus
    stream = eventBus.on<HttpErrorEvent>().listen((event) {
      errorHandleFunction(event.code, event.message);
    });
  }

  @override
  void dispose() {
    super.dispose();
    if (stream != null) {
      stream.cancel();
      stream = null;
    }
  }

  ///网络错误提醒
  errorHandleFunction(int code, message) {
    switch (code) {
      case Code.NETWORK_ERROR:
        Fluttertoast.showToast(msg: CommonUtils.getLocale(context).network_error);
        break;
      case 401:
        Fluttertoast.showToast(msg: CommonUtils.getLocale(context).network_error_401);
        break;
      case 403:
        Fluttertoast.showToast(
            msg: CommonUtils.getLocale(context).network_error_403);
        break;
      case 404:
        Fluttertoast.showToast(
            msg: CommonUtils.getLocale(context).network_error_404);
        break;
      case Code.NETWORK_TIMEOUT:
      //超时
        Fluttertoast.showToast(
            msg: CommonUtils.getLocale(context).network_error_timeout);
        break;
      default:
        Fluttertoast.showToast(
            msg: CommonUtils.getLocale(context).network_error_unknown +
                " " +
                message);
        break;
    }
  }
}


