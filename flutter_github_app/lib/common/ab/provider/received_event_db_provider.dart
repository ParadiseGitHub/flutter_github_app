import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_github_app/common/model/Event.dart';
import 'package:flutter_github_app/common/ab/sql_provider.dart';
import 'package:flutter_github_app/common/utils/code_utils.dart';

/**
 * 用户接受事件表
 */

class ReceivedEventDbProvider extends BaseDbProvider {

  final String name = "ReceivedEvent";
  final String columnId = "_id";
  final String columnData = "data";

  int id;
  String data;

  ReceivedEventDbProvider();

  Map<String, dynamic> toMap(String eventMapString) {
    Map<String, dynamic> map = {columnData: eventMapString};
    if (id != null) {
      map[columnId] = id;
    }
    return map;
  }

  ReceivedEventDbProvider.fromMap(Map map) {
    id = map[columnId];
    data = map[columnData];
  }

  @override
  tableSqlString() {
    return tableBaseString(name, columnId) +
      '''
      $columnData text not null)
      ''';
  }

  @override
  tableName() {
    return name;
  }

  ///插入到数据库
  Future insert(String eventMapString) async {
    Database db = await getDataBase();

    ///清空后再插入，因为只保留第一页数据
    db.execute("delete from $name");
    return await db.insert(name, toMap(eventMapString));
  }

  ///获取事件数据
  Future<List<Event>> getEvents() async {
    Database db = await getDataBase();
    List<Map> maps = await db.query(name, columns: [columnId, columnData]);
    List<Event> list = List();

    if (maps.length > 0) {
      ReceivedEventDbProvider provider = ReceivedEventDbProvider.fromMap(maps.first);

      ///使用 compute 的 Isolate 优化 json decode
      List<dynamic> eventMap = await compute(CodeUtils.decodeListResult, provider.data);

      if (eventMap.length > 0) {
        for (var item in eventMap) {
          list.add(Event.fromJson(item));
        }
      }
    }
    return list;
  }
}
