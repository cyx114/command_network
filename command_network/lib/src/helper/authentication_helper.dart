import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

import 'package:command_network/command_network.dart';
import 'package:command_network/src/header_const.dart';

String generateDigestAuthString(BaseRequest request, String wwwAuthString, DioError err) {
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
  String ha3 = _computeHA3(
      realm,
      algorithm,
      request.authInfo.username,
      request.authInfo.password,
      nonce,
      cnonce,
      uri,
      nc,
      qop,
      request.requestMethod.value);
  StringBuffer sb = StringBuffer();
  sb.write(HeaderConst.digest + '');
  sb..write('username')..write('="')..write(request.authInfo.username)..write(
      '",');
  sb..write('qop')..write('="')..write(qop)..write('",');
  sb..write('algorithm')..write('="')..write(algorithm)..write('",');
  sb..write('realm')..write('="')..write(realm)..write('",');
  sb..write('nonce')..write('="')..write(nonce)..write('",');
  sb..write('nc')..write("=")..write(nc)..write(", ");
  sb..write('uri')..write('="')..write(uri)..write('",');
  sb..write('cnonce')..write('="')..write(cnonce)..write('",');
  sb..write('response')..write('="')..write(ha3)..write('"');
  return sb.toString();
}

/// [password] should be resolved by MD5 algorithm.
String generateBasicAuthString(String username, String password) {
  final token = base64.encode(latin1.encode('$username:$password'));
  final authStr = 'Basic ' + token.trim();
  return authStr;
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

String md5Hash(String data) {
  var content = utf8.encode(data);
  var digest = md5.convert(content).toString();
  return digest;
}

String sha256Hash(String data) {
  var content = utf8.encode(data);
  var digest = sha256.convert(content).toString();
  return digest;
}

String _computeHA3(String realm, String algorithm, String username,
    String password, String nonce, String cnonce, String uri, String nc,
    String qop, String requestMethod) {
  if (algorithm.isEmpty || algorithm == 'MD5') {
    String ha1 = md5Hash('$username:$realm:$password');
    String ha2 = md5Hash('$requestMethod:$uri');
    String ha3 = md5Hash('$ha1:$nonce:$nc:$cnonce:$qop:$ha2');
    return ha3;
  } else if (algorithm == 'MD5-sess') {
    final token1 = '$username:$realm:$password';
    final md51 = md5Hash(token1);
    final token2 = '$md51:$nonce:$cnonce';
    return md5Hash(token2);
  } else if (algorithm == 'SHA-256') {
    String ha1 = sha256Hash('$username:$realm:$password');
    String ha2 = sha256Hash('$requestMethod:$uri');
    String ha3 = sha256Hash('$ha1:$nonce:$nc:$cnonce:$qop:$ha2');
    return ha3;
  } else {
    throw ArgumentError.value(
        algorithm, 'algorithm', 'Unsupported algorithm');
  }
}
