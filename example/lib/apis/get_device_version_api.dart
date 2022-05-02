import 'package:command_network/command_network.dart';


class GetDeviceVersionApi extends BaseRequest {
  GetDeviceVersionApi(this.ipAddress,
      {this.username, this.password, this.authString})
      : assert((username != null && username.isNotEmpty) ||
            (authString != null && authString.isNotEmpty)),
        super();

  String ipAddress;
  String? username;
  String? password;
  String? authString;

  @override
  String get baseUrl {
    return 'http://' + ipAddress + '/';
  }

  @override
  String get requestUrl => 'api/V1.0/deviceVersion';

  @override
  AuthType get authType {
    return AuthType.basicOrDigest;
  }

  @override
  AuthInfo get authInfo {
    AuthInfo authInfo = super.authInfo;
    return authInfo.copyWith(
        username: username,
        password: password,
        authString: authString);
  }
}
