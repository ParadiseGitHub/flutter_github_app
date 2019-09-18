import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_github_app/common/dao/repos_dao.dart';

import 'package:flutter_github_app/common/utils/common_utils.dart';
import 'package:flutter_github_app/common/utils/event_utils.dart';
import 'package:flutter_github_app/common/utils/navigator_utils.dart';
import 'package:flutter_github_app/page/repository_detail_page.dart';
import 'package:flutter_github_app/widget/event_item.dart';
import 'package:flutter_github_app/widget/gsy_common_option_widget.dart';
import 'package:flutter_github_app/widget/pull/nested/gsy_pull_nested_load_widget.dart';
import 'package:flutter_github_app/widget/pull/nested/gsy_sliver_header_delegate.dart';
import 'package:flutter_github_app/widget/pull/nested/nested_refresh.dart';
import 'package:flutter_github_app/widget/state/gsy_list_state.dart';


import 'package:scoped_model/scoped_model.dart';


class ReposDetailInfoPage extends StatefulWidget {

  final String userName;

  final String repoName;

  final OptionControl titleOptionControl;

  ReposDetailInfoPage(this.userName, this.repoName, this.titleOptionControl, {Key key}) : super(key: key);

  @override
  ReposDetailInfoPageState createState() => ReposDetailInfoPageState();
}

class ReposDetailInfoPageState extends State<ReposDetailInfoPage>
    with
        AutomaticKeepAliveClientMixin<ReposDetailInfoPage>,
       // GSYListStateMixin<ReposDetailInfoPage>,
        TickerProviderStateMixin {

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

