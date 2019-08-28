import 'package:flutter/material.dart';
import 'package:redux/redux.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_github_app/common/dao/event_dao.dart';
import 'package:flutter_github_app/common/dao/user_dao.dart';
import 'package:flutter_github_app/common/redux/gsy_state.dart';
import 'package:flutter_github_app/common/redux/user_redux.dart';
import 'package:flutter_github_app/common/style/gsy_style.dart';
import 'package:flutter_github_app/widget/state/base_person_state.dart';
import 'package:flutter_github_app/widget/pull/nested/gsy_pull_nested_load_widget.dart';


class MyPage extends StatefulWidget {
  @override
  _MyPageState createState() => _MyPageState();
}

class _MyPageState extends BasePersonState<MyPage> {
  String beStaredCount = "---";

  Color notifyColor = const Color(GSYColors.subTextColor);

  Store<GSYState> _getStore() {
    if (context == null) {
      return null;
    }
    return StoreProvider.of(context);
  }

  ///从全局状态中获取我的用户名
  _getUserName() {
    if (_getStore()?.state?.userInfo == null) {
      return null;
    }
    return _getStore()?.state?.userInfo?.login;
  }

  ///从全局状态中获取我的用户类型
  getUserType() {
    if (_getStore()?.state?.userInfo == null) {
      return null;
    }
    return _getStore()?.state?.userInfo?.type;
  }

  ///更新通知图标颜色
  _refreshNotify() {
    UserDao.getNotifyDao(false, false, 0).then((res) {
      Color newColor;
      if (res != null && res.result && res.data.length > 0) {
        newColor = Color(GSYColors.actionBlue);
      } else {
        newColor = Color(GSYColors.subTextColor);
      }
      if (isShow) {
        setState(() {
          notifyColor = newColor;
        });
      }
    });
  }

  @override
  bool get wantKeepAlive => true;

  @override
  bool get isRefreshFirst => false;

  @override
  bool get needHeader => false;

  @override
  void initState() {
    pullLoadWidgetControl.needHeader = true;
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Text('我的'),
      ),
    );
  }
}
