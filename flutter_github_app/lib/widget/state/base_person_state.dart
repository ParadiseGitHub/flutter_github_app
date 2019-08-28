import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:flutter_github_app/common/dao/user_dao.dart';
import 'package:flutter_github_app/widget/state/gsy_list_state.dart';


abstract class BasePersonState<T extends StatefulWidget> extends State<T> with
    AutomaticKeepAliveClientMixin<T>, GSYListState<T> ,SingleTickerProviderStateMixin{

}

/// Provider HonorModel
class HonorModel extends ChangeNotifier {
  int _beStaredCount;

  int get beStaredCount => _beStaredCount;

  set beStaredCount(int value) {
    _beStaredCount = value;
    notifyListeners();
  }

  List _honorList;

  List get honorList => _honorList;

  set honorList(List value) {
    _honorList = value;
    notifyListeners();
  }
}