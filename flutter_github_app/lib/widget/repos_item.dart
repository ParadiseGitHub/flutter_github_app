import 'package:flutter/material.dart';
import 'package:flutter_github_app/common/model/Repository.dart';
import 'package:flutter_github_app/common/model/TrendingRepoModel.dart';
import 'package:flutter_github_app/common/style/gsy_style.dart';
import 'package:flutter_github_app/widget/gsy_card_item.dart';
import 'package:flutter_github_app/widget/gsy_icon_text.dart';
import 'package:flutter_github_app/widget/gsy_user_icon_widget.dart';
import 'package:flutter_github_app/common/utils/navigator_utils.dart';

///仓库Item

class ReposItem extends StatelessWidget {

  final ReposViewModel reposViewModel;

  final VoidCallback onPressed;

  ReposItem(this.reposViewModel, {this.onPressed}) : super();

  ///仓库item的底部状态，比如star数量等
  _getBottomItem(BuildContext context, IconData icon, String text, {int flex = 3}) {
    return Expanded(
      flex: flex,
      child: Center(
        child: GSYIconText(
          icon,
          text,
          GSYConstant.smallSubText,
          Color(GSYColors.subTextColor),
          15.0,
          padding: 5.0,
          textWidth: flex == 4
            ? (MediaQuery.of(context).size.width - 100) / 3
            : (MediaQuery.of(context).size.width - 100) / 5,
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      child: GSYCardItem(
        child: FlatButton(
          onPressed: onPressed, 
          child: Padding(
            padding: EdgeInsets.only(left: 0.0, top: 10.0, right: 10.0, bottom: 10.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    ///头像
                    GSYUserIconWidget(
                      padding: const EdgeInsets.only(right: 5.0),
                      width: 40.0,
                      height: 40.0,
                      image: reposViewModel.ownerPic,
                      onPressed: () {
                        //NavigatorUtils.goPerson(context, reposViewModel.ownerName);
                      },
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          ///仓库名
                          Text(
                            reposViewModel.repositoryName ?? "",
                            style: GSYConstant.normalTextBold,
                          ),

                          ///用户名
                          GSYIconText(
                            GSYICons.REPOS_ITEM_USER,
                            reposViewModel.ownerName,
                            GSYConstant.smallSubLightText,
                            Color(GSYColors.subLightTextColor),
                            10.0,
                            padding: 3.0,
                          ),
                        ],
                      ),
                    ),

                    ///仓库语言
                    Text(
                      reposViewModel.repositoryType,
                      style: GSYConstant.smallSubText,
                    ),
                  ],
                ),

                ///仓库描述
                Container(
                  child: Text(
                    reposViewModel.repositoryDes,
                    style: GSYConstant.smallSubText,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  margin: EdgeInsets.only(top: 6.0),
                  alignment: Alignment.topLeft,
                ),

                Padding(padding: EdgeInsets.all(5.0)),

                ///仓库状态数值
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _getBottomItem(context, GSYICons.REPOS_ITEM_STAR, reposViewModel.repositoryStar),
                    SizedBox(width: 5.0),
                    _getBottomItem(context, GSYICons.REPOS_ITEM_FORK, reposViewModel.repositoryFork),
                    SizedBox(width: 5.0),
                    _getBottomItem(context, GSYICons.REPOS_ITEM_ISSUE, reposViewModel.repositoryWatch, flex: 4),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ReposViewModel {
  String ownerName;
  String ownerPic;
  String repositoryName;
  String repositoryStar;
  String repositoryFork;
  String repositoryWatch;
  String hideWatchIcon;
  String repositoryType = "";
  String repositoryDes;

  ReposViewModel();

  ReposViewModel.fromMap(Repository repo) {
    ownerName = repo.owner.login;
    ownerPic = repo.owner.avatar_url;
    repositoryName = repo.name;
    repositoryStar = repo.watchersCount.toString();
    repositoryFork = repo.forksCount.toString();
    repositoryWatch = repo.openIssuesCount.toString();
    repositoryType = repo.language ?? "---";
    repositoryDes = repo.description ?? "---";
  }

  ReposViewModel.fromTrendMap(TrendingRepoModel model) {
    ownerName = model.name;
    if (model.contributors.length > 0) {
      ownerPic = model.contributors[0];
    } else {
      ownerPic = "";
    }
    repositoryName = model.reposName;
    repositoryStar = model.starCount;
    repositoryFork = model.forkCount;
    repositoryWatch = model.meta;
    repositoryType = model.language;
    repositoryDes = model.description;
  }
}