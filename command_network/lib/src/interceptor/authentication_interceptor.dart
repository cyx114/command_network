import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

import 'package:command_network/src/base_request.dart';
import 'package:command_network/src/adapter/dio_network_adapter.dart';
import 'package:command_network/src/header_const.dart';

class DigestAuthInterceptor extends QueuedInterceptor {
  DigestAuthInterceptor(this.request);

  BaseRequest request;

  @override
  void onError(DioError err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode != 401) {
      handler.next(err);
      return;
    }
    String wwwAuthString =
        err.response!.headers[Headers.wwwAuthenticateHeader]![0];
    if (wwwAuthString.isEmpty) {
      handler.next(err);
      return;
    }
    String authString = '';
    if (wwwAuthString.startsWith(HeaderConst.digest)) {
      authString = _generateDigestAuthString(wwwAuthString, err);
    } else if (wwwAuthString.startsWith(HeaderConst.basic)) {
      authString = _generateBasicAuthString();
    }
    if (authString.isEmpty) {
      handler.next(err);
    }
    request.authInfo.authString = authString;
    try {
      var response = await sendRequest(request);
      handler.resolve(response);
    } on DioError catch (error) {
      handler.next(error);
    }
  }

  // Generate a string containing 32 numbers and letters
  String _getCnonceString() {
    Random random = Random();
    String cnonce = '';
    for (int i = 0; i < 32; i++) {
      if (random.nextInt(2) == 0) {
        cnonce += String.fromCharCodes([65 + random.nextInt(26)]);
      } else {
        cnonce += random.nextInt(10).toString();
      }
    }
    return cnonce;
  }

  String _generateDigestAuthString(String wwwAuthString, DioError err) {
    String handleAuth =
        wwwAuthString.substring(7).replaceAll(' ', '').replaceAll('"', '');
    Map<String, String> authFields = {};
    List<String> itemList = handleAuth.split(',');
    for (String item in itemList) {
      List<String> keyValueList = item.split('=');
      authFields[keyValueList[0]] = keyValueList[1];
    }
    String qop = authFields['qop'] ?? '';
    String algorithm = authFields['algorithm'] ?? '';
    String realm = authFields['realm'] ?? '';
    String nonce = authFields['nonce'] ?? '';
    String nc = '00000002';
    String uri = err.response?.realUri.path ?? '';
    String cnonce = _getCnonceString();
    var bytes1 = utf8.encode(request.authInfo.username +
        ':' +
        realm +
        ':' +
        request.authInfo.password);
    String ha1 = md5.convert(bytes1).toString();
    var bytes2 = utf8.encode(request.requestMethod.value + ':' + uri);
    String ha2 = md5.convert(bytes2).toString();
    var bytes3 = utf8.encode(
        ha1 + ':' + nonce + ':' + nc + ':' + cnonce + ':' + qop + ':' + ha2);
    String ha3 = md5.convert(bytes3).toString();
    StringBuffer sb = StringBuffer();
    sb.write(HeaderConst.digest + '');
    sb
      ..write('username')
      ..write('="')
      ..write(request.authInfo.username)
      ..write('",');
    sb
      ..write('qop')
      ..write('="')
      ..write(qop)
      ..write('",');
    sb
      ..write('algorithm')
      ..write('="')
      ..write(algorithm)
      ..write('",');
    sb
      ..write('realm')
      ..write('="')
      ..write(realm)
      ..write('",');
    sb
      ..write('nonce')
      ..write('="')
      ..write(nonce)
      ..write('",');
    sb
      ..write('nc')
      ..write("=")
      ..write(nc)
      ..write(", ");
    sb
      ..write('uri')
      ..write('="')
      ..write(uri)
      ..write('",');
    sb
      ..write('cnonce')
      ..write('="')
      ..write(cnonce)
      ..write('",');
    sb
      ..write('response')
      ..write('="')
      ..write(ha3)
      ..write('"');
    return sb.toString();
  }

  String _generateBasicAuthString() {
    String authString =
        request.authInfo.username + ':' + request.authInfo.password;
    return base64Decode(authString).toString();
  }
}
