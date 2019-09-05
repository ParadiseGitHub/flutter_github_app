import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_github_app/common/config/config.dart';
import 'package:flutter_github_app/widget/pull/gsy_pull_load_widget.dart';

/**
 * 下拉刷新、上拉加载更多：列表通用State
 */

mixin GSYListStateMixin<T extends StatefulWidget> on State<T>, AutomaticKeepAliveClientMixin<T> {

  bool isShow = false;
  bool isLoading = false;
  int page = 1;
  bool isRefreshing = false;
  bool isLoadingMore = false;

  final List dataList = List();

  final GSYPullLoadWidgetControl pullLoadWidgetControl = GSYPullLoadWidgetControl();

  final GlobalKey<RefreshIndicatorState> refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();

  ///if loading, lock to await
  _lockToAwait() async {
    onDelayed() async {
      await Future.delayed(Duration(seconds: 1)).then((_) async {
        if (isLoading) {
          return await onDelayed();
        } else {
          return null;
        }
      });
    }
    await onDelayed();
  }

  showRefreshLoading() {
    Future.delayed(const Duration(seconds: 0), () {
      refreshIndicatorKey.currentState.show().then((e) {});
      return true;
    });
  }

  @protected
  Future<Null> handleRefresh() async {
    if (isLoading) {
      if (isRefreshing) {
        return null;
      }
      await _lockToAwait();
    }

    isLoading = true;
    isRefreshing = true;
    page = 1;
    var res = await requestRefresh();

    resolveRefreshResult(res);
    resolveDataResult(res);

    if (res.next != null) {
      var resNext = await res.next();
      resolveRefreshResult(resNext);
      resolveDataResult(resNext);
    }

    isLoading = false;
    isRefreshing = false;
    return null;
  }

  @protected
  Future<Null> onLoadMore() async {
    if (isLoading) {
      if (isLoadingMore) {
        return null;
      }
      await _lockToAwait();
    }

    isLoading = true;
    isLoadingMore = true;
    page++;
    var res = await requestLoadMore();

    if (res != null && res.result) {
      if (isShow) {
        setState(() {
          pullLoadWidgetControl.dataList.addAll(res.data);
        });
      }
    }

    resolveDataResult(res);
    isLoading = false;
    isLoadingMore = false;
    return null;
  }

  @protected
  resolveRefreshResult(res) {
    if (res != null && res.result) {
      pullLoadWidgetControl.dataList.clear();
      if (isShow) {
        setState(() {
          pullLoadWidgetControl.dataList.addAll(res.data);
        });
      }
    }
  }

  @protected
  resolveDataResult(res) {
    if (isShow) {
      setState(() {
        pullLoadWidgetControl.needLoadMore.value = (res != null && res.data != null && res.data.length == Config.PAGE_SIZE);
      });
    }
  }

  @protected
  clearData() {
    if (isShow) {
      setState(() {
        pullLoadWidgetControl.dataList.clear();
      });
    }
  }

  ///下拉刷新数据
  @protected
  requestRefresh() async {}

  ///上拉加载更多
  @protected
  requestLoadMore() async {}


  ///是否需要第一次进入自动刷新
  @protected
  bool get isRefreshFirst;

  ///是否需要头部
  @protected
  bool get needHeader => false;

  ///切换页面时是否需要保活
  @override
  bool get wantKeepAlive => true;

  List get getDataList => dataList;

  @override
  void initState() {
    isShow = true;
    super.initState();
    pullLoadWidgetControl.needHeader = needHeader;
    pullLoadWidgetControl.dataList = getDataList;
    if (pullLoadWidgetControl.dataList.length == 0 && isRefreshFirst) {
      showRefreshLoading();
    }
  }

  @override
  void dispose() {
    isShow = false;
    isLoading = false;
    super.dispose();
  }
}