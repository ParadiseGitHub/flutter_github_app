import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:flutter_github_app/common/model/Repository.dart';
import 'package:flutter_github_app/widget/gsy_tabbar_widget.dart';
import 'package:flutter_github_app/common/dao/repos_dao.dart';
import 'package:flutter_github_app/common/style/gsy_style.dart';
import 'package:flutter_github_app/widget/gsy_icon_text.dart';
import 'package:flutter_github_app/widget/gsy_title_bar.dart';
import 'package:flutter_github_app/common/utils/common_utils.dart';
import 'package:flutter_github_app/widget/gsy_bottom_action_bar.dart';
import 'package:flutter_github_app/widget/gsy_common_option_widget.dart';
import 'package:flutter_github_app/page/repository_detail_readme_page.dart';
import 'package:flutter_github_app/page/repostory_detail_info_page.dart';

class RepositoryDetailPage extends StatefulWidget {
  final String userName;

  final String repoName;

  RepositoryDetailPage(this.userName, this.repoName);

  @override
  _RepositoryDetailPageState createState() => _RepositoryDetailPageState();
}

class _RepositoryDetailPageState extends State<RepositoryDetailPage> with SingleTickerProviderStateMixin {

  /// 仓库底部状态，如 star、watch 等等
  BottomStatusModel bottomStatusModel;

  /// 仓库的详情数据实体
  final ReposDetailModel reposDetailModel = ReposDetailModel();

  /// 仓库底部状态，如 star、watch 控件的显示
  final TarWidgetControl tarBarControl = TarWidgetControl();

  /// 配置标题栏右侧控件显示
  final OptionControl titleOptionControl = OptionControl();

//  /// 文件列表页的 GlobalKey ，可用于当前控件控制文件也行为
//  GlobalKey<RepositoryDetailFileListPageState> fileListKey =
//  new GlobalKey<RepositoryDetailFileListPageState>();
//
//  /// 详情信息页的 GlobalKey ，可用于当前控件控制文件也行为
//  GlobalKey<ReposDetailInfoPageState> infoListKey =
//  new GlobalKey<ReposDetailInfoPageState>();
//
  /// readme 页面的 GlobalKey ，可用于当前控件控制文件也行为
  GlobalKey<RepositoryDetailReadmePageState> readmeKey =
  new GlobalKey<RepositoryDetailReadmePageState>();
//
//  /// issue 列表页的 GlobalKey ，可用于当前控件控制文件也行为
//  GlobalKey<RepositoryDetailIssuePageState> issueListKey =
//  new GlobalKey<RepositoryDetailIssuePageState>();

  /// 动画控制器，用于底部发布 issue 按键动画
  AnimationController animationController;

  /// 分支数据列表
  List<String> branchList = List();

  /// 获取网络端仓库的star等状态
  _getReposStatus() async {
    var result = await ReposDao.getRepositoryStatusDao(widget.userName, widget.repoName);

    String watchText = result.data["watch"] ? "UnWatch" : "Watch";
    String starText = result.data["star"] ? "UnStar" : "Star";
    IconData watchIcon = result.data["watch"]
      ? GSYICons.REPOS_ITEM_WATCHED
      : GSYICons.REPOS_ITEM_WATCH;
    IconData starIcon = result.data["star"]
      ? GSYICons.REPOS_ITEM_STARED
      : GSYICons.REPOS_ITEM_STAR;

    BottomStatusModel model = BottomStatusModel(watchText, starText, watchIcon, starIcon, result.data["watch"], result.data["star"]);
    setState(() {
      bottomStatusModel = model;
      tarBarControl.footerButton = _getBottomWidget();
    });
  }

  /// 获取分支数据
  _getBranchList() async {
    var result = await ReposDao.getBranchesDao(widget.userName, widget.repoName);
    if (result!= null && result.result) {
      setState(() {
        branchList = result.data;
      });
    }
  }

  _refresh() {
    this._getReposStatus();
  }

  /// 绘制底部状态 item
  _renderBottomItem(var text, var icon, var onPressed) {
    return FlatButton(
      onPressed: onPressed,
      child: GSYIconText(
        icon,
        text,
        GSYConstant.smallText,
        Color(GSYColors.primaryValue),
        15.0,
        padding: 5.0,
        mainAxisAlignment: MainAxisAlignment.center,
      ),
    );
  }

