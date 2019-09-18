import 'dart:async';
import 'dart:io';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_github_app/common/net/address.dart';
import 'package:flutter_github_app/common/net/http_manager.dart';
import 'package:flutter_github_app/common/model/TrendingRepoModel.dart';
import 'package:flutter_github_app/common/dao/dao_result.dart';
import 'package:flutter_github_app/common/net/trending/github_trending.dart';
import 'package:flutter_github_app/common/ab/provider/repos/repository_trend_db_provider.dart';

class ReposDao {

  /**
   * 趋势数据
   * @param page 分页，趋势数据其实没有分页
   * @param since 数据时长， 本日，本周，本月
   * @param languageType 语言
   */
  static getTrendDao({since = 'daily', languageType, page = 0, needDb = true}) async {
    RepositoryTrendDbProvider provider = RepositoryTrendDbProvider();
    String languageTypeDb = languageType ?? "*";

    next() async {
      String url = Address.trending(since, languageType);
      var res = await GitHubTrending().fetchTrending(url);
      if (res != null && res.result && res.data.length > 0) {
        List<TrendingRepoModel> list = List();
        var data = res.data;
        if (needDb) {
          provider.insert(json.encode(data), since, languageTypeDb);
        }
        for (int i = 0; i < data.length; i++) {
          TrendingRepoModel model = data[i];
          list.add(model);
        }
        return DataResult(list, true);
      } else {
        return DataResult(null, false);
      }
    }

    if (needDb) {
      List<TrendingRepoModel> list  = await provider.getData(since, languageTypeDb);
      if (list == null || list.length == 0) {
        return await next();
      }
      DataResult dataResult = DataResult(list, true, next: next);
      return dataResult;
    }
  }

  ///仓库的详情数据
  static getRepositoryDetailDao(userName, repoName, branch, {needDb = true}) async {

  }

  ///仓库活动事件
  static getRepositoryEventDao(userName, repoName, {page = 0, branch = "master", needDb = false}) async {

  }

  ///获取用户对当前仓库的star、watch状态
  static getRepositoryStatusDao(userName, repoName) async {
    String urlStar = Address.resolveStarRepos(userName, repoName);
    String urlWatch = Address.resolveWatcherRepos(userName, repoName);

    var resStar = await httpManager.netFetch(urlStar, null, null, Options(contentType: ContentType.text), noTip: true);
    var resWatch = await httpManager.netFetch(urlWatch, null, null, Options(contentType: ContentType.text), noTip: true);
    var data = {"star": resStar.result, "watch": resWatch.result};

    return DataResult(data, true);
  }

  ///获取仓库的提交列表
  static getRepositoryCommitsDao(userName, repoName, {page = 0, branch = "master", needDb = false}) async {

  }

  ///获取仓库的文件列表
  static getRepoFileDirDao() async {

  }

  ///获取当前仓库所有分支
  static getBranchesDao(userName, repoName) async {
    String url = Address.getBranches(userName, repoName);
    var res = await httpManager.netFetch(url, null, null, null);
    if (res != null && res.result && res.data.length > 0) {
      List<String> list = List();
      var dataList = res.data;
      if (dataList == null || dataList.length == 0) {
        return DataResult(null, false);
      }
      for (int i = 0; i < dataList.length; i++) {
        var data = dataList[i];
        list.add(data['name']);
      }
      return DataResult(list, true);
    } else {
      return DataResult(null, false);
    }
  }

  ///用户的前100仓库
  static getUserRepository100StatusDao(userName) async {
//    String url = Address.userRepo(userName, 'pushed') + "&page=1&per_page=100";
//    var res = await httpManager.netFetch(url, null, null, null);

  }

  ///详情的remde数据
  static getRepositoryDetailReadmeDao(userName, reposName, branch, {needDb = true}) async {
    String fullName = userName + "/" + reposName;
//    RepositoryDetailReadmeDbProvider provider = RepositoryDetailReadmeDbProvider();

    next() async {
      String url = Address.readmeFile(userName + '/' + reposName, branch);
      var res = await httpManager.netFetch(
          url,
          null,
          {"Accept": 'application/vnd.github.VERSION.raw'},
          new Options(contentType: ContentType.text));
      //var res = await httpManager.netFetch(url, null, {"Accept": 'application/vnd.github.html'}, new Options(contentType: ContentType.text));
      if (res != null && res.result) {
        if (needDb) {
//          provider.insert(fullName, branch, res.data);
        }
        return new DataResult(res.data, true);
      }
      return new DataResult(null, false);
    }

    if (needDb) {
//      String readme = await provider.getRepositoryReadme(fullName, branch);
//      if (readme == null) {
//        return await next();
//      }
//      DataResult dataResult = new DataResult(readme, true, next: next);
//      return dataResult;
    }
    return await next();
  }

}