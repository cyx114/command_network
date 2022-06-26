import 'package:dio/dio.dart';

import 'package:command_network/src/base_request.dart';
import 'package:flutter/material.dart';

class JsonValidateInterceptor extends QueuedInterceptor {
  JsonValidateInterceptor(this.validator);

  bool Function(Response response) validator;

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // print('[json interceptor]');
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
