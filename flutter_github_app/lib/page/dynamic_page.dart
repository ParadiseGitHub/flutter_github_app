import 'package:flutter/material.dart';
import 'package:redux/redux.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_github_app/common/redux/gsy_state.dart';
import 'package:flutter_github_app/bloc/dynamic_bloc.dart';
import 'package:flutter_github_app/widget/pull/gsy_pull_new_load_widget.dart';

import 'package:flutter_github_app/widget/event_item.dart';
import 'package:flutter_github_app/common/model/Event.dart';
import 'package:flutter_github_app/common/utils/event_utils.dart';


class DynamicPage extends StatefulWidget {
  @override
  _DynamicPageState createState() => _DynamicPageState();
}

class _DynamicPageState extends State<DynamicPage> with AutomaticKeepAliveClientMixin<DynamicPage>, WidgetsBindingObserver {

  ///AutomaticKeepAlive
  @override
  bool get wantKeepAlive => true;

  ///监听生命周期，resumed的时候触发刷新
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      showRefreshLoading();
    }
  }

  final DynamicBloc dynamicBloc = DynamicBloc();

  ///控制列表滚动和监听
  final ScrollController scrollController = ScrollController();

  final GlobalKey<RefreshIndicatorState> refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();

  ///模拟IOS下拉显示刷新
  showRefreshLoading() {
    ///直接触发下拉
    Future.delayed(Duration(milliseconds: 500), () {
      scrollController.animateTo(-141, duration: Duration(milliseconds: 600), curve: Curves.linear);
    });
  }

  ///下拉刷新数据
  Future<void> requestRefresh() async {
    return await dynamicBloc.requestRefresh(_getStore().state.userInfo?.login);
  }

  ///上拉加载更多
  Future<void> requestLoadMore() async {
    return await dynamicBloc.requestLoadMore(_getStore().state.userInfo?.login);
  }

  Store<GSYState> _getStore() {
    return StoreProvider.of(context);
  }

  _renderEventItem(Event e) {
    EventViewModel eventViewModel = EventViewModel.fromEventMap(e);
    return EventItem(
      eventViewModel,
      onPressed: () {
        EventUtils.ActionUtils(context, e, "");
      },
    );
  }

  @override
  void initState() {
    super.initState();
    ///监听生命周期，主要判断页面 resumed 的时候触发刷新
    WidgetsBinding.instance.addObserver(this);

    ///获取网络端新版信息
    //ReposDao.getNewsVersion(context, false);
  }

  @override
  void didChangeDependencies() {
    //请求更新
    if (dynamicBloc.getDataLength() == 0) {
      dynamicBloc.changeNeedHeaderStatus(false);

      //先读取数据库
      dynamicBloc.requestRefresh(_getStore().state.userInfo?.login,
        doNextFlag: false).then((_) {
          showRefreshLoading();
      });
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); //AutomaticKeepAlive
    return GSYPullLoadWidget(
      dynamicBloc.pullLoadWidgetControl,
      (BuildContext context, int index) =>
          _renderEventItem(dynamicBloc.dataList[index]),
      requestRefresh,
      requestLoadMore,
      refreshKey: refreshIndicatorKey,
      scrollController: scrollController,

      //使用ios模式的下拉刷新
      userIos: false,
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    dynamicBloc.dispose();
    super.dispose();
  }
}
