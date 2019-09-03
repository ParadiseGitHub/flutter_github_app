import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_github_app/common/localization/default_localizations.dart';
import 'package:flutter_github_app/common/model/User.dart';
import 'package:flutter_github_app/common/model/UserOrg.dart';
import 'package:flutter_github_app/common/style/gsy_style.dart';
import 'package:flutter_github_app/common/utils/common_utils.dart';
import 'package:flutter_github_app/common/utils/navigator_utils.dart';
import 'package:flutter_github_app/widget/gsy_card_item.dart';
import 'package:flutter_github_app/widget/gsy_icon_text.dart';
import 'package:flutter_github_app/widget/gsy_user_icon_widget.dart';

/**
 * 用户详情头部
 */

class UserHeaderItem extends StatelessWidget {

  final User userInfo;
  final String beStaredCount;
  final Color notifyColor;
  final Color themeColor;
  final VoidCallback refreshCallBack;
  final List<UserOrg> orgList;

  UserHeaderItem(this.userInfo, this.beStaredCount, this.themeColor,
      {this.notifyColor, this.refreshCallBack, this.orgList});

  ///通知Icon
  _getNotifyIcon(BuildContext context, Color color) {
    if (notifyColor == null) {
      return Container();
    }
    return RawMaterialButton(
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      padding: const EdgeInsets.only(top: 0.0, right: 5.0, left: 5.0),
      constraints: const BoxConstraints(minWidth: 0.0, minHeight: 0.0),
      child: ClipOval(
        child: Icon(
          GSYICons.USER_NOTIFY,
          color: color,
          size: 18.0,
        ),
      ),
      onPressed: () {
        NavigatorUtils.goNotifyPage(context).then((res) {
          refreshCallBack?.call();
        });
      },
    );
  }

  ///用户组织
  _renderOrgs(BuildContext context, List<UserOrg> orgList) {
    if (orgList == null || orgList.length == 0) {
      return Container();
    }
    List<Widget> list = List();

    renderOrgsItem(UserOrg org) {
      return GSYUserIconWidget(
        padding: const EdgeInsets.only(left: 5.0, right: 5.0),
        width: 30.0,
        height: 30.0,
        image: org.avatarUrl ?? GSYICons.DEFAULT_REMOTE_PIC,
        onPressed: () {
          NavigatorUtils.goPerson(context, org.login);
        },
      );
    }

    int length = orgList.length > 3 ? 3 : orgList.length;

    list.add(Text(CommonUtils.getLocale(context).user_orgs_title + ":", style: GSYConstant.smallSubLightText,));

    for (int i = 0; i < length; i++) {
      list.add(renderOrgsItem(orgList[i]));
    }

    if (orgList.length > 3) {
      list.add(RawMaterialButton(
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        padding: const EdgeInsets.only(left: 5.0, right: 5.0),
        constraints: BoxConstraints(minWidth: 0.0, minHeight: 0.0),
        child: Icon(
          Icons.more_horiz,
          color: Color(GSYColors.white),
          size: 18.0,
        ),
        onPressed: () {
          //NavigatorUtils.gotoCommonList();
        },
      ));
    }

    return Row(children: list);
  }


