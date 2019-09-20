import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_github_app/common/dao/repos_dao.dart';
import 'package:flutter_github_app/common/model/RepoCommit.dart';
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
import 'package:flutter_github_app/widget/gsy_select_item_widget.dart';
import 'package:flutter_github_app/widget/repos_header_item.dart';
import 'package:scoped_model/scoped_model.dart';

class ReposDetailInfoPage extends StatefulWidget {
  final String userName;

  final String repoName;

  final OptionControl titleOptionControl;

  ReposDetailInfoPage(this.userName, this.repoName, this.titleOptionControl,
      {Key key})
      : super(key: key);

  @override
  ReposDetailInfoPageState createState() => ReposDetailInfoPageState();
}

class ReposDetailInfoPageState extends State<ReposDetailInfoPage>
    with
        AutomaticKeepAliveClientMixin<ReposDetailInfoPage>,
        GSYListStateMixin<ReposDetailInfoPage>,
        TickerProviderStateMixin {
  ///滑动监听
  final ScrollController scrollController = ScrollController();

  ///当前显示tab
  int selectIndex = 0;

  ///初始化 header 默认大小，后面动态调整
  double headerSize = 270;

  ///NestedScrollView 的刷新状态 GlobalKey ，方便主动刷新使用
  final GlobalKey<NestedScrollViewRefreshIndicatorState> refreshIKey =
      GlobalKey<NestedScrollViewRefreshIndicatorState>();

  ///动画控制
  AnimationController animationController;

  @override
  showRefreshLoading() {
    Future.delayed(Duration(seconds: 0), () {
      refreshIKey.currentState.show().then((e) {});
      return true;
    });
  }

  ///渲染时间Item或者提交Item
  _renderEventItem(index) {
    if (selectIndex == 1) {
      ///提交
      return EventItem(
        EventViewModel.fromCommitMap(pullLoadWidgetControl.dataList[index]),
        needImage: false,
        onPressed: () {
          RepoCommit model = pullLoadWidgetControl.dataList[index];
          //NavigatorUtils.goPushDetailPage(context, widget.userName, widget.repoName, model.sha, false);
        },
      );
    }
    return EventItem(
      EventViewModel.fromEventMap(pullLoadWidgetControl.dataList[index]),
      onPressed: () {
        EventUtils.ActionUtils(context, pullLoadWidgetControl.dataList[index],
            widget.userName + "/" + widget.repoName);
      },
    );
  }

  ///获取列表
  _getDataLogic() async {
    if (selectIndex == 1) {
      return await ReposDao.getReposCommitsDao(
        widget.userName,
        widget.repoName,
        page: page,
        branch: ReposDetailModel.of(context).currentBranch,
        needDb: page <= 1,
      );
    }
    return await ReposDao.getRepositoryEventDao(
      widget.userName,
      widget.repoName,
      page: page,
      branch: ReposDetailModel.of(context).currentBranch,
      needDb: page <= 1,
    );
  }

  ///获取详情信息
  _getReposDetail() {
    ReposDao.getRepositoryDetailDao(
      widget.userName,
      widget.repoName,
      ReposDetailModel.of(context).currentBranch,
    ).then((result) {
      if (result != null && result.result) {
        setState(() {
          widget.titleOptionControl.url = result.data.htmlUrl;
        });
        ReposDetailModel.of(context).repository = result.data;
        return result.next();
      }
      return Future.value(null);
    }).then((result) {
      if (result != null && result.result) {
        if (!isShow) {
          return;
        }
        setState(() {
          widget.titleOptionControl.url = result.data.htmlUrl;
        });
        ReposDetailModel.of(context).repository = result.data;
      }
    });
  }

  @override
  bool get wantKeepAlive => true;

  @override
  requestRefresh() async {
    _getReposDetail();
    return await _getDataLogic();
  }

  @override
  requestLoadMore() async {
    return await _getDataLogic();
  }

  @override
  bool get isRefreshFirst => true;

  @override
  bool get needHeader => false;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ScopedModelDescendant<ReposDetailModel>(
      builder: (context, child, model) {
        return GSYNestedPullLoadWidget(
          pullLoadWidgetControl,
          (BuildContext context, int index) => _renderEventItem(index),
          handleRefresh,
          onLoadMore,
          refreshKey: refreshIKey,
          scrollController: scrollController,
          headerSliverBuilder: (context, _) {
            return _sliverBuilder(context, _);
          },
        );
      },
    );
  }

  ///绘制内置Header，支持部分停靠支持
  List<Widget> _sliverBuilder(BuildContext context, bool innerBoxIsScrolled) {
    return <Widget>[
      ///头部信息
      SliverPersistentHeader(
        delegate: GSYSliverHeaderDelegate(
          minHeight: headerSize,
          maxHeight: headerSize,
          snapConfig: FloatingHeaderSnapConfiguration(
            vsync: this,
            curve: Curves.bounceInOut,
            duration: const Duration(milliseconds: 10),
          ),
          child: ReposHeaderItem(
            ReposHeaderViewModel.fromHttpMap(
              widget.userName,
              widget.repoName,
              ReposDetailModel.of(context).repository,
            ),
            layoutListener: (size) {
              setState(() {
                headerSize = size.height;
              });
            },
          ),
        ),
      ),

      ///动态缩放的tab控件
      SliverPersistentHeader(
        pinned: true,
        delegate: GSYSliverHeaderDelegate(
            minHeight: 50,
            maxHeight: 50,
            snapConfig: FloatingHeaderSnapConfiguration(
              vsync: this,
              curve: Curves.bounceInOut,
              duration: const Duration(milliseconds: 10),
            ),
            builder: (BuildContext context, double shrinkOffset, bool overlapsContent) {
              ///根据数值计算偏差
              var lr = 10 - shrinkOffset / 50 * 10;
              var radius = Radius.circular(4 - shrinkOffset / 50 * 4);
              return SizedBox.expand(
                child: Padding(
                  padding: EdgeInsets.only(left: lr, right: lr, bottom: 10),
                  child: GSYSelectItemWidget(
                    [
                      CommonUtils.getLocale(context).repos_tab_activity,
                      CommonUtils.getLocale(context).repos_tab_commits,
                    ],
                    (index) {
                      ///切换时先滑动
                      scrollController.animateTo(
                        0,
                        duration: Duration(milliseconds: 200),
                        curve: Curves.bounceInOut,
                      ).then((_) {
                        selectIndex = index;
                        clearData();
                        showRefreshLoading();
                      });
                    },
                    margin: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(radius),
                    ),
                  ),
                ),
              );
            }
        ),
      ),
    ];
  }
}
