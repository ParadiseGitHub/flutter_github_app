import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter_github_app/common/style/gsy_style.dart';
import 'package:flutter_github_app/common/utils/navigator_utils.dart';
import 'package:flutter_github_app/common/redux/gsy_state.dart';

class WelcomePage extends StatefulWidget {
  static final String sName = '/';

  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  bool hadInit = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (hadInit) {
      return;
    }

    hadInit = true;
    Store<GSYState> store = StoreProvider.of(context);
    Future.delayed(const Duration(seconds: 2, milliseconds: 500), () {
      NavigatorUtils.goLogin(context);
      return true;
    });

  }

  @override
  Widget build(BuildContext context) {
    return StoreBuilder<GSYState>(
      builder: (context, store) {
        double size = 200.0;
        return Container(
          color: Color(GSYColors.white),
          child: Stack(
            children: <Widget>[
              Center(child: Image(image: AssetImage('static/images/welcome.png'))),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: size,
                  height: size,
                  child: FlareActor(
                    "static/file/flare_flutter_logo_.flr",
                    alignment: Alignment.topCenter,
                    animation: "Placeholder",
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
