import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../../core/errors/exceptions.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login(String email, String password);
  Future<UserModel> register(String name, String email, String password);
  Future<void> resetPassword(String email);
  Future<void> sendEmailVerification();
  Future<bool> checkVerificationStatus();
  Future<void> logout();
  Future<UserModel?> getCurrentUser();
  Future<UserModel> googleSignIn();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firestore;
  final GoogleSignIn googleSignInInstance;

  AuthRemoteDataSourceImpl({
    required this.firebaseAuth,
    required this.firestore,
    required this.googleSignInInstance,
  });

  @override
  Future<bool> checkVerificationStatus() async {
    final user = firebaseAuth.currentUser;
    if (user != null) {
      await user.reload();
      return user.emailVerified;
    }
    throw AuthException('No user logged in');
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final user = firebaseAuth.currentUser;
    if (user != null) {
      final doc = await firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
    }
    return null;
  }

  @override
  Future<UserModel> login(String email, String password) async {
    try {
      final userCredential = await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = userCredential.user;
      if (user != null) {
        final doc = await firestore.collection('users').doc(user.uid).get();
        if (doc.exists) {
          return UserModel.fromFirestore(doc);
        } else {
          // Fallback if user document does not exist for some reason
          return UserModel(
            id: user.uid,
            email: user.email ?? '',
            name: user.displayName ?? '',
            isEmailVerified: user.emailVerified,
          );
        }
      }
      throw AuthException('Failed to login');
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.message ?? 'An error occurred during login');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> logout() async {
    await googleSignInInstance.signOut();
    await firebaseAuth.signOut();
  }

  @override
  Future<UserModel> register(String name, String email, String password) async {
    try {
      final userCredential = await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = userCredential.user;
      if (user != null) {
        await user.updateDisplayName(name);
        await user.sendEmailVerification();
        
        final userModel = UserModel(
          id: user.uid,
          email: email,
          name: name,
          isEmailVerified: user.emailVerified,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        
        await firestore.collection('users').doc(user.uid).set(userModel.toJson());
        return userModel;
      }
      throw AuthException('Failed to register');
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.message ?? 'An error occurred during registration');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> resetPassword(String email) async {
    try {
      await firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.message ?? 'Failed to send password reset email');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> sendEmailVerification() async {
    try {
      final user = firebaseAuth.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
      } else {
        throw AuthException('No unverified user logged in');
      }
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.message ?? 'Failed to send email verification');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<UserModel> googleSignIn() async {
    try {
      // Note: In this version of the package, we use authenticate()
      // and authorizationClient to get the token.
      final account = await googleSignInInstance.authenticate();

      final headers = await account.authorizationClient.authorizationHeaders([
        'email',
        'profile',
        'openid',
      ]);
      
      final accessToken = headers?['Authorization']?.split(' ').last;

      if (accessToken == null) {
        throw AuthException('Failed to obtain access token from Google');
      }

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: accessToken,
      );

      final UserCredential userCredential = await firebaseAuth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        final doc = await firestore.collection('users').doc(user.uid).get();
        if (doc.exists) {
          return UserModel.fromFirestore(doc);
        } else {
          // New user from Google
          final userModel = UserModel(
            id: user.uid,
            email: user.email ?? '',
            name: user.displayName ?? '',
            isEmailVerified: true, // Google emails are implicitly verified
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
          await firestore.collection('users').doc(user.uid).set(userModel.toJson());
          return userModel;
        }
      }
      throw AuthException('Failed to sign in with Google');
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.message ?? 'An error occurred during Google Sign-In');
    } catch (e) {
      if (e is AuthException) rethrow;
      throw ServerException(e.toString());
    }
  }
}
