import 'dart:async';
import 'dart:io';

import 'package:flutter_github_app/common/dao/user_dao.dart';
import 'package:flutter_github_app/common/model/User.dart';
import 'package:sqflite/sqflite.dart';

class SqlManager {
  static const _VERSION = 1;

  static const _NAME = 'gsy_github_app_flutter.db';

  static Database _database;

  static init() async {
    // open the database
    var databasesPath = await getDatabasesPath();
    var userRes = await UserDao.getUserInfoLocal();

    String dbName = _NAME;
    if (userRes != null && userRes.result) {
      User user = userRes.data;
      if (user != null && user.login != null) {
        dbName = user.login + "_" + _NAME;
      }
    }

    String path = databasesPath + dbName;
    if (Platform.isIOS) {
      path = databasesPath + "/" + dbName;
    }

    _database = await openDatabase(path, version: _VERSION, onCreate: (Database db, int version) {
      // When creating the db, create the table
      //await db.execute("CREATE TABLE Test (id INTEGER PRIMARY KEY, name TEXT, value INTEGER, num REAL)");
    });
  }

  static isTableExist(String tableName) async {
    await getCurrentDatabase();
    var res = await _database.rawQuery("select * from Sqlite_master where type = 'table' and name = '$tableName'");
    return res != null && res.length > 0;
  }

  static Future<Database> getCurrentDatabase() async {
    if (_database == null) {
      await init();
    }
    return _database;
  }

  ///关闭
  static close() {
    _database?.close();
    _database = null;
  }
}