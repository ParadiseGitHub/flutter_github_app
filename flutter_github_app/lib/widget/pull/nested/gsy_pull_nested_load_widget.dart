import 'package:flutter/material.dart';
import 'nested_refresh.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_github_app/common/style/gsy_style.dart';
import 'package:flutter_github_app/common/utils/common_utils.dart';
import 'package:flutter_github_app/widget/pull/gsy_pull_load_widget.dart';

///通用下上刷新控件
class GSYNestedPullLoadWidget extends StatefulWidget {

  ///item渲染
  final IndexedWidgetBuilder itemBuilder;

  ///加载更多回调
  final RefreshCallback onLoadMore;

  ///下拉刷新回调
  final RefreshCallback onRefresh;

  ///控制器，比如数据和一些配置
  final GSYPullLoadWidgetControl control;

  final Key refreshKey;

  final NestedScrollViewHeaderSliversBuilder headerSliverBuilder;

  final ScrollController scrollController;

  GSYNestedPullLoadWidget(
      this.control, this.itemBuilder, this.onRefresh, this.onLoadMore,
      {this.refreshKey, this.headerSliverBuilder, this.scrollController});

  @override
  _GSYNestedPullLoadWidgetState createState() => _GSYNestedPullLoadWidgetState(
      this.control,
      this.itemBuilder,
      this.onRefresh,
      this.onLoadMore,
      this.refreshKey);
}

class _GSYNestedPullLoadWidgetState extends State<GSYNestedPullLoadWidget> {

  final IndexedWidgetBuilder itemBuilder;

  final RefreshCallback onLoadMore;

  final RefreshCallback onRefresh;

  final Key refreshKey;

  GSYPullLoadWidgetControl control;

  _GSYNestedPullLoadWidgetState(this.control, this.itemBuilder, this.onRefresh,
      this.onLoadMore, this.refreshKey);

  @override
  void initState() {
    super.initState();
  }

  ///根据配置状态返回实际列表数量
  ///实际上这里可以根据你的需要做更多的处理
  ///比如多个头部，是否需要空页面，是否需要显示加载更多。
  _getListCount() {
    ///是否需要头部
    if (widget.control.needHeader) {
      ///如果需要头部，用Item 0 的 Widget 作为ListView的头部
      ///列表数量大于0时，因为头部和底部加载更多选项，需要对列表数据总数+2
      return (widget.control.dataList.length > 0)
          ? widget.control.dataList.length + 2
          : widget.control.dataList.length + 1;
    } else {
      ///不需要头部
      ///如果没有数据，固定返回数量1用于空页面呈现
      ///如果有数据,因为底部加载更多选项，需要对列表数据总数+1
      return widget.control.dataList.length + 1;
    }
  }

  ///根据配置状态，返回实际列表渲染Item
  _getItem(int index) {
    if (!widget.control.needHeader &&
        index == widget.control.dataList.length &&
        widget.control.dataList.length != 0) {
      ///如果不需要头部，并且数据不为0，当index等于数据长度时，渲染加载更多Item（因为index是从0开始）
      return _buildProgressIndicator();
    } else if (widget.control.needHeader &&
        index == _getListCount() - 1 &&
        widget.control.dataList.length != 0) {
      ///如果需要头部，并且数据不为0，当index等于实际渲染长度-1时，渲染加载更多Item（因为index是从0开始）
      return _buildProgressIndicator();
    } else if (!widget.control.needHeader &&
        widget.control.dataList.length == 0) {
      return _buildEmpty();
    } else {
      ///回调外部正常渲染Item，如果这里有需要，可以直接返回相对位置的index
      return widget.itemBuilder(context, index);
    }
  }

  ///上拉加载更多
  Widget _buildProgressIndicator() {
    ///是否需要显示上拉加载更多的loading
    Widget bottomWidget = (control.needLoadMore.value)
        ? Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ///加载动画
              SpinKitRotatingCircle(color: Theme.of(context).primaryColor),
              ///控件间距
              Container(width: 5.0),
              ///文本提示
              Text(CommonUtils.getLocale(context).load_more_text,
                style: TextStyle(
                color: Color(GSYColors.primaryDarkValue),
                fontSize: GSYConstant.smallTextSize,
                fontWeight: FontWeight.bold,
                ),
              ),
            ],
          )
        ///不需要加载
        : Container();

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Center(
        child: bottomWidget,
      ),
    );
  }

  ///空页面
  Widget _buildEmpty() {
    return Container(
      height: MediaQuery.of(context).size.height - 100,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          FlatButton(
            onPressed: () {},
            child: Image(
              image: AssetImage(GSYICons.DEFAULT_USER_ICON),
              width: 70.0,
              height: 70.0,
            ),
          ),
          Container(
            child: Text(
              CommonUtils.getLocale(context).app_empty,
              style: GSYConstant.normalText,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return NestedScrollViewRefreshIndicator(
      key: refreshKey,
      child: NestedScrollView(
        ///滑动监听
        controller: widget.scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        headerSliverBuilder: widget.headerSliverBuilder,
        body: NotificationListener(
          onNotification: (ScrollNotification p) {
            if (p.metrics.pixels > p.metrics.maxScrollExtent) {
              if (this.control.needLoadMore.value) {
                this.onLoadMore?.call();
              }
            }
            //return true;
          },
          child: ListView.builder(
            ///根据状态返回数量
            itemCount: _getListCount(),

            itemBuilder: (_, index) {
              return _getItem(index);
            },
          ),
        ),
      ),
      ///下拉刷新触发，返回的是一个Future
      onRefresh: onRefresh,
    );
  }
}
