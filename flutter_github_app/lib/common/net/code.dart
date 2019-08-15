import 'package:flutter_github_app/common/event/event_bus.dart';
import 'package:flutter_github_app/common/event/http_error_event.dart';

class Code {
  static const NETWORK_ERROR = -1;

  static const NETWORK_TIMEOUT = -2;

  static const NETWORK_JSON_EXCEPTION = -3;

  static const SUCCESS = 200;

  static errorHandleFunction(code, message, noTip) {
    if (noTip) {
      return message;
    }
    eventBus.fire(HttpErrorEvent(code, message));
    return message;
  }
}