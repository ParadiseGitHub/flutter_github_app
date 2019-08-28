import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_github_app/common/style/gsy_style.dart';
import 'package:flutter_github_app/common/utils/common_utils.dart';

///通用下上刷新控件
class GSYPullLoadWidget extends StatefulWidget {

  ///item渲染
  final IndexedWidgetBuilder itemBuilder;

  ///下拉刷新回调
  final RefreshCallback onRefresh;

  ///加载更多回调
  final RefreshCallback onLoadMore;

  ///控制器，比如数据和一些配置
  final GSYPullLoadWidgetControl control;

  final Key refreshKey;

  GSYPullLoadWidget(this.control, this.itemBuilder, this.onRefresh, this.onLoadMore, {this.refreshKey});

  @override
  _GSYPullLoadWidgetState createState() => _GSYPullLoadWidgetState(this.control, this.itemBuilder, this.onRefresh, this.onLoadMore, this.refreshKey);
}

class _GSYPullLoadWidgetState extends State<GSYPullLoadWidget> {

  final IndexedWidgetBuilder itemBuilder;

  final RefreshCallback onLoadMore;

  final RefreshCallback onRefresh;

  GSYPullLoadWidgetControl control;

  final Key refreshKey;

  _GSYPullLoadWidgetState(this.control, this.itemBuilder, this.onRefresh, this.onLoadMore, this.refreshKey);

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    this.control.needLoadMore?.addListener(() {
      ///延迟两秒等待确认
      try {
        Future.delayed(Duration(seconds: 2), () {
          _scrollController.notifyListeners();
        });
      } catch (e) {
        print(e);
      }
    });

    ///增加滑动监听
    _scrollController.addListener(() {
      ///判断当前滑动位置是不是到达底部，触发加载更多回调
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        if (this.control.needLoadMore.value) {
          this.onLoadMore?.call();
        }
      }
    });

    super.initState();
  }

  ///根据配置状态返回实际列表数量
  ///实际上这里可以根据你的需要做更多的处理
  ///比如多个头部，是否需要空页面，是否需要显示加载更多。
  _getListCount() {
    ///是否需要头部
    if (control.needHeader) {
      ///如果需要头部，用Item 0 的 Widget 作为ListView的头部
      ///列表数量大于0时，因为头部和底部加载更多选项，需要对列表数据总数+2
      return (control.dataList.length > 0) ? control.dataList.length + 2 : control.dataList.length + 1;
    } else {
      ///不需要头部
      ///如果没有数据，固定返回数量1用于空页面呈现
      ///如果有数据,因为底部加载更多选项，需要对列表数据总数+1
      return control.dataList.length + 1;
    }
  }

  ///根据配置状态返回实际列表渲染Item
  _getItem(int index) {
    if (!control.needHeader && index == control.dataList.length && control.dataList.length != 0) {
      ///如果不需要头部，并且数据不为0，当index等于数据长度时，渲染加载更多Item（因为index是从0开始）
      return _buildProgressIndicator();
    } else if (control.needHeader && index == _getListCount() - 1 && control.dataList.length != 0) {
      ///如果需要头部，并且数据不为0，当index等于实际渲染长度 - 1时，渲染加载更多Item（因为index是从0开始）
      return _buildProgressIndicator();
    } else if (!control.needHeader && control.dataList.length == 0) {
      ///如果不需要头部，并且数据为0，渲染空页面
      return _buildEmpty();
    } else {
      ///回调外部正常渲染Item，如果这里有需要，可以直接返回相对位置的index
      return itemBuilder(context, index);
    }
  }

  ///上拉加载更多
  Widget _buildProgressIndicator() {
    ///是否需要显示上拉加载更多的loading
    Widget bottomWidget = (control.needLoadMore.value)
        ? Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ///loading框
              SpinKitRotatingCircle(color: Theme.of(context).primaryColor),
              Container(width: 5.0),
              Text(CommonUtils.getLocale(context).load_more_text,
                style: TextStyle(
                  color: Color(GSYColors.primaryDarkValue),
                  fontSize: GSYConstant.smallTextSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          )
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
            child: Image(image: AssetImage(GSYICons.DEFAULT_USER_ICON), width: 70, height: 70,),
          ),
          Container(
            child: Text(CommonUtils.getLocale(context).app_empty, style: GSYConstant.normalText),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class GSYPullLoadWidgetControl {

  ///数据，对齐增减，不能替换
  List dataList = List();

  ///是否需要加载更多
  ValueNotifier<bool> needLoadMore = ValueNotifier(false);

  ///是否需要头部
  bool needHeader = false;
}
