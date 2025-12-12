import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // Configure Google Sign-In with server client ID from Firebase Console
  // You can find this in Firebase Console > Authentication > Sign-in method > Google > Web SDK configuration
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    // Optionally specify scopes
    scopes: ['email', 'profile'],
  );

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign in with email and password
  Future<UserCredential?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      print('Sign in successful for: ${credential.user?.email}');
      return credential;
    } on FirebaseAuthException catch (e) {
      print('FirebaseAuthException during sign in: ${e.code} - ${e.message}');
      throw _handleAuthException(e);
    } catch (e, stackTrace) {
      print('Error during sign in (checking if user is signed in): $e');
      
      // Handle type casting error that can occur with some Firebase Auth versions
      // Even if there's a decoding error, check if user is actually signed in
      if (e.toString().contains('is not a subtype') || 
          e.toString().contains('PigeonUserDetails')) {
        // Wait a moment for auth state to update
        await Future.delayed(const Duration(milliseconds: 500));
        
        // Check if user is actually signed in despite the error
        final currentUser = _auth.currentUser;
        if (currentUser != null && currentUser.email?.toLowerCase() == email.trim().toLowerCase()) {
          print('Sign in successful (handled type casting error): ${currentUser.email}');
          // User is signed in, return null and let auth state listener handle navigation
          return null;
        }
      }
      
      print('Stack trace: $stackTrace');
      throw 'An unexpected error occurred. Please try again.';
    }
  }

  // Sign up with email and password
  Future<UserCredential?> signUpWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      print('Account created successfully for: ${credential.user?.email}');
      return credential;
    } on FirebaseAuthException catch (e) {
      print('FirebaseAuthException during signup: ${e.code} - ${e.message}');
      throw _handleAuthException(e);
    } catch (e, stackTrace) {
      print('Error during signup (checking if account was created): $e');
      
      // Handle type casting error that can occur with some Firebase Auth versions
      // Even if there's a decoding error, check if user is actually created
      if (e.toString().contains('is not a subtype') || 
          e.toString().contains('PigeonUserDetails')) {
        // Wait a moment for auth state to update
        await Future.delayed(const Duration(milliseconds: 500));
        
        // Check if user is actually created despite the error
        final currentUser = _auth.currentUser;
        if (currentUser != null && currentUser.email == email.trim()) {
          print('Account created successfully (handled type casting error): ${currentUser.email}');
          // User is created, return null and let the caller handle it
          return null;
        }
      }
      
      print('Stack trace: $stackTrace');
      throw 'An unexpected error occurred: ${e.toString()}';
    }
  }

  // Sign in with Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // User canceled the sign-in
        return null;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      try {
        return await _auth.signInWithCredential(credential);
      } catch (e) {
        // Handle type casting error that can occur with some Firebase Auth versions
        // Even if there's a decoding error, check if user is actually signed in
        if (e.toString().contains('is not a subtype') || 
            e.toString().contains('PigeonUserDetails')) {
          // Wait a moment for auth state to update
          await Future.delayed(const Duration(milliseconds: 500));
          
          // Check if user is actually signed in despite the error
          final currentUser = _auth.currentUser;
          if (currentUser != null) {
            print('Google Sign-In successful (handled type casting error): ${currentUser.email}');
            // Return a mock credential since the actual one failed to decode
            // The user is authenticated, so this is fine
            return null; // Will be handled by auth state listener
          }
        }
        rethrow;
      }
    } on FirebaseAuthException catch (e) {
      print('FirebaseAuthException during Google sign-in: ${e.code} - ${e.message}');
      throw _handleAuthException(e);
    } catch (e, stackTrace) {
      print('Error during Google sign-in: $e');
      print('Stack trace: $stackTrace');
      
      // Check if user is actually signed in despite the error
      final currentUser = _auth.currentUser;
      if (currentUser != null) {
        print('Google Sign-In successful despite error: ${currentUser.email}');
        // User is authenticated, return null and let auth state listener handle it
        return null;
      }
      
      // Show the actual error message if available
      if (e.toString().contains('PlatformException') || e.toString().contains('sign_in_failed')) {
        throw 'Google Sign-In failed. Please make sure Google Sign-In is enabled in Firebase Console and your SHA-1 fingerprint is added.';
      }
      throw 'An unexpected error occurred during Google sign-in: ${e.toString()}';
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      // Sign out from both Firebase Auth and Google Sign-In
      // Use separate try-catch for each to ensure both are attempted
      try {
        await _auth.signOut();
      } catch (e) {
        print('Firebase signOut error: $e');
        // Continue even if Firebase signOut fails
      }
      
      try {
        await _googleSignIn.signOut();
      } catch (e) {
        print('Google Sign-In signOut error: $e');
        // Continue even if Google Sign-In signOut fails
      }
    } catch (e) {
      print('General signOut error: $e');
      // Don't throw - signOut is best effort
    }
  }

  // Handle Firebase Auth exceptions
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'email-already-in-use':
        return 'An account already exists for that email.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        // For security, don't reveal whether email exists or password is wrong
        return 'Wrong email or password. Try again.';
      case 'operation-not-allowed':
        return 'This operation is not allowed.';
      case 'too-many-requests':
        return 'Too many requests. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Please check your internet connection.';
      default:
        // Check if the error message indicates credential issues
        final errorMessage = e.message?.toLowerCase() ?? '';
        if (errorMessage.contains('credential') && 
            (errorMessage.contains('incorrect') || 
             errorMessage.contains('malformed') || 
             errorMessage.contains('expired'))) {
          return 'Wrong email or password. Try again.';
        }
        return e.message ?? 'An authentication error occurred.';
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'An unexpected error occurred. Please try again.';
    }
  }
}

