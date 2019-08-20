import 'package:dio/dio.dart';
import 'package:flutter_github_app/common/net/result_data.dart';
import 'package:flutter_github_app/common/net/code.dart';

class ResponseInterceptors extends InterceptorsWrapper {

  @override
  onResponse(Response response) {
    RequestOptions options = response.request;
    try {
      if (options.contentType != null && options.contentType.primaryType == "text") {
        return ResultData(response.data, true, Code.SUCCESS);
      }
      if (response.statusCode == 200 || response.statusCode == 201) {
        return new ResultData(response.data, true, Code.SUCCESS, headers: response.headers);
      }
    } catch (e) {
      print(e.toString() + options.path);
      return new ResultData(response.data, false, response.statusCode, headers: response.headers);
    }
  }
}