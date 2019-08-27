import 'dart:convert';
import 'package:flutter_github_app/common/model/Event.dart';
import 'package:flutter_github_app/common/net/address.dart';
import 'package:flutter_github_app/common/net/http_manager.dart';
import 'package:flutter_github_app/common/dao/dao_result.dart';
import 'package:flutter_github_app/common/ab/provider/received_event_db_provider.dart';

class EventDao {

  static getEventReceived(String userName, {page = 1, bool needDb = false}) async {
    if (userName == null) {
      return null;
    }

    ReceivedEventDbProvider provider = new ReceivedEventDbProvider();

    next() async {
      String url = Address.getEventReceived(userName) + Address.getPageParams("?", page);

      var res = await httpManager.netFetch(url, null, null, null);
      if (res != null && res.result) {
        List<Event> list = List();
        var data = res.data;
        if (data == null || data.length == 0) {
          return null;
        }
        if (needDb) {
          await provider.insert(json.encode(data));
        }
        for (int i = 0; i < data.length; i++) {
          list.add(Event.fromJson(data[i]));
        }
        return DataResult(list, true);
      } else {
        return DataResult(null, false);
      }
    }

    if (needDb) {
      List<Event> dbList = await provider.getEvents();
      if (dbList == null || dbList.length == 0) {
        return await next();
      }
      DataResult dataResult = new DataResult(dbList, true, next: next);
      return dataResult;
    }

    return await next();
  }

}