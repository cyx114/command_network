import 'dart:convert';

import 'package:crypto/crypto.dart';

import 'package:command_network/command_network.dart';


class LoginApi extends BaseRequest {
  LoginApi(this.username, this.password);

  String username;
  String password;

  @override
  HttpRequestMethod get requestMethod => HttpRequestMethod.post;

  @override
  Map<String, dynamic>? get requestArgument {
    var md5Password = md5.convert(utf8.encode(password));
    Map<String, dynamic> bodyMap = {};
    bodyMap['username'] = username;
    bodyMap['password'] = md5Password;
    return bodyMap;
  }

  @override
  String get requestUrl {
    return 'api/login';
  }

}