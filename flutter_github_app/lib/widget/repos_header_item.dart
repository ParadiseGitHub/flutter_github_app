import 'package:flutter/material.dart';
import 'package:flutter_github_app/common/config/config.dart';
import 'package:flutter_github_app/common/model/Repository.dart';
import 'package:flutter_github_app/common/style/gsy_style.dart';
import 'package:flutter_github_app/common/utils/common_utils.dart';
import 'package:flutter_github_app/common/utils/navigator_utils.dart';
import 'package:flutter_github_app/widget/gsy_card_item.dart';
import 'package:flutter_github_app/widget/gsy_icon_text.dart';

class ReposHeaderItem extends StatefulWidget {
  final ReposHeaderViewModel reposHeaderViewModel;

  final ValueChanged<Size> layoutListener;

  ReposHeaderItem(this.reposHeaderViewModel, {this.layoutListener}) : super();

  @override
  _ReposHeaderItemState createState() => _ReposHeaderItemState();
}

class _ReposHeaderItemState extends State<ReposHeaderItem> {
  final GlobalKey layoutKey = GlobalKey();
  final GlobalKey layoutTopicContainerKey = GlobalKey();
  final GlobalKey layoutLastTopicKey = GlobalKey();

  double widgetHeight = 0.0;

  ///底部仓库状态信息，比如star数量等
  _getBottomItem(IconData icon, String text, onPressed) {
    return Expanded(
      child: Center(
        child: RawMaterialButton(
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          padding: EdgeInsets.symmetric(vertical: 10.0),
          constraints: const BoxConstraints(minWidth: 0.0, minHeight: 0.0),
          child: GSYIconText(
            icon,
            text,
            GSYConstant.smallSubLightText,
            Color(GSYColors.subLightTextColor),
            15.0,
            padding: 3.0,
            mainAxisAlignment: MainAxisAlignment.center,
          ),
          onPressed: onPressed,
        ),
      ),
    );
  }

