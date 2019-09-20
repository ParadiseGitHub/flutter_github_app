import 'package:flutter/material.dart';

class GSYTabBarWidget extends StatefulWidget {
  static const int BOTTOM_TAB = 1;
  static const int TOP_TAB = 2;

  final int type;
  final bool resizeToAvoidBottomPadding;
  final List<Widget> tabItems;
  final List<Widget> tabViews;
  final Color backgroundColor;
  final Color indicatorColor;
  final Widget title;
  final Widget drawer;
  final Widget floatingActionButton;
  final FloatingActionButtonLocation floatingActionButtonLocation;
  final Widget bottomBar;
  final TarWidgetControl tarWidgetControl;
  final ValueChanged<int> onPageChanged;

  GSYTabBarWidget({
    Key key,
    this.type,
    this.tabItems,
    this.tabViews,
    this.backgroundColor,
    this.indicatorColor,
    this.title,
    this.drawer,
    this.bottomBar,
    this.floatingActionButtonLocation,
    this.floatingActionButton,
    this.resizeToAvoidBottomPadding = true,
    this.tarWidgetControl,
    this.onPageChanged,
  }) : super(key: key);

  @override
  _GSYTabBarWidgetState createState() => _GSYTabBarWidgetState(
    type,
    tabViews,
    indicatorColor,
    drawer,
    floatingActionButton,
    tarWidgetControl,
    onPageChanged,
  );
}

class _GSYTabBarWidgetState extends State<GSYTabBarWidget> with SingleTickerProviderStateMixin {

  final int _type;
  final List<Widget> _tabViews;
  final Color _indicatorColor;
  final Widget _drawer;
  final Widget _floatingActionButton;
  final TarWidgetControl _tarWidgetControl;
  final PageController _pageController = PageController();
  final ValueChanged<int> _onPageChanged;

  _GSYTabBarWidgetState(
      this._type,
      this._tabViews,
      this._indicatorColor,
      this._drawer,
      this._floatingActionButton,
      this._tarWidgetControl,
      this._onPageChanged,
  ) : super();

  TabController _tabController;

  @override
  void initState() {
    super.initState();
    // 初始化时创建控制器
    _tabController = TabController(length: widget.tabItems.length, vsync: this);
  }

  @override
  void dispose() {
    // 页面销毁时，销毁控制器

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (this._type == GSYTabBarWidget.TOP_TAB) {
      return Scaffold(
        resizeToAvoidBottomPadding: widget.resizeToAvoidBottomPadding,
        floatingActionButton: SafeArea(
          child: _floatingActionButton ?? Container()),
        floatingActionButtonLocation: widget.floatingActionButtonLocation,
        persistentFooterButtons: _tarWidgetControl == null ? null : _tarWidgetControl.footerButton,
        appBar: AppBar(
          backgroundColor: Theme.of(context).primaryColor,
          title: widget.title,
          bottom: TabBar(
            controller: _tabController,
            tabs: widget.tabItems,
            indicatorColor: _indicatorColor,
            onTap: (index) {
              _onPageChanged?.call(index);
              _pageController.jumpTo(MediaQuery.of(context).size.width * index);
            },
          ),
        ),
        body: PageView(
          controller: _pageController,
          children: _tabViews,
          onPageChanged: (index) {
            _tabController.animateTo(index);
            _onPageChanged?.call(index);
          },
        ),
        bottomNavigationBar: widget.bottomBar,
      );

    } else {
      // 底部TabBar模式
      return Scaffold(
        drawer: _drawer,
        appBar: AppBar(
          backgroundColor: Theme.of(context).primaryColor,
          title: widget.title,
        ),
        body: PageView(
          controller: _pageController,
          children: _tabViews,
          onPageChanged: (index) {
            _tabController.animateTo(index);
            _onPageChanged?.call(index);
          },
        ),
        bottomNavigationBar: Material(
          // 适配主题，包一层Material实现风格套用
          color: Theme.of(context).primaryColor,
          child: SafeArea(
            child: TabBar(
              // TabBar放到Scaffold的bottomNavigationBar中
              tabs: widget.tabItems,
              controller: _tabController,
              indicatorColor: _indicatorColor,
              onTap: (index) {
                _onPageChanged?.call(index);
                _pageController.jumpTo(MediaQuery.of(context).size.width * index);
              },
            ),
          ),
        ),
      );
    }
  }
}

class TarWidgetControl {
  List<Widget> footerButton = [];
}
