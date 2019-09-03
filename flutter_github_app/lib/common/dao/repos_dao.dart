import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:flutter_github_app/common/net/address.dart';
import 'package:flutter_github_app/common/net/http_manager.dart';

class ReposDao {

  /**
   * 趋势数据
   * @param page 分页，趋势数据其实没有分页
   * @param since 数据时长， 本日，本周，本月
   * @param languageType 语言
   */
  static getTrendDao() {

  }

  ///仓库的详情数据
  static getRepositoryDetailDao(userName, repoName, branch, {needDb = true}) async {

  }

  ///仓库活动事件
  static getRepositoryEventDao(userName, repoName, {page = 0, branch = "master", needDb = false}) async {

  }

  ///获取用户对当前仓库的star、watcher状态
  static getRepositoryStatusDao(userName, repoName) async {

  }

  ///获取仓库的提交列表
  static getRepositoryCommitsDao(userName, repoName, {page = 0, branch = "master", needDb = false}) async {

  }

  ///获取仓库的文件列表
  static getRepoFileDirDao() async {

  }

  ///用户的前100仓库
  static getUserRepository100StatusDao(userName) async {
//    String url = Address.userRepo(userName, 'pushed') + "&page=1&per_page=100";
//    var res = await httpManager.netFetch(url, null, null, null);

  }
}