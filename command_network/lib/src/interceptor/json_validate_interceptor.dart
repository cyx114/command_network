import 'package:dio/dio.dart';

import 'package:command_network/src/base_request.dart';

class JsonValidateInterceptor extends QueuedInterceptor {
  JsonValidateInterceptor(this.validator);

  bool Function(Response response) validator;

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (validator(response)) {
      handler.next(response);
    } else {
      handler.reject(DioError(
          requestOptions: response.requestOptions,
          response: response,
          error: CmdError(CmdErrorType.jsonValidateError,)));
    }
  }

}
