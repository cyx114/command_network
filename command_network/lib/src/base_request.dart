import 'dart:core';

import 'package:meta/meta.dart';
import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import 'package:command_network/src/network_agent.dart';
import 'package:command_network/src/network_config.dart';
import 'package:command_network/src/interceptor/authentication_interceptor.dart';
import 'package:command_network/src/interceptor/json_validate_interceptor.dart';

enum CmdErrorType {
  requestError,
  jsonValidateError,
}

class CmdError {
  CmdError(this.errorType, {this.error});

  final CmdErrorType errorType;
  dynamic error;

  @override
  String toString() {
    String msg = 'CmdError [$errorType]:\n';
    msg += '\n';
    switch (errorType) {
      case CmdErrorType.requestError:
        {
          msg += error?.toString() ?? '';
        }
        break;
      case CmdErrorType.jsonValidateError:
        {
          msg += error!.response.toString();
        }
    }
    return msg;
  }
}

enum HttpRequestMethod {
  get,
  put,
  post,
}

extension HttpRequestMethodValue on HttpRequestMethod {
  String get value {
    String value = '';
    switch (this) {
      case HttpRequestMethod.get:
        value = 'GET';
        break;
      case HttpRequestMethod.put:
        value = 'PUT';
        break;
      case HttpRequestMethod.post:
        value = 'POST';
        break;
    }
    return value;
  }
}

enum AuthType { none, basic, digest, basicOrDigest, jwt }

class AuthInfo {
  AuthInfo({this.username = '', this.password = '', this.authString = ''});

  AuthInfo copyWith({String? username, String? password, String? authString}) {
    return AuthInfo(
        username: username ?? this.username,
        password: password ?? this.password,
        authString: authString ?? this.authString);
  }

  void mergeWith({String? username, String? password, String? authString}) {
    this.username = username ?? this.username;
    this.password = password ?? this.password;
    this.authString = authString ?? this.authString;
  }

  AuthInfo.none();

  String username = '';
  String password = '';
  String authString = '';
}

class Result {
  Result(this.isSuccess, {this.data, this.error});

  bool isSuccess = false;
  dynamic data;
  CmdError? error;

  @override
  String toString() {
    String msg = '\nResult: isSuccess: $isSuccess\n';
    msg += '\n';
    if (data != null) {
      msg += data?.toString() ?? '';
    }
    if (error != null) {
      msg += error?.toString() ?? '';
    }
    return msg;
  }
}

abstract class BaseRequest {
  // request and response
  Response? response;
  CmdError? error;

  /// This property CAN NOT be used before request finished.
  late final Result result;

  bool get cancelled => cancelToken.isCancelled;
  CancelToken cancelToken = CancelToken();

  final AuthInfo _authInfo = AuthInfo.none();

  // request operation
  Future<Result> start() {
    return NetworkAgent().addRequest(this);
  }

  void stop() {
    NetworkAgent().cancelRequest(this);
  }

  HttpRequestMethod get requestMethod {
    return HttpRequestMethod.get;
  }

  /// connect timeout in milliseconds
  int get connectTimeout {
    return 20000;
  }

  /// send timeout in milliseconds
  int get sendTimeout {
    return 20000;
  }

  /// receive timeout in milliseconds
  int get receiveTimeout {
    return 20000;
  }

  Map<String, dynamic>? get requestHeader {
    return {};
  }

  Map<String, dynamic>? get requestArgument {
    return {};
  }

  AuthType get authType {
    return AuthType.none;
  }

  @mustCallSuper
  set authInfo(AuthInfo authInfo) {
    _authInfo.mergeWith(
        username: authInfo.username.isEmpty ? _authInfo.username : authInfo.username,
        password: authInfo.password.isEmpty ? _authInfo.password : authInfo.password,
        authString: authInfo.authString.isEmpty ? _authInfo.authString : authInfo.authString,);
  }

  /// subclass should call super and merge the data when inherit.
  @mustCallSuper
  AuthInfo get authInfo {
    return _authInfo;
  }

  bool jsonValidate(Response response) {
    return true;
  }

  String get baseUrl {
    return NetworkConfig().baseUrl;
  }

  String get requestUrl {
    return '';
  }

  List<Interceptor> getRequiredInterceptors() {
    List<Interceptor> interceptors = [];
    if (NetworkConfig().requestLogEnabled) {
      interceptors.add(PrettyDioLogger());
    }
    switch (authType) {
      case AuthType.basicOrDigest:
      case AuthType.basic:
      case AuthType.digest:
        interceptors.add(DigestAuthInterceptor(this));
        break;
      case AuthType.none:
      case AuthType.jwt:
        break;
    }
    interceptors.add(JsonValidateInterceptor(jsonValidate));
    return interceptors;
  }

}
