import 'package:flutter/material.dart';
import 'package:command_network/command_network.dart';

import 'package:command_network_example/apis/login_api.dart';
import 'package:command_network_example/apis/get_user_info_api.dart';
import 'package:command_network_example/apis/get_device_version_api.dart';

void main() {
  NetworkConfig().baseUrl = 'https://sample.com';
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'HTTP Request Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  void _requestWithAuthTypeNone() async {
    var loginApi = LoginApi('username', 'password');
    Result result = await loginApi.start();
    if (result.isSuccess) {
      print('[Result]success: ${result.data}');
    } else {
      print('[Result]failed: ${result.error}');
    }
  }

  void _requestWithAuthTypeJwt() async {
    var api = GetUserInfoApi();
    Result result = await api.start();
    if (result.isSuccess) {
      print('[Result]success: ${result.data}');
    } else {
      print('[Result]failed: ${result.error}');
    }
  }

  void _requestWithAuthTypeDigestOrBasic() async {
    var api = GetDeviceVersionApi('192.168.10.10',
        username: 'username', password: 'password');
    Result result = await api.start();
    if (result.isSuccess) {
      print('[Result]success: ${result.data}');
    } else {
      print('[Result]failed: ${result.error}');
    }
  }

  void _batchRequest() async {
    List<BaseRequest> requestList = [
      LoginApi('username', 'password'),
      GetUserInfoApi(),
      GetDeviceVersionApi('192.168.10.10',
          username: 'username', password: 'password')
    ];
    BatchRequest batchRequest = BatchRequest(requestList);
    Result batchResult = await batchRequest.start();
    if (batchResult.isSuccess) {
      for (BaseRequest request in requestList) {
        print('[Result]success: ${request.result.data}');
      }
    } else {
      for (BaseRequest request in requestList) {
        if (!request.result.isSuccess) {
          print('[Result]failed: ${request.result.error}');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                  onPressed: _requestWithAuthTypeNone,
                  child: const Text('AuthTypeNone')),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                  onPressed: _requestWithAuthTypeJwt,
                  child: const Text('AuthTypeJwt')),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                  onPressed: _requestWithAuthTypeDigestOrBasic,
                  child: const Text('AuthTypeDigestOrBasic')),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                  onPressed: _batchRequest,
                  child: const Text('BatchRequest')),
            ),
          ],
        ),
      ),
    );
  }
}
