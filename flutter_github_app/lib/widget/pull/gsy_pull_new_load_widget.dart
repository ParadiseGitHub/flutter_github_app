import 'package:flutter/material.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_github_app/common/style/gsy_style.dart';
import 'package:flutter_github_app/common/utils/common_utils.dart';


const double iosRefreshHeight = 140;
const double iosRefreshIndicatorExtent = 100;

class GSYPullLoadWidget extends StatefulWidget {
  ///item渲染
  final IndexedWidgetBuilder itemBuilder;

  ///下拉刷新回调
  final RefreshCallback onRefresh;

  ///加载更多回调
  final RefreshCallback onLoadMore;

  ///控制器，比如数据和一些配置
  final GSYPullLoadWidgetControl control;

  final ScrollController scrollController;

  final bool userIos;

  final Key refreshKey;

  GSYPullLoadWidget(
      this.control, this.itemBuilder, this.onRefresh, this.onLoadMore,
      {this.refreshKey, this.scrollController, this.userIos = false}
  );

  @override
  _GSYPullLoadWidgetState createState() => _GSYPullLoadWidgetState();
}

class _GSYPullLoadWidgetState extends State<GSYPullLoadWidget> {

  //final GlobalKey<IOS.C>

  ScrollController _scrollController;

  bool isRefreshing = false;

  bool isLoadMoring = false;

  @override
  ValueNotifier<bool> isActive = ValueNotifier<bool>(true);

  @override
  void initState() {
    _scrollController = widget.scrollController ?? ScrollController();

    ///增加滑动监听
    _scrollController.addListener(() {
      ///判断当前滑动位置是否达到底部，出发加载更多回调
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        if (widget.control.needLoadMore) {
          handleLoadMore();
        }
      }
    });

    widget.control.addListener(() {
      setState(() {});
      try {
        Future.delayed(Duration(seconds: 2), () {
          _scrollController.notifyListeners();
        });
      } catch (e) {
        print(e);
      }
    });
    super.initState();
  }

  @protected
  Future<Null> handleRefresh() async {
    if (widget.control.isLoading) {
      if (isRefreshing) {
        return null;
      }

      ///if loading, lock to await
      await _lockToAwait();
    }
    widget.control.isLoading = true;
    isRefreshing = true;
    await widget.onRefresh?.call();
    isRefreshing = false;
    widget.control.isLoading = false;
    return null;
  }

  @protected
  Future<Null> handleLoadMore() async {
    if (widget.control.isLoading) {
      if (isLoadMoring) {
        return null;
      }

      ///if loading, lock to await
      await _lockToAwait();
    }
    isLoadMoring = true;
    widget.control.isLoading = true;
    await widget.onLoadMore?.call();
    isLoadMoring = false;
    widget.control.isLoading = false;
    return null;
  }

  ///if loading, lock to await
  _lockToAwait() async {
    doDelayed() async {
      await Future.delayed(Duration(seconds: 1)).then((_) async {
        if (widget.control.isLoading) {
          return await doDelayed();
        } else {
          return null;
        }
      });
    }
    await doDelayed();
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
    Widget bottomWidget = (widget.control.needLoadMore)
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

    return RefreshIndicator(
      ///GlobalKey，用户外部获取RefreshIndicator的State，做显示刷新
      key: widget.refreshKey,

      ///下拉刷新触发，返回的是一个Future
      onRefresh: handleRefresh,
      child: ListView.builder(
        ///保持ListView任何情况都能滚动，解决在RefreshIndicator的兼容问题。
        physics: const AlwaysScrollableScrollPhysics(),

        ///根据状态返回子控件
        itemBuilder: (context, index) {
          return _getItem(index);
        },

        ///根据状态返回数量
        itemCount: _getListCount(),

        ///滑动监听
        controller: _scrollController,
      ),
    );
  }
}

class GSYPullLoadWidgetControl extends ChangeNotifier {
  ///数据，对齐增减，不能替换
  List _dataList = List();

  get dataList => _dataList;

  set dataList(List value) {
    _dataList.clear();
    if (value != null) {
      _dataList.addAll(value);
      notifyListeners();
    }
  }

  addList(List value) {
    if (value != null) {
      _dataList.addAll(value);
      notifyListeners();
    }
  }

  ///是否需要加载更多
  bool _needLoadMore = true;

  get needLoadMore => _needLoadMore;

  set needLoadMore(value) {
    _needLoadMore = value;
    notifyListeners();
  }

  ///是否需要头部
  bool _needHeader = true;

  get needHeader => _needHeader;

  set needHeader(value) {
    _needHeader = value;
    notifyListeners();
  }

  ///是否加载中
  bool isLoading = false;

}