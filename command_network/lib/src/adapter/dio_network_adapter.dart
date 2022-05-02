import 'package:dio/dio.dart';

import 'package:command_network/src/base_request.dart';
import 'package:command_network/src/header_const.dart';

export 'package:dio/dio.dart';


Future<Response> sendRequest(BaseRequest request,
    {List<Interceptor>? interceptors}) async {
  final Dio dio = Dio();
  dio.options.connectTimeout = request.connectTimeout;
  if (interceptors != null) {
    dio.interceptors.addAll(interceptors);
  }
  HttpRequestMethod requestMethod = request.requestMethod;
  Response response;
  switch (requestMethod) {
    case HttpRequestMethod.get:
      {
        response = await dio.get(buildRequestUrl(request),
            cancelToken: request.cancelToken,
            queryParameters: request.requestArgument,
            options: buildRequestOption(request));
      }
      break;
    case HttpRequestMethod.put:
      {
        response = await dio.put(buildRequestUrl(request),
            cancelToken: request.cancelToken,
            queryParameters: request.requestArgument,
            options: buildRequestOption(request));
      }
      break;
    case HttpRequestMethod.post:
      {
        response = await dio.post(buildRequestUrl(request),
            cancelToken: request.cancelToken,
            data: request.requestArgument,
            options: buildRequestOption(request));
      }
      break;
  }
  return response;
}

String buildRequestUrl(BaseRequest request) {
  String requestUrl = request.requestUrl;
  String baseUrl = request.baseUrl;
  if (baseUrl.endsWith('/') && requestUrl.startsWith('/')) {
    requestUrl = requestUrl.replaceFirst('/', '');
  }
  if (!baseUrl.endsWith('/') && !requestUrl.startsWith('/')) {
    requestUrl = '/' + requestUrl;
  }
  var uri = Uri.parse(request.baseUrl);
  uri = uri.resolve(request.requestUrl);
  return uri.toString();
}

void handleAuthorizationHeader(BaseRequest request, options) {
  if (request.authInfo.authString.isEmpty) {
    return;
  }
  Map<String, dynamic> additionalHeader = {};
  switch (request.authType) {
    case AuthType.basic:
    case AuthType.digest:
    case AuthType.jwt:
      additionalHeader = {
        HeaderConst.authorization: request.authInfo.authString,
      };
      break;
    default:
      break;
  }
  additionalHeader.addAll(options.headers ?? {});
  options.headers = additionalHeader;
}

Options buildRequestOption(BaseRequest request) {
  Options options = Options();
  options.sendTimeout = request.sendTimeout;
  options.receiveTimeout = request.receiveTimeout;
  options.headers = request.requestHeader;
  handleAuthorizationHeader(request, options);
  return options;
}
