import 'dart:async';
import 'package:redux/redux.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_github_app/bloc/trend_bloc.dart';
import 'package:flutter_github_app/widget/repos_item.dart';
import 'package:flutter_github_app/widget/gsy_card_item.dart';
import 'package:flutter_github_app/common/redux/gsy_state.dart';
import 'package:flutter_github_app/common/style/gsy_style.dart';
import 'package:flutter_github_app/common/utils/common_utils.dart';
import 'package:flutter_github_app/common/utils/navigator_utils.dart';
import 'package:flutter_github_app/common/model/TrendingRepoModel.dart';
import 'package:flutter_github_app/widget/pull/nested/nested_refresh.dart';
import 'package:flutter_github_app/widget/pull/nested/gsy_sliver_header_delegate.dart';


///趋势页面
///目前采用 bloc 的 rxdart(stream) + streamBuilder

class TrendPage extends StatefulWidget {
  @override
  _TrendPageState createState() => _TrendPageState();
}

class _TrendPageState extends State<TrendPage>
    with  AutomaticKeepAliveClientMixin<TrendPage>,
          SingleTickerProviderStateMixin {

  ///显示数据时间
  TrendTypeModel selectTime = null;

  ///显示过滤语言
  TrendTypeModel selectType = null;

  ///NestedScrollView 的刷新状态 GlobalKey ，方便主动刷新使用
  final GlobalKey<NestedScrollViewRefreshIndicatorState> refreshIndicatorKey =
      GlobalKey<NestedScrollViewRefreshIndicatorState>();

  ///滚动控制与监听
  final ScrollController scrollController = ScrollController();

  ///Bloc
  final TrendBloc trendBloc = TrendBloc();

  ///显示刷新
  _showRefreshLoading() {
    Future.delayed(Duration(seconds: 0), () {
      refreshIndicatorKey.currentState.show().then((e) {});
    });
  }

  ///绘制tiem
  _renderItem(e) {
    ReposViewModel reposViewModel = ReposViewModel.fromTrendMap(e);
    return ReposItem(reposViewModel, onPressed: () {
      print('Go to Repo Detial!!!');
      //NavigatorUtils.goReposDetail(context, reposViewModel.ownerName, reposViewModel.repositoryName);
    });
  }

  ///绘制头部可选item
  _renderHeader(Store<GSYState> store, Radius radius) {
    if (selectTime == null && selectType == null) {
      return Container();
    }

    return GSYCardItem(
      color: store.state.themeData.primaryColor,
      margin: EdgeInsets.all(0.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(radius)),
      child: Padding(
        padding: EdgeInsets.only(top: 5.0, bottom: 5.0),
        child: Row(
          children: <Widget>[
            _renderHeaderPopItem(selectTime.name, trendTime(context), (TrendTypeModel result) {
              if (trendBloc.isLoading) {
                Fluttertoast.showToast(msg: CommonUtils.getLocale(context).loading_text);
                return;
              }
              scrollController.animateTo(0, duration: Duration(milliseconds: 200), curve: Curves.bounceInOut)
                .then((_) {
                  setState(() {
                    selectTime = result;
                  });
                  _showRefreshLoading();
              });
            }),

            Container(
              height: 10.0, width: 0.5, color: Color(GSYColors.white),
            ),

            _renderHeaderPopItem(selectType.name, trendType(context), (TrendTypeModel result) {
              if (trendBloc.isLoading) {
                Fluttertoast.showToast(msg: CommonUtils.getLocale(context).loading_text);
                return;
              }
              scrollController.animateTo(0, duration: Duration(milliseconds: 200), curve: Curves.bounceInOut)
                .then((_) {
                  setState(() {
                    selectType = result;
                  });
                  _showRefreshLoading();
              });
            }),
          ],
        ),
      ),
    );
  }

  ///绘制头部可选弹出item容器
  _renderHeaderPopItem(String data, List<TrendTypeModel> list,
      PopupMenuItemSelected<TrendTypeModel> onSelected) {
    return Expanded(
      child: PopupMenuButton<TrendTypeModel>(
        child: Center(
          child: Text(data, style: GSYConstant.middleTextWhite),
        ),
        onSelected: onSelected,
        itemBuilder: (BuildContext context) {
          return _renderHeaderPopItemChild(list);
        },
      ),
    );
  }

  ///绘制头部可选弹出item
  _renderHeaderPopItemChild(List<TrendTypeModel> data) {
    List<PopupMenuEntry<TrendTypeModel>> list = List();
    for (TrendTypeModel item in data) {
      list.add(PopupMenuItem<TrendTypeModel>(
        value: item,
        child: Text(item.name),
      ));
    }
    return list;
  }

  ///空页面
  Widget _buildEmpty() {
    var statusBar = MediaQueryData.fromWindow(WidgetsBinding.instance.window).padding.top;
    var bottomArea = MediaQueryData.fromWindow(WidgetsBinding.instance.window).padding.bottom;

    var height = MediaQuery.of(context).size.height
        - statusBar
        - bottomArea
        - kBottomNavigationBarHeight
        - kToolbarHeight;

    return SingleChildScrollView(
      child: Container(
        height: height,
        width: MediaQuery.of(context).size.width,
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
              child: Text(CommonUtils.getLocale(context).app_empty,
                          style: GSYConstant.normalText),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> requestRefresh() async {
    return trendBloc.requestRefresh(selectTime, selectType);
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void didChangeDependencies() {
    if (!trendBloc.requested) {
      setState(() {
        selectTime = trendTime(context)[0];
        selectType = trendType(context)[0];
      });
      _showRefreshLoading();
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); //AutomaticKeepAliveClientMixin
    return StoreBuilder<GSYState>(
      builder: (context, store) {
        return Scaffold(
          backgroundColor: Color(GSYColors.mainBackgroundColor),

          ///采用目前采用纯 bloc 的 rxdart(stream) + streamBuilder
          body: StreamBuilder<List<TrendingRepoModel>>(
            stream: trendBloc.stream,
            builder: (context, snapShot) {
              ///下拉刷新
              return NestedScrollViewRefreshIndicator(
                key: refreshIndicatorKey,
                onRefresh: requestRefresh,
                ///嵌套滚动
                child: NestedScrollView(
                  controller: scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  headerSliverBuilder: (context, innerBoxIsScrolled) {
                    return _sliverBuilder(context, innerBoxIsScrolled, store);
                  },
                  body: (snapShot.data == null || snapShot.data.length == 0)
                    ? _buildEmpty()
                    : ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: snapShot.data.length,
                        itemBuilder: (context, index) {
                          return _renderItem(snapShot.data[index]);
                        },
                      ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  ///嵌套可滚动头部
  List<Widget> _sliverBuilder(BuildContext context, bool innerBoxIsScrolled, Store store) {
    return <Widget>[
      ///动态头部
      SliverPersistentHeader(
        pinned: true,
        ///SliverPersistentHeaderDelegate 实现
        delegate: GSYSliverHeaderDelegate(
          maxHeight: 65.0,
          minHeight: 65.0,
          changeSize: true,
          snapConfig: FloatingHeaderSnapConfiguration(
            vsync: this,
            curve: Curves.bounceInOut,
            duration: const Duration(milliseconds: 10),
          ),
          builder: (BuildContext context, double shrinkOffset, bool overlapsContent) {
            print('shrinkOffset = $shrinkOffset');
            ///根据数值计算偏差
            var lr = 10 - shrinkOffset / 65 * 10;
            var radius = Radius.circular(4 - shrinkOffset / 65 * 4);
            return SizedBox.expand(
              child: Padding(
                padding: EdgeInsets.only(top: lr, bottom: 10.0, left: lr, right: lr),
                child: _renderHeader(store, radius),
              ),
            );
          }
        ),
      ),
    ];
  }
}


///趋势数据过滤显示item
class TrendTypeModel {
  final String name;
  final String value;

  TrendTypeModel(this.name, this.value);
}

///趋势数据时间过滤
trendTime(BuildContext context) {
  return [
    TrendTypeModel(CommonUtils.getLocale(context).trend_day, "daily"),
    TrendTypeModel(CommonUtils.getLocale(context).trend_week, "weekly"),
    TrendTypeModel(CommonUtils.getLocale(context).trend_month, "monthly"),
  ];
}

///趋势数据语言过滤
trendType(BuildContext context) {
  return [
    TrendTypeModel(CommonUtils.getLocale(context).trend_all, null),
    TrendTypeModel("Java", "Java"),
    TrendTypeModel("Kotlin", "Kotlin"),
    TrendTypeModel("Dart", "Dart"),
    TrendTypeModel("Objective-C", "Objective-C"),
    TrendTypeModel("Swift", "Swift"),
    TrendTypeModel("JavaScript", "JavaScript"),
    TrendTypeModel("PHP", "PHP"),
    TrendTypeModel("Go", "Go"),
    TrendTypeModel("C++", "C++"),
    TrendTypeModel("C", "C"),
    TrendTypeModel("HTML", "HTML"),
    TrendTypeModel("CSS", "CSS"),
    TrendTypeModel("Python", "Python"),
    TrendTypeModel("C#", "c%23"),
  ];
}
