import 'package:flutter/material.dart';
import 'package:flutter_github_app/common/style/gsy_style.dart';
import 'package:flutter_github_app/common/utils/navigator_utils.dart';

class LoginPage extends StatefulWidget {
  static final String sName = 'login';

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(GSYColors.white),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Login', style: TextStyle(fontSize: 24, fontWeight: FontWeight.normal, color: Theme.of(context).primaryColor)),
            FlatButton(
              child: Text('GoHome', style: TextStyle(color: Colors.blue),),
              onPressed: () {
                NavigatorUtils.goHome(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