  @override
  Widget build(BuildContext context) {
    return GSYCardItem(
      color: themeColor,
      elevation: 0,
      margin: EdgeInsets.all(0.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(0.0),
          bottomRight: Radius.circular(0.0),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.only(left: 10.0, right: 10.0, top: 10.0, bottom: 10.0),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                ///头像
                RawMaterialButton(
                  padding: const EdgeInsets.all(0.0),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  constraints: BoxConstraints(minWidth: 0.0, minHeight: 0.0),
                  child: ClipOval(
                    child: FadeInImage.assetNetwork(
                      placeholder: GSYICons.DEFAULT_USER_ICON,
                      fit: BoxFit.fitWidth,
                      width: 80.0,
                      height: 80.0,
                      image: userInfo.avatar_url ?? GSYICons.DEFAULT_REMOTE_PIC,
                    ),
                  ),
                ),
                Padding(padding: EdgeInsets.all(10.0)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          ///用户名
                          Text(userInfo.login ?? "",
                            style: GSYConstant.largeTextWhiteBold),
                          _getNotifyIcon(context, notifyColor),
                        ],
                      ),
                      Text(userInfo.name == null ? "" : userInfo.name,
                        style: GSYConstant.smallSubLightText,
                      ),

                      ///用户组织
                      GSYIconText(
                        GSYICons.USER_ITEM_COMPANY,
                        userInfo.company ?? CommonUtils.getLocale(context).nothing_now,
                        GSYConstant.smallSubLightText,
                        Color(GSYColors.subLightTextColor),
                        10.0,
                        padding: 3.0,
                      ),

                      ///用户位置
                      GSYIconText(
                        GSYICons.USER_ITEM_LOCATION,
                        userInfo.location ?? CommonUtils.getLocale(context).nothing_now,
                        GSYConstant.smallSubLightText,
                        Color(GSYColors.subLightTextColor),
                        10.0,
                        padding: 3.0,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Container(
              ///用户博客
              child:  RawMaterialButton(
                padding: const EdgeInsets.all(0.0),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                constraints: const BoxConstraints(minWidth: 0.0, minHeight: 0.0),
                child: GSYIconText(
                  GSYICons.USER_ITEM_LINK,
                  userInfo.blog ?? CommonUtils.getLocale(context).nothing_now,
                  (userInfo.blog == null) ? GSYConstant.smallSubLightText : GSYConstant.smallActionLightText,
                  Color(GSYColors.subLightTextColor),
                  10.0,
                  padding: 3.0,
                  textWidth: MediaQuery.of(context).size.width - 50,
                ),
                onPressed: () {
                  if (userInfo.blog != null) {
                    //CommonUtils.launchOutURL(userInfo.blog, context);
                  }
                },
              ),
              margin: EdgeInsets.only(top: 6.0, bottom: 2.0),
              alignment: Alignment.topLeft,
            ),

            ///组织
            _renderOrgs(context, orgList),

            ///用户描述
            Container(
              child: Text(
                userInfo.bio == null ? "" : userInfo.bio,
                style: GSYConstant.smallSubLightText,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              alignment: Alignment.topLeft,
            ),

            ///用户创建时间
            Container(
              child: Text(
                CommonUtils.getLocale(context).user_create_at + CommonUtils.getDateStr(userInfo.created_at),
                style: GSYConstant.smallSubLightText,
                overflow: TextOverflow.ellipsis,
              ),
              margin: EdgeInsets.only(top: 6.0, bottom: 2.0),
              alignment: Alignment.topLeft,
            ),

            Padding(padding:  EdgeInsets.only(bottom: 5.0)),
          ],
        ),
      ),
    );
  }
}

class UserHeaderBottom extends StatelessWidget {

  final User userInfo;
  final String beStaredCount;
  final Radius radius;
  final List honorList;

  UserHeaderBottom(this.userInfo, this.beStaredCount, this.radius, this.honorList);

