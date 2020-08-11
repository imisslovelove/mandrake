import 'package:google_sign_in/google_sign_in.dart';

import '../config.dart';

class GoogleAuthManager {
  static String get _clientId => config['googleClientId'];

  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'https://www.googleapis.com/auth/drive.readonly',
    ],
    clientId: _clientId,
  );

  static Future<GoogleSignInAccount> signIn() async {
    try {
      return _googleSignIn.signIn();
    } catch (error) {
      print(error);
      return null;
    }
  }

  static Future<GoogleSignInAccount> signInSilently() async => _googleSignIn.signInSilently();

  static Future<void> signOut() async {
    try {
      return _googleSignIn.disconnect();
    } catch (error) {
      print(error);
    }
  }
}
