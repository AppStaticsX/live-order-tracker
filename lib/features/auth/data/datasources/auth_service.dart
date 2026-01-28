import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../../core/constants/app_constants.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  // Sign in with Google and verify with Backend
  Future<Map<String, dynamic>> signInWithGoogle(String role) async {
    try {
      // 1. Trigger Google Sign In Flow
      final GoogleSignInAccount googleUser = await _googleSignIn.authenticate();
      // 2. Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          googleUser.authentication;

      // 3. Create a new credential
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.idToken,
        idToken: googleAuth.idToken,
      );

      // 4. Sign in to Firebase with the credential
      final UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );
      final User? user = userCredential.user;

      if (user == null) {
        throw Exception('Firebase Sign In failed');
      }

      // 5. Get the ID Token to send to backend
      final String? idToken = await user.getIdToken();

      if (idToken == null) {
        throw Exception('Failed to retrieve ID Token');
      }

      // 6. Verify with Backend
      final Uri url = Uri.parse('${AppConstants.socketUrl}/api/auth/google');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'idToken': idToken, 'role': role}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Backend verification failed: ${response.body}');
      }
    } catch (e) {
      print("Login Error: $e");
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}
