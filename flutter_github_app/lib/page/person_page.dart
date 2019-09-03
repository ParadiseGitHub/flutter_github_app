import 'package:flutter/material.dart';

class PersonPage extends StatefulWidget {

  static final String sName = "person";

  final String userName;

  PersonPage(this.userName, {Key key}) : super(key: key);

  @override
  _PersonPageState createState() => _PersonPageState(userName);
}

class _PersonPageState extends State<PersonPage> {

  final String userName;

  _PersonPageState(this.userName);

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
