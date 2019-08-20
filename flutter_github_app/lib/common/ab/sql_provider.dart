import 'dart:async';
/**
 * 数据库表
 * Created by guoshuyu
 * Date: 2018-08-03
 */
import 'package:flutter_github_app/common/ab/sql_manager.dart';
import 'package:meta/meta.dart';
import 'package:sqflite/sqflite.dart';

abstract class BaseDbProvider {
  bool isTableExist = false;

  tableSqlString();

  tableName();

  tableBaseString(String name, String columnId) {
    return '''
      create table $name (
      $columnId integer primary key autoincrement,
    ''';
  }

  Future<Database> getDataBase() async {
    return await open();
  }

  @mustCallSuper
  prepare(name, String createSql) async {
    isTableExist = await SqlManager.isTableExist(name);
    if (!isTableExist) {
      Database db = await SqlManager.getCurrentDatabase();
      return await db.execute(createSql);
    }
  }

  @mustCallSuper
  open() async {
    if (!isTableExist) {
      await prepare(tableName(), tableSqlString());
    }
    return await SqlManager.getCurrentDatabase();
  }
}