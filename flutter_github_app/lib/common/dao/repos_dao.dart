import 'dart:async';
import 'dart:io';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:flutter_github_app/common/config/config.dart';
import 'package:flutter_github_app/common/model/Event.dart';
import 'package:flutter_github_app/common/model/RepoCommit.dart';
import 'package:flutter_github_app/common/model/Repository.dart';
import 'package:flutter_github_app/common/model/User.dart';
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
    String fullName = userName + "/" + repoName;
//    RepositoryDetailDbProvider provider = new RepositoryDetailDbProvider();

    next() async {
      String url = Address.getReposDetail(userName, repoName) + "?ref=" + branch;
      var res = await httpManager.netFetch(url, null,
          {"Accept": 'application/vnd.github.mercy-preview+json'}, null);
      if (res != null && res.result && res.data.length > 0) {
        var data = res.data;
        if (data == null || data.length == 0) {
          return new DataResult(null, false);
        }
        Repository repository = Repository.fromJson(data);
        var issueResult =
        await ReposDao.getRepositoryIssueStatusDao(userName, repoName);
        if (issueResult != null && issueResult.result) {
          repository.allIssueCount = int.parse(issueResult.data);
        }
        if (needDb) {
//          provider.insert(fullName, json.encode(repository.toJson()));
        }
//        saveHistoryDao(fullName, DateTime.now(), json.encode(repository.toJson()));
        return new DataResult(repository, true);
      } else {
        return new DataResult(null, false);
      }
    }

    if (needDb) {
//      Repository repository = await provider.getRepository(fullName);
//      if (repository == null) {
//        return await next();
//      }
//      DataResult dataResult = new DataResult(repository, true, next: next);
//      return dataResult;
    }
    return await next();
  }

  ///获取issue总数
  static getRepositoryIssueStatusDao(userName, repository) async {
    String url = Address.getReposIssue(userName, repository, null, null, null) +
        "&per_page=1";
    var res = await httpManager.netFetch(url, null, null, null);
    if (res != null && res.result && res.headers != null) {
      try {
        List<String> link = res.headers['link'];
        if (link != null) {
          int indexStart = link[0].lastIndexOf("page=") + 5;
          int indexEnd = link[0].lastIndexOf(">");
          if (indexStart >= 0 && indexEnd >= 0) {
            String count = link[0].substring(indexStart, indexEnd);
            return new DataResult(count, true);
          }
        }
      } catch (e) {
        print(e);
      }
    }
    return new DataResult(null, false);
  }

  ///仓库活动事件
  static getRepositoryEventDao(userName, repoName, {page = 0, branch = "master", needDb = false}) async {
    String fullName = userName + "/" + repoName;

//    RepositoryEventDbProvider provider = new RepositoryEventDbProvider();

    next() async {
      String url = Address.getReposEvent(userName, repoName) +
                   Address.getPageParams("?", page);
      var res = await httpManager.netFetch(url, null, null, null);
      if (res != null && res.result) {
        List<Event> list = List();
        var data = res.data;
        if (data == null || data.length == 0) {
          return DataResult(null, false);
        }
        for (int i = 0; i < data.length; i++) {
          list.add(Event.fromJson(data[i]));
        }
        if (needDb) {
//          provider.insert(fullName, json.encode(data));
        }
        return DataResult(list, true);
      } else {
        return DataResult(null , false);
      }
    }

    if (needDb) {
//      List<Event> list = await provider.getEvents(fullName);
//      if (list == null) {
//        return await next();
//      }
//      DataResult dataResult = new DataResult(list, true, next: next);
//      return dataResult;
    }
    return await next();
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
  static getReposCommitsDao(userName, repoName, {page = 0, branch = "master", needDb = false}) async {
    String fullName = userName + "/" + repoName;

//    RepositoryCommitsDbProvider provider = new RepositoryCommitsDbProvider();

    next() async {
      String url = Address.getReposCommits(userName, repoName) +
                   Address.getPageParams("?", page) + "&sha=" + branch;

      var res = await httpManager.netFetch(url, null, null, null);
      if (res != null && res.result) {
        List<RepoCommit> list = List();
        var data = res.data;
        if (data == null || data.length == 0) {
          return DataResult(null, false);
        }
        for (int i = 0; i < data.length; i++) {
          list.add(RepoCommit.fromJson(data[i]));
        }
        if (needDb) {
//          provider.insert(fullName, branch, json.encode(data));
        }
        return DataResult(list, true);
      } else {
        return DataResult(null, false);
      }
    }

    if (needDb) {
//      List<RepoCommit> list = await provider.getData(fullName, branch);
//      if (list == null) {
//        return await next();
//      }
//      DataResult dataResult = DataResult(list, true, next: next);
//      return dataResult;
    }
    return await next();
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