  /// 绘制底部状态
  _getBottomWidget() {
    ///根据网络返回数据，返回底部状态数据
    List<Widget> bottomWidget = (bottomStatusModel == null)
        ? []
        : <Widget>[
            /// star
            _renderBottomItem(
              bottomStatusModel.starText,
              bottomStatusModel.starIcon,
              () {
               print('star!!!');
              }),

            /// watch
            _renderBottomItem(
              bottomStatusModel.watchText,
              bottomStatusModel.watchIcon,
              () {
                print('watch!!!');
              }),

            /// fork
            _renderBottomItem(
              "fork",
              GSYICons.REPOS_ITEM_FORK,
              () { print('fork!!!'); },
            ),
          ];

    return bottomWidget;
  }

  ///渲染 Tab 的 Item
  _renderTabItem() {
    var itemList = [
      CommonUtils.getLocale(context).repos_tab_info,
      CommonUtils.getLocale(context).repos_tab_readme,
      CommonUtils.getLocale(context).repos_tab_issue,
      CommonUtils.getLocale(context).repos_tab_file,
    ];

    renderItem(String item) {
      return Container(
        padding: EdgeInsets.symmetric(vertical: 10.0),
        child: Text(
          item,
          style: GSYConstant.smallTextWhite,
          maxLines: 1,
        ),
      );
    }

    List<Widget> list = List();
    for (int i = 0; i < itemList.length; i++) {
      list.add(renderItem(itemList[i]));
    }
    return list;
  }

  /// title 显示更多弹出item
  _getMoreOtherItem(Repository repository) {
    return [
      GSYOptionModel(
        CommonUtils.getLocale(context).repos_option_release,
        CommonUtils.getLocale(context).repos_option_release,
          (model) {

          }
      ),
    ];
  }

  /// 创建 issue
  _createIssue() {
    String title = "";
    String content = "";
  }

  @override
  void initState() {
    super.initState();
    _getBranchList();
    _refresh();

    ///悬浮按键动画控制器
    animationController = AnimationController(vsync: this, duration: Duration(milliseconds: 800));
    animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    ///跨 tab 共享状态
    return ScopedModel<ReposDetailModel>(
      model: reposDetailModel,
      child: ScopedModelDescendant<ReposDetailModel>(
        builder: (context, child, model) {
          Widget widgetContent = (model.repository != null && model.repository.htmlUrl != null)
              ? GSYCommonOptionWidget(titleOptionControl, otherList: _getMoreOtherItem(model.repository))
              : Container();

          return GSYTabBarWidget(
            type: GSYTabBarWidget.TOP_TAB,
            tabItems: _renderTabItem(),
            resizeToAvoidBottomPadding: false,
            tabViews: <Widget>[

            ],
            backgroundColor: GSYColors.primarySwatch,
            indicatorColor: Color(GSYColors.white),
            title: GSYTitleBar(
              widget.repoName,
              rightWidget: widgetContent,
            ),
            onPageChanged: (index) {
              reposDetailModel.setCurrentIndex(index);
            },

            ///悬浮按键位置
            floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,

            ///底部bar，增加对悬浮按键的缺省容器处理
            bottomBar: GSYBottomAppBar(
              color: Color(GSYColors.white),
              fabLocation: FloatingActionButtonLocation.endDocked,
              shape: CircularNotchedRectangle(),
              rowContents: (tarBarControl.footerButton == null)
                  ? [Container()]
                  : tarBarControl.footerButton.length == 0
                      ? [SizedBox.fromSize(size: Size(100, 50))]
                      : tarBarControl.footerButton,
            ),
          );
        },
      ),
    );
  }
}

///底部状态实体
class BottomStatusModel {
  final String watchText;
  final String starText;
  final IconData watchIcon;
  final IconData starIcon;
  final bool star;
  final bool watch;

  BottomStatusModel(
    this.watchText,
    this.starText,
    this.watchIcon,
    this.starIcon,
    this.watch,
    this.star,
  );
}

///仓库详情数据实体，包含有当前index，仓库数据，分支等等
class ReposDetailModel extends Model {

  static ReposDetailModel of(BuildContext context) =>
      ScopedModel.of<ReposDetailModel>(context);

  int _currentIndex = 0;

  int get currentIndex => _currentIndex;

  String _currentBranch = "master";

  String get currentBranch => _currentBranch;

  Repository _repository = Repository.empty();

  Repository get repository => _repository;

  set repository(Repository data) {
    _repository = data;
    notifyListeners();
  }

  void setCurrentBranch(String branch) {
    _currentBranch = branch;
    notifyListeners();
  }

  void setCurrentIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }
}