  ///底部状态栏
  _getBottomItem(String title, var value, onPressed) {
    String data = value == null ? "" : value.toString();
    TextStyle valueStyle = (value != null && value.toString().length > 6)
        ? GSYConstant.minText
        : GSYConstant.smallSubLightText;
    TextStyle titleStyle = (title != null && title.toString().length > 6)
        ? GSYConstant.minText
        : GSYConstant.smallSubLightText;

    return Expanded(
      child: Center(
        child: RawMaterialButton(
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          padding: EdgeInsets.only(top: 5.0),
          constraints: BoxConstraints(minHeight: 5.0, minWidth: 5.0),
          child: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              children: [
                TextSpan(text: title, style: titleStyle),
                TextSpan(text: "\n", style: valueStyle),
                TextSpan(text: data, style: valueStyle),
              ],
            ),
          ),
          onPressed: onPressed,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GSYCardItem(
      color: Theme.of(context).primaryColor,
      margin: EdgeInsets.all(0.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(bottomRight: radius, bottomLeft: radius)
      ),
      child: Container(
        alignment: Alignment.center,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[

            _getBottomItem(GSYLocalizations.of(context).currentLocalized.user_tab_repos,
              userInfo.public_repos,
              () {
//                NavigatorUtils.gotoCommonList(
//                    context, userInfo.login, "repository", "user_repos",
//                    userName: userInfo.login);
              },
            ),

            Container(
              width: 0.3,
              height: 40.0,
              alignment: Alignment.center,
              color: Color(GSYColors.subLightTextColor),
            ),
            _getBottomItem(CommonUtils.getLocale(context).user_tab_fans,
              userInfo.followers,
              () {
//                NavigatorUtils.gotoCommonList(
//                    context, userInfo.login, "user", "follower",
//                    userName: userInfo.login);
              },
            ),

            Container(
              width: 0.3,
              height: 40.0,
              alignment: Alignment.center,
              color: Color(GSYColors.subLightTextColor),
            ),
            _getBottomItem(
              CommonUtils.getLocale(context).user_tab_focus,
              userInfo.following,
                  () {
//                NavigatorUtils.gotoCommonList(
//                    context, userInfo.login, "user", "followed",
//                    userName: userInfo.login);
              },
            ),

            Container(
              width: 0.3,
              height: 40.0,
              alignment: Alignment.center,
              color: Color(GSYColors.subLightTextColor),
            ),
            _getBottomItem(
              CommonUtils.getLocale(context).user_tab_star,
              userInfo.starred,
                  () {
//                NavigatorUtils.gotoCommonList(
//                    context, userInfo.login, "repository", "user_star",
//                    userName: userInfo.login);
              },
            ),

            Container(
              width: 0.3,
              height: 40.0,
              alignment: Alignment.center,
              color: Color(GSYColors.subLightTextColor),
            ),
            _getBottomItem(
              CommonUtils.getLocale(context).user_tab_honor,
              beStaredCount,
                  () {
                if (honorList != null) {
//                  NavigatorUtils.goHonorListPage(context, honorList);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class UserHeaderChart extends StatelessWidget {

  final User userInfo;

  UserHeaderChart(this.userInfo);

  _renderChart(context) {
    double height = 140.0;
    double width = 3 * MediaQuery.of(context).size.width / 2;

    if (userInfo.login != null && userInfo.type == "Organization") {
      return Container();
    }

    return(userInfo.login != null)
        ? Card(
            margin: EdgeInsets.only(left: 10.0, top: 0.0, right: 10.0, bottom: 0.0),
            color: Color(GSYColors.white),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Container(
                padding: EdgeInsets.only(left: 10.0, right: 10.0),
                width: width,
                height: height,

                ///svg chart
                child: SvgPicture.network(
                  CommonUtils.getUserChartAddress(userInfo.login),
                  width: width,
                  height: height - 10,
                  allowDrawingOutsideViewBox: true,
                  placeholderBuilder: (BuildContext context) => Container(
                    height: height,
                    width: width,
                    child: Center(
                      child: SpinKitRipple(color: Theme.of(context).primaryColor),
                    ),
                  ),
                ),
              ),
            ),
          )
        : Container(
            height: height,
            child: Center(
              child: SpinKitRipple(color: Theme.of(context).primaryColor),
            ),
          );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          Container(
            child: Text(
              (userInfo.type == "Organization")
                ? CommonUtils.getLocale(context).user_dynamic_group
                : CommonUtils.getLocale(context).user_dynamic_title,
              style: GSYConstant.normalTextBold,
              overflow: TextOverflow.ellipsis,
            ),
            margin: EdgeInsets.only(top: 15.0, bottom: 15.0, left: 12.0),
            alignment: Alignment.topLeft,
          ),
          _renderChart(context),
        ],
      ),
    );
  }
}


