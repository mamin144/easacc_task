import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../state/auth_state.dart';

final authControllerProvider =
    StateNotifierProvider<AuthController, AuthState>((ref) {
  return AuthController();
});

class AuthController extends StateNotifier<AuthState> {
  AuthController() : super(AuthState.initial()) {
    _checkAuthState();
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    // Web Client ID from Google Cloud Console
    serverClientId:
        '911981193074-qoi3ncu8tlkgevqctsha3ppc9pl28sjc.apps.googleusercontent.com',
  );

  Future<void> _checkAuthState() async {
    state = state.copyWith(isLoading: true);

    try {
      // Check if user is already logged in
      final user = _auth.currentUser;
      if (user != null) {
        state = AuthState.authenticated(user);
      } else {
        // Check shared preferences for persisted auth
        final prefs = await SharedPreferences.getInstance();
        final userId = prefs.getString('user_id');
        if (userId != null) {
          // Try to reload user
          await _auth.currentUser?.reload();
          final currentUser = _auth.currentUser;
          if (currentUser != null && currentUser.uid == userId) {
            state = AuthState.authenticated(currentUser);
            return;
          }
        }
        state = AuthState.unauthenticated();
      }
    } catch (e) {
      state = AuthState.unauthenticated();
    }
  }

  Future<void> signInWithFacebook() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      // Trigger Facebook login with only public_profile permission
      // This avoids the "Invalid Scopes: email" error
      // Email will be available from Firebase Auth after successful login
      final loginResult = await FacebookAuth.instance.login(
        permissions: ['public_profile'],
      );

      if (loginResult.status != LoginStatus.success) {
        state = state.copyWith(
          isLoading: false,
          error:
              'Facebook login failed: ${loginResult.message ?? 'Unknown error'}',
        );
        return;
      }

      // Get Facebook access token
      final accessToken = loginResult.accessToken;
      if (accessToken == null) {
        state = state.copyWith(
          isLoading: false,
          error: 'Failed to get Facebook access token',
        );
        return;
      }

      // Check if token string is available
      final tokenString = accessToken.token;
      if (tokenString.isEmpty) {
        state = state.copyWith(
          isLoading: false,
          error: 'Facebook access token is empty',
        );
        return;
      }

      // Create Firebase credential from Facebook token
      final credential = FacebookAuthProvider.credential(tokenString);

      // Sign in to Firebase with Facebook credential
      final userCredential = await _auth.signInWithCredential(credential);

      // Check if user exists
      final user = userCredential.user;
      if (user == null) {
        state = state.copyWith(
          isLoading: false,
          error: 'Failed to get user information',
        );
        return;
      }

      // Save user ID to shared preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_id', user.uid);

      state = AuthState.authenticated(user);
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Authentication failed: ${e.message ?? 'Unknown error'}',
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'An error occurred: ${e.toString()}',
      );
    }
  }

  Future<void> signInWithGoogle() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      // Trigger Google Sign-In
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // User cancelled the sign-in
        state = state.copyWith(isLoading: false);
        return;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with Google credential
      final userCredential = await _auth.signInWithCredential(credential);

      // Check if user exists
      final user = userCredential.user;
      if (user == null) {
        state = state.copyWith(
          isLoading: false,
          error: 'Failed to get user information',
        );
        return;
      }

      // Save user ID to shared preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_id', user.uid);

      state = AuthState.authenticated(user);
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Authentication failed: ${e.message ?? 'Unknown error'}',
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'An error occurred: ${e.toString()}',
      );
    }
  }

  Future<void> signOut() async {
    state = state.copyWith(isLoading: true);

    try {
      // Sign out from Firebase
      await _auth.signOut();

      // Sign out from Facebook
      await FacebookAuth.instance.logOut();

      // Sign out from Google
      await _googleSignIn.signOut();

      // Clear shared preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_id');

      state = AuthState.unauthenticated();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to sign out: ${e.toString()}',
      );
    }
  }
}
