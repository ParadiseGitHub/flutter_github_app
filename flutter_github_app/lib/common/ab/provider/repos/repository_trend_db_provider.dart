import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_github_app/common/ab/sql_provider.dart';
import 'package:flutter_github_app/common/utils/common_utils.dart';
import 'package:flutter_github_app/common/utils/code_utils.dart';
import 'package:flutter_github_app/common/model/TrendingRepoModel.dart';

///Trend DB

class RepositoryTrendDbProvider extends BaseDbProvider {

  final String name = 'TrendRepository';

  int id;
  String data;
  String since;
  String language;
  String fullName;

  final String columnId = "_id";
  final String columnData = "data";
  final String columnSince = "since";
  final String columnLanguageType = "languageType";

  RepositoryTrendDbProvider();

  Map<String, dynamic> toMap(String dataMapString, String since, String language) {
    Map<String, dynamic> map = {columnSince: since, columnLanguageType: language, columnData: dataMapString};
    if (id != null) {
      map[columnId] = id;
    }
    return map;
  }

  RepositoryTrendDbProvider.fromMap(Map map) {
    id = map[columnId];
    data = map[columnData];
    since = map[columnSince];
    language = map[columnLanguageType];
  }

  @override
  tableSqlString() {
    return tableBaseString(name, columnId) +
        '''
        $columnData text not null,
        $columnSince text not null,
        $columnLanguageType text not null)
        ''';
  }

  @override
  tableName() {
    return name;
  }

  ///插入到数据库
  Future insert(String dataMapString, String since, String language) async {
    Database db = await getDataBase();

    ///清空上次存储数据后，再插入数据，因为数据库只做第一页数据存储
    db.execute("delete from $name");
    return await db.insert(name, toMap(dataMapString, since, language));
  }

  ///获取数据
  Future<List<TrendingRepoModel>> getData(String since, String language) async {
    Database db = await getDataBase();

    List<Map> maps = await db.query(
      name,
      columns: [columnId, columnData, columnSince, columnLanguageType],
      where: "$columnSince = ? and $columnLanguageType = ?",
      whereArgs: [since, language],
    );

    List<TrendingRepoModel> list = List();

    if (maps.length > 0) {
      RepositoryTrendDbProvider provider = RepositoryTrendDbProvider.fromMap(maps.first);

      ///使用 compute 的 Isolate 优化 json decode
      List<dynamic> eventMap = await compute(CodeUtils.decodeListResult, provider.data);

      if (eventMap.length > 0) {
        for (var item in eventMap) {
          list.add(TrendingRepoModel.fromJson(item));
        }
      }
    }
    return list;
  }
}