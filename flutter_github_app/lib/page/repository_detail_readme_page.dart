import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_github_app/common/dao/repos_dao.dart';
import 'package:flutter_github_app/common/style/gsy_style.dart';
import 'package:flutter_github_app/common/utils/common_utils.dart';
import 'package:flutter_github_app/widget/gsy_markdown_widget.dart';
import 'package:flutter_github_app/page/repository_detail_page.dart';
import 'package:scoped_model/scoped_model.dart';

class RepositoryDetailReadmePage extends StatefulWidget {

  final String userName;

  final String repoName;

  RepositoryDetailReadmePage(this.userName, this.repoName, {Key key}) : super(key: key);

  @override
  RepositoryDetailReadmePageState createState() => RepositoryDetailReadmePageState();
}

class RepositoryDetailReadmePageState extends State<RepositoryDetailReadmePage> with AutomaticKeepAliveClientMixin {

  bool isShow = false;

  String markdownData;

  RepositoryDetailReadmePageState();

  refreshReadme() {
    ReposDao.getRepositoryDetailReadmeDao(widget.userName, widget.repoName, ReposDetailModel.of(context).currentBranch).then((res) {
      if (res != null && res.result) {
        if (isShow) {
          setState(() {
            markdownData = res.data;
          });
          return res.next?.call();
        }
      }
      return new Future.value(null);
    }).then((res) {
      if (res != null && res.result) {
        if (isShow) {
          setState(() {
            markdownData = res.data;
          });
        }
      }
    });
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    isShow = true;
    super.initState();
    refreshReadme();
  }

  @override
  void dispose() {
    isShow = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    var widget = (markdownData == null)
      ? Center(
          child: Container(
            width: 200,
            height: 200,
            padding: EdgeInsets.all(4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SpinKitDoubleBounce(color: Theme.of(context).primaryColor),
                Container(width: 10.0),
                Container(child: Text(CommonUtils.getLocale(context).loading_text, style: GSYConstant.middleText)),
              ],
            ),
          ),
        )
      : GSYMarkdownWidget(markdownData: markdownData);
    return ScopedModelDescendant<ReposDetailModel>(
      builder: (context, child, model) => widget,
    );
  }
}
