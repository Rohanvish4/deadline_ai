import 'dart:convert';

import 'package:amazon_cognito_identity_dart_2/cognito.dart';

class AuthRemoteDataSource {
  final CognitoUserPool userPool;

  AuthRemoteDataSource({
    required String userPoolId,
    required String clientId,
  }) : userPool = CognitoUserPool(userPoolId, clientId);

  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    await userPool.signUp(
      email.trim(),
      password,
      userAttributes: [
        AttributeArg(name: 'email', value: email.trim()),
        AttributeArg(name: 'name', value: fullName.trim()),
      ],
    );
  }

  Future<void> confirmSignUp({
    required String email,
    required String code,
  }) async {
    final user = CognitoUser(email.trim(), userPool);
    await user.confirmRegistration(code.trim());
  }

  Future<void> resendConfirmationCode({
    required String email,
  }) async {
    final user = CognitoUser(email.trim(), userPool);
    await user.resendConfirmationCode();
  }

  Future<Map<String, String>> signIn({
    required String email,
    required String password,
  }) async {
    final user = CognitoUser(email.trim(), userPool);
    final authDetails = AuthenticationDetails(
      username: email.trim(),
      password: password,
    );

    final session = await user.authenticateUser(authDetails);
    final cognitoIdToken = session?.getIdToken();
    final idToken = cognitoIdToken?.getJwtToken();

    if (idToken == null || idToken.isEmpty) {
      throw Exception('Could not retrieve Cognito ID token');
    }

    final payload = _decodeJwtPayload(idToken);
    final userId = payload['sub']?.toString() ?? '';
    final displayName = payload['name']?.toString().trim().isNotEmpty == true
        ? payload['name']!.toString()
        : (payload['email']?.toString() ?? email.trim());

    return {
      'id': userId,
      'displayName': displayName,
      'token': idToken,
    };
  }

  Map<String, dynamic> _decodeJwtPayload(String token) {
    final parts = token.split('.');
    if (parts.length != 3) return {};

    final normalized = base64Url.normalize(parts[1]);
    final payload = utf8.decode(base64Url.decode(normalized));
    return jsonDecode(payload) as Map<String, dynamic>;
  }
}
