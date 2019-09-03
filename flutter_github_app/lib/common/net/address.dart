import 'package:flutter_github_app/common/config/config.dart';

class Address {
  static const String host = "https://api.github.com/";
  static const String hostWeb = "https://github.com/";
  static const String downloadUrl = 'https://www.pgyer.com/GSYGithubApp';
  static const String graphicHost = 'https://ghchart.rshah.org/';
  static const String updateUrl = 'https://www.pgyer.com/vj2B';

  static getAuthorization() {
    return "${host}authorizations";
  }

  ///我的用户信息 GET
  static getMyUserInfo() {
    return "${host}user";
  }

  ///用户信息 get
  static getUserInfo(userName) {
    return "${host}users/$userName";
  }

  ///用户的star get
  static userStar(userName, sort) {
    sort ??= 'updated';

    return "${host}users/$userName/starred?sort=$sort";
  }

  ///用户收到的事件信息
  static getEventReceived(userName) {
    return "${host}users/$userName/received_events";
  }

  ///用户相关的事件信息 get
  static getEvent(userName) {
    return "${host}users/$userName/events";
  }

  ///组织成员
  static getMember(orgs) {
    return "${host}orgs/$orgs/members";
  }


  ///处理分页参数
  static getPageParams(tab, page, [pageSize = Config.PAGE_SIZE]) {
    if (page != null) {
      if (pageSize != null) {
        return "${tab}page=$page&per_page=$pageSize";
      } else {
        return "${tab}page=$page";
      }
    } else {
      return "";
    }
  }

}