import 'package:dio/dio.dart';
import 'package:flutter_github_app/common/config/config.dart';

class LogInterceptors extends InterceptorsWrapper {

  @override
  onRequest(RequestOptions options) {
    if (Config.DEBUG) {
      print("请求url: ${options.path}");
      print("请求头: ${options.headers.toString()}");
      if (options.data != null) {
        print("请求参数: ${options.data.toString()}");
      }
    }
    return options;
  }

  @override
  onResponse(Response response) {
    if (Config.DEBUG) {
      if (response != null) {
        print('返回参数: ' + response.toString());
      }
    }
    return response;
  }

  @override
  onError(DioError error) {
    if (Config.DEBUG) {
      print('请求异常: ' + error.toString());
      print('请求异常信息: ' + error.response?.toString() ?? "");
    }
    return error;
  }
}