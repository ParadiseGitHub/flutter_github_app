import 'package:rxdart/rxdart.dart';
import 'package:flutter_github_app/common/dao/repos_dao.dart';
import 'package:flutter_github_app/common/model/TrendingRepoModel.dart';

class TrendBloc {

  bool _isLoading = false;
  bool _requested = false;

  ///是否正在loading
  bool get isLoading => _isLoading;
  ///是否已经请求过
  bool get requested => _requested;

  ///rxdart 实现的 stream
  var _subject = PublishSubject<List<TrendingRepoModel>>();

  Observable<List<TrendingRepoModel>> get stream => _subject.stream;

  ///根据数据库和网络返回数据
  Future<void> requestRefresh(selectTime, selectType) async {
    _isLoading = true;

    var res = await ReposDao.getTrendDao(since: selectTime.value, languageType: selectType.value);
    if (res != null && res.result) {
      _subject.add(res.data);
    }
    await doNext(res);
    _isLoading = false;
    _requested = true;
    return;
  }

  ///请求next, 是否有网络
  doNext(res) async {
    if (res.next != null) {
      var resNext = await res.next();
      if (resNext != null && resNext.result) {
        _subject.add(resNext.data);
      }
    }
  }
}