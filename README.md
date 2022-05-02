# command_network    [![Pub Version](https://img.shields.io/pub/v/command_network)](https://pub.dev/packages/command_network)

## What
command_network is a high level request util based on [dio](https://pub.dev/packages/dio), inspired by [YTKNetowrk](https://github.com/yuantiku/YTKNetwork).

## Features
- Plugin mechanism, handle request start and finish.
- Support HTTP authentication(Basic/Digest)

## Getting started
Add dependency
```dart
dependencies:
  command_network: ^0.0.1
```

A simple example:
```dart
var api = GetUserInfoApi();
Result result = await api.start();
if (result.isSuccess) {
  print('[Result]sucess: ${result.data}');
} else {
  print('[Result]failed: ${result.error}');
}
```

## Usage
### command_network's basic composition
command_netwrok mainly contains the following classes:
- NetworkConfig: it's used for setting global network host address.
- BaseRequest: it's the parent of all the detailed network request classes. All netwrok request classes should inherit it. Every subclass of BaseRequest represents a specific network request.

### NetworkConfig class
Network class has 1 main usages for now:
1. Set global network host address.

Setting global network host address using NetworkConfig is according to the `Do Not Repeat Yourself` principle, we should write the host address only once.

We should set NetworkConfig's property at the begining of app launching, the sample is below:

```dart
void main() {
  NetworkConfig().baseUrl = 'https://sample.com';
  runApp(const MyApp());
}
```

After setting, all network requests will use NetworkConfig's `baseUrl` property as their host address by default. You can overwrite the `baseUrl` method in request implementation to change it for specific request, too.

### BaseRequest class
The design idea of BaseRequest is that every specific network request should be a object. So after using command_network, all your request classes should inherit BaseRequest. Through overwriting the methods of super class, you can build your own specific and distinguished request. The key idea behind this is somewhat like the Command Pattern.

For example, if we want to send a POST request to `https://sample.com/api/login`, with username and password as arguments, then the class should be as following:
```dart
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
```
In above example:
- Through overwriting `requestUrl` method, we've indicated the detail url. Because host address has been set in `NetworkConfig`, we should not write the host address in `requestUrl` method.
- Through overwriting `requestMethod` method, we've indicated the use of the `POST` method.
- Through overwriting `requestArgument` method, we've provided the `POST` data. 

### Call LoginApi
How can we use the `LoginApi`? We can call it in the login page. After initializing the instance, we can call its `start()` method to send the request.
Then we can get network response by a `Result` object.
```dart

ElevatedButton(
  onPressed: () async {
    var loginApi = LoginApi('username', 'password');
    Result result = await loginApi.start();
    if (result.isSuccess) {
      print('[Result]sucess: ${result.data}');
    } else {
      print('[Result]failed: ${result.error}');
    }
  }
  child: const Text("Login"),
)
```
Since I am not used to use `try-catch`, so all exceptions will be handled inside `start()` method. You just need to check the `isSucess` property of `Result` class to verify if the request is sucessful or not. If the request failed, use `error` property of the `Result` class to figure out the reason.

## Acknowledgements
- [dio](https://pub.dev/packages/dio)
Thanks for their great work.

## License
command_network is available under the BSD 3-Clause.
