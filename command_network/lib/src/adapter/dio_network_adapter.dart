import 'dart:io';

import 'package:dio/adapter.dart';

import 'package:command_network/src/header_const.dart';
import 'package:command_network/command_network.dart';
import 'package:command_network/src/helper/authentication_helper.dart';

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
// print('get: options: ${buildRequestOption(request).headers}');
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
  // print('[Handle Header] ${request.authInfo.authString}');
  Map<String, dynamic> additionalHeader = {};
  switch (request.authType) {
    case AuthType.basic:
      {
        String authString = request.authInfo.authString.isEmpty
            ? generateBasicAuthString(
                request.authInfo.username, request.authInfo.password)
            : request.authInfo.authString;
        additionalHeader = {
          HeaderConst.authorization: authString,
        };
      }
      break;
    case AuthType.digest:
    case AuthType.jwt:
    case AuthType.basicOrDigest:
      {
        if (request.authInfo.authString.isNotEmpty) {
          additionalHeader = {
            HeaderConst.authorization: request.authInfo.authString,
          };
        }
      }
      break;
    case AuthType.none:
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