  _renderTopicItem(BuildContext context, String item, index) {
    return RawMaterialButton(
      key: index == widget.reposHeaderViewModel.topics.length - 1
          ? layoutLastTopicKey
          : null,
      padding: const EdgeInsets.all(0.0),
      constraints: const BoxConstraints(minHeight: 0.0, minWidth: 0.0),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      child: Container(
        padding: EdgeInsets.only(left: 5.0, top: 2.5, right: 5.0, bottom: 2.5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(4.0)),
          color: Colors.white30,
          border: Border.all(color: Colors.white30, width: 0.0),
        ),
        child: Text(item, style: GSYConstant.smallSubLightText),
      ),
      onPressed: () {
        //NavigatorUtils.gotoCommonList(context, item, "repository", "topics", userName: item, reposName: "");
      },
    );
  }

  ///话题组件
  _renderTopicGroup(BuildContext context) {
    if (widget.reposHeaderViewModel.topics == null ||
        widget.reposHeaderViewModel.topics.length == 0) {
      return Container();
    }
    List<Widget> list = List();
    for (int i = 0; i < widget.reposHeaderViewModel.topics.length; i++) {
      var item = widget.reposHeaderViewModel.topics[i];
      list.add(_renderTopicItem(context, item, i));
    }
    return Container(
      key: layoutTopicContainerKey,
      alignment: Alignment.topLeft,
      margin: EdgeInsets.only(top: 5.0),
      child: Wrap(
        spacing: 10.0,
        runSpacing: 5.0,
        children: list,
      ),
    );
  }

  ///仓库创建和提交状态信息
  _getInfoText(BuildContext context) {
    String createStr = widget.reposHeaderViewModel.repositoryIsFork
        ? CommonUtils.getLocale(context).repos_fork_at +
            widget.reposHeaderViewModel.repositoryParentName +
            '\n'
        : CommonUtils.getLocale(context).repos_create_at +
            widget.reposHeaderViewModel.created_at +
            '\n';

    String updateStr = CommonUtils.getLocale(context).repos_last_commit +
        widget.reposHeaderViewModel.push_at;

    return createStr +
        ((widget.reposHeaderViewModel.push_at != null) ? updateStr : '');
    ;
  }

  @override
  void didUpdateWidget(ReposHeaderItem oldWidget) {
    super.didUpdateWidget(oldWidget);

    ///如果没有tag列表，不需要处理
    /*if(layoutTopicContainerKey.currentContext == null || layoutLastTopicKey.currentContext == null) {
      return;
    }*/
    ///如果存在tag，根据tag去判断，修复溢出
    Future.delayed(Duration(seconds: 0), () {
      /// tag 所在 container
      RenderBox renderBox2 =
          layoutTopicContainerKey.currentContext?.findRenderObject();

      /// 最后面的一个tag
      RenderBox renderBox3 =
          layoutLastTopicKey.currentContext?.findRenderObject();
      double overflow = ((renderBox3?.localToGlobal(Offset.zero)?.dy ?? 0) -
              (renderBox2?.localToGlobal(Offset.zero)?.dy ?? 0)) -
          (layoutLastTopicKey.currentContext?.size?.height ?? 0);

      var newSize;
      if (overflow > 0) {
        newSize = layoutKey.currentContext.size.height + overflow;
      } else {
        newSize = layoutKey.currentContext.size.height + 10.0;
      }
      if (Config.DEBUG) {
        print("newSize $newSize overflow $overflow");
        if (widgetHeight != newSize && newSize > 0) {
          print("widget?.layoutListener?.call");
          widgetHeight = newSize;
          widget?.layoutListener
              ?.call(Size(layoutKey.currentContext.size.width, widgetHeight));
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      key: layoutKey,
      child: GSYCardItem(
        color: Theme.of(context).primaryColor,
        child: ClipRRect(
          borderRadius: BorderRadius.all(Radius.circular(4.0)),
          child: Container(
            ///背景头像
            decoration: BoxDecoration(
              image: DecorationImage(
                fit: BoxFit.cover,
                image: NetworkImage(widget.reposHeaderViewModel.ownerPic ??
                    GSYICons.DEFAULT_REMOTE_PIC),
              ),
            ),
            child: Container(
              ///透明黑色遮罩
              decoration: BoxDecoration(
                  color: Color(GSYColors.primaryDarkValue & 0xA0FFFFFF)),
              child: Padding(
                padding: EdgeInsets.only(
                    left: 10.0, top: 0.0, right: 10.0, bottom: 10.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        ///用户名
                        RawMaterialButton(
                          constraints:
                              BoxConstraints(minWidth: 0.0, minHeight: 0.0),
                          padding: EdgeInsets.all(0.0),
                          onPressed: () {
                            NavigatorUtils.goPerson(
                                context, widget.reposHeaderViewModel.ownerName);
                          },
                          child: Text(widget.reposHeaderViewModel.ownerName,
                              style: GSYConstant.normalTextActionWhiteBold),
                        ),
                        Text(" /", style: GSYConstant.normalTextMitWhiteBold),

                        ///仓库名
                        Text(" " + widget.reposHeaderViewModel.repositoryName,
                            style: GSYConstant.normalTextMitWhiteBold),
                      ],
                    ),

                    Row(
                      children: <Widget>[
                        ///仓库语言
                        Text(
                          widget.reposHeaderViewModel.repositoryType ?? "--",
                          style: GSYConstant.smallSubLightText,
                        ),

                        ///仓库大小
                        Text(
                          widget.reposHeaderViewModel.repositorySize ?? "--",
                          style: GSYConstant.smallSubLightText,
                        ),
                        Container(width: 5.3, height: 1.0),

                        ///仓库协议
                        Text(
                          widget.reposHeaderViewModel.license ?? "--",
                          style: GSYConstant.smallSubLightText,
                        ),
                      ],
                    ),

                    ///仓库描述
                    Container(
                      child: Text(
                        widget.reposHeaderViewModel.repositoryDes ?? "---",
                        style: GSYConstant.smallSubLightText,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      margin: EdgeInsets.only(top: 6.0, bottom: 3.0),
                      alignment: Alignment.topLeft,
                    ),

                    ///创建状态
                    Container(
                      margin:
                          EdgeInsets.only(top: 6.0, bottom: 2.0, right: 5.0),
                      alignment: Alignment.topRight,
                      child: RawMaterialButton(
                        onPressed: () {
                          if (widget.reposHeaderViewModel.repositoryIsFork) {
                            NavigatorUtils.goReposDetail(
                              context,
                              widget.reposHeaderViewModel.repositoryParentUser,
                              widget.reposHeaderViewModel.repositoryName,
                            );
                          }
                        },
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        padding: const EdgeInsets.all(0.0),
                        constraints: const BoxConstraints(minHeight: 0.0, minWidth: 0.0),
                        child: Text(_getInfoText(context),
                          style: widget.reposHeaderViewModel.repositoryIsFork
                              ? GSYConstant.smallActionLightText
                              : GSYConstant.smallSubLightText),
                      ),
                    ),

                    Divider(color: Color(GSYColors.subTextColor)),

                    Padding(
                      padding: EdgeInsets.all(0.0),

                      ///创建数值状态
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          ///star
                          _getBottomItem(
                            GSYICons.REPOS_ITEM_STAR,
                            widget.reposHeaderViewModel.repositoryStar,
                            () {
//                              NavigatorUtils.gotoCommonList(context,
//                                  widget.reposHeaderViewModel.repositoryName,
//                                  "user",
//                                  "repo_star",
//                                  userName:
//                                  widget.reposHeaderViewModel.ownerName,
//                                  reposName: widget
//                                      .reposHeaderViewModel.repositoryName);
                            },
                          ),

                          ///fork
                          Container(
                            width: 0.3,
                            height: 25.0,
                            color: Color(GSYColors.subLightTextColor),
                          ),
                          _getBottomItem(
                            GSYICons.REPOS_ITEM_FORK,
                            widget.reposHeaderViewModel.repositoryFork,
                            () {
//                              NavigatorUtils.gotoCommonList(
//                                  context,
//                                  widget.reposHeaderViewModel.repositoryName,
//                                  "repository",
//                                  "repo_fork",
//                                  userName:
//                                  widget.reposHeaderViewModel.ownerName,
//                                  reposName: widget
//                                      .reposHeaderViewModel.repositoryName);
                            },
                          ),

                          ///watch
                          Container(
                            width: 0.3,
                            height: 25.0,
                            color: Color(GSYColors.subLightTextColor),
                          ),
                          _getBottomItem(
                            GSYICons.REPOS_ITEM_WATCH,
                            widget.reposHeaderViewModel.repositoryWatch,
                            () {
//                              NavigatorUtils.gotoCommonList(
//                                  context,
//                                  widget.reposHeaderViewModel.repositoryName,
//                                  "user",
//                                  "repo_watcher",
//                                  userName:
//                                  widget.reposHeaderViewModel.ownerName,
//                                  reposName: widget
//                                      .reposHeaderViewModel.repositoryName);
                            },
                          ),

                          ///issue
                          Container(
                            width: 0.3,
                            height: 25.0,
                            color: Color(GSYColors.subLightTextColor),
                          ),
                          _getBottomItem(
                              GSYICons.REPOS_ITEM_ISSUE,
                              widget.reposHeaderViewModel.repositoryIssue,
                              () {
                                if (widget.reposHeaderViewModel.allIssueCount ==
                                    null ||
                                    widget.reposHeaderViewModel.allIssueCount <=
                                        0) {
                                  return;
                                }
                                List<String> list = [
                                  CommonUtils.getLocale(context)
                                      .repos_all_issue_count +
                                      widget.reposHeaderViewModel.allIssueCount
                                          .toString(),
                                  CommonUtils.getLocale(context)
                                      .repos_open_issue_count +
                                      widget
                                          .reposHeaderViewModel.openIssuesCount
                                          .toString(),
                                  CommonUtils.getLocale(context)
                                      .repos_close_issue_count +
                                      (widget.reposHeaderViewModel
                                          .allIssueCount -
                                          widget.reposHeaderViewModel
                                              .openIssuesCount)
                                          .toString(),
                                ];
                                CommonUtils.showCommitOptionDialog(
                                    context, list, (index) {},
                                    height: 150.0);
                              }
                          ),
                        ],
                      ),
                    ),

                    _renderTopicGroup(context),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ReposHeaderViewModel {
  String ownerName = "---";
  String ownerPic;
  String repositoryName = "---";
  String repositorySize = "---";
  String repositoryStar = "---";
  String repositoryFork = "---";
  String repositoryWatch = "---";
  String repositoryIssue = "---";
  String repositoryIssueClose = "";
  String repositoryIssueAll = "";
  String repositoryType = "---";
  String repositoryDes = "---";
  String repositoryLastActivity = "";
  String repositoryParentName = "";
  String repositoryParentUser = "";
  String created_at = "";
  String push_at = "";
  String license = "";
  List<String> topics;
  int allIssueCount = 0;
  int openIssuesCount = 0;
  bool repositoryStared = false;
  bool repositoryForked = false;
  bool repositoryWatched = false;
  bool repositoryIsFork = false;

  ReposHeaderViewModel();

  ReposHeaderViewModel.fromHttpMap(ownerName, reposName, Repository map) {

    this.ownerName = ownerName;
    if (map == null || map.owner == null) {
      return;
    }
    this.ownerPic = map.owner.avatar_url;
    this.repositoryName = reposName;
    this.allIssueCount = map.allIssueCount;
    this.topics = map.topics;
    this.openIssuesCount = map.openIssuesCount;
    this.repositoryStar =
        map.watchersCount != null ? map.watchersCount.toString() : "";
    this.repositoryFork =
        map.forksCount != null ? map.forksCount.toString() : "";
    this.repositoryWatch =
        map.subscribersCount != null ? map.subscribersCount.toString() : "";
    this.repositoryIssue =
        map.openIssuesCount != null ? map.openIssuesCount.toString() : "";
    //this.repositoryIssueClose = map.closedIssuesCount != null ? map.closed_issues_count.toString() : "";
    //this.repositoryIssueAll = map.all_issues_count != null ? map.all_issues_count.toString() : "";
    this.repositorySize =
        ((map.size / 1024.0)).toString().substring(0, 3) + "M";
    this.repositoryType = map.language;
    this.repositoryDes = map.description;
    this.repositoryIsFork = map.fork;
    this.license = map.license != null ? map.license.name : "";
    this.repositoryParentName = map.parent != null ? map.parent.fullName : null;
    this.repositoryParentUser =
        map.parent != null ? map.parent.owner.login : null;
    this.created_at = CommonUtils.getNewsTimeStr(map.createdAt);
    this.push_at = CommonUtils.getNewsTimeStr(map.pushedAt);
  }
}
