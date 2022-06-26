import 'dart:core';

import 'package:command_network/src/adapter/dio_network_adapter.dart';
import 'package:command_network/src/base_request.dart';

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
          interceptors: request.getRequiredInterceptors());
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
      result = Result(false, error: request.error);
    } on Exception catch (error) {
      assert(true,
          'There should not be any [Exception] error when request, error: $error');
      request.error = CmdError(CmdErrorType.requestError, error: error);
      result = Result(false, error: request.error);
    }
    request.result = result;
    return result;
  }

  void cancelRequest(BaseRequest request) {
    request.cancelToken.cancel('cancelled');
  }

}
