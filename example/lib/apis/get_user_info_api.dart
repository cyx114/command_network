import 'package:command_network/command_network.dart';


class GetUserInfoApi extends BaseRequest {

  @override
  String get requestUrl {
    return 'api/user/account/get';
  }

  @override
  AuthType get authType => AuthType.jwt;

  @override
  AuthInfo get authInfo {
    AuthInfo authInfo = super.authInfo;
    return authInfo.copyWith(
        authString: 'jwtToken');
  }

}