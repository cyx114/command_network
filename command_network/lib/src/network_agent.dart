import 'dart:core';

import 'package:command_network/src/adapter/dio_network_adapter.dart';
import 'package:command_network/src/base_request.dart';
import 'package:command_network/src/interceptor/authentication_interceptor.dart';
import 'package:command_network/src/interceptor/json_validate_interceptor.dart';

class NetworkAgent {
  static final NetworkAgent _singleton = NetworkAgent._internal();

  factory NetworkAgent() {
    return _singleton;
  }

  NetworkAgent._internal();

  Future<Result> addRequest(BaseRequest request) async {
    Result result;
    try {
      Response response = await sendRequest(request,
          interceptors: _getNeededInterceptors(request));
      request.response = response;
      result = Result(true, data: response.data);
    } on DioError catch (error) {
      CmdError cmdError;
      if (error.error is CmdError) {
        cmdError = error.error;
      } else {
        cmdError = CmdError(CmdErrorType.requestError);
      }
      cmdError.error = error;
      request.error = cmdError;
      request.response = error.response;
    } on Exception catch (error) {
      assert(true,
          'There should not be any [Exception] error when request, error: $error');
    }
    result = Result(false, error: request.error);
    request.result = result;
    return result;
  }

  void cancelRequest(BaseRequest request) {
    request.cancelToken.cancel('cancelled');
  }

  List<Interceptor> _getNeededInterceptors(BaseRequest request) {
    List<Interceptor> interceptors = [];
    switch (request.authType) {
      case AuthType.basicOrDigest:
      case AuthType.basic:
      case AuthType.digest:
        interceptors.add(DigestAuthInterceptor(request));
        break;
      case AuthType.none:
      case AuthType.jwt:
        break;
    }
    interceptors.add(JsonValidateInterceptor(request.jsonValidate));
    return interceptors;
  }
}
