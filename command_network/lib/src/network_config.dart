import 'dart:core';

import 'package:command_network/command_network.dart';
import 'package:flutter/foundation.dart';


class NetworkConfig {

  static final NetworkConfig _singleton = NetworkConfig._internal();

  factory NetworkConfig() {
    return _singleton;
  }

  NetworkConfig._internal();

  /// Request base Url, such as 'http:www.baidu.com'. Default is empty string.
  String baseUrl = '';
  AuthInfo authInfo = AuthInfo.none();
  bool requestLogEnabled = kDebugMode;

}