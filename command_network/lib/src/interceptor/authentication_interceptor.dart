import 'package:command_network/src/base_request.dart';
import 'package:command_network/src/adapter/dio_network_adapter.dart';
import 'package:command_network/src/header_const.dart';
import 'package:command_network/src/helper/authentication_helper.dart';

class DigestAuthInterceptor extends QueuedInterceptor {
  DigestAuthInterceptor(this.request);

  BaseRequest request;

  @override
  void onError(DioError err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode != 401) {
      handler.next(err);
      return;
    }
    String wwwAuthString =
        err.response!.headers[Headers.wwwAuthenticateHeader]![0];
    if (wwwAuthString.isEmpty) {
      handler.next(err);
      return;
    }
    String authString = '';
    if (wwwAuthString.startsWith(HeaderConst.digest)) {
      authString = generateDigestAuthString(request, wwwAuthString, err);
    } else if (wwwAuthString.startsWith(HeaderConst.basic)) {
      authString = generateBasicAuthString(
          request.authInfo.username, request.authInfo.password);
    }
    if (authString.isEmpty) {
      handler.next(err);
    }
    request.authInfo.authString = authString;
    // print('[auth interceptor] ${request.authInfo.authString}');
    try {
      Response response = await sendRequest(request,
          interceptors: request.getRequiredInterceptors());
      handler.resolve(response);
    } on DioError catch (error) {
      handler.next(error);
    }
  }
}
