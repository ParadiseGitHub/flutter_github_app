import 'package:dio/dio.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter_github_app/common/net/code.dart';
import 'package:flutter_github_app/common/net/result_data.dart';

class ErrorInterceptors extends InterceptorsWrapper {
  final Dio _dio;

  ErrorInterceptors(this._dio);

  @override
  onRequest(RequestOptions options) async {
    //没有网络
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      return _dio.resolve(ResultData(Code.errorHandleFunction(Code.NETWORK_ERROR, "", false), false, Code.NETWORK_ERROR));
    }
    return options;
  }
}