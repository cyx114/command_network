import 'dart:core';


class NetworkConfig {

  static final NetworkConfig _singleton = NetworkConfig._internal();

  factory NetworkConfig() {
    return _singleton;
  }

  NetworkConfig._internal();

  /// Request base Url, such as 'http:www.baidu.com'. Default is empty string.
  String baseUrl = '';

}