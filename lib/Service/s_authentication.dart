import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:isar_community/isar.dart';
import 'package:tasknote/Other/constants.dart';
import 'package:tasknote/User/Model/m_user.dart';
import 'package:tasknote/Other_Views/v_splash.dart';

class AuthenticationService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final GoogleSignIn googleSignIn = GoogleSignIn.instance;

  final BuildContext context;

  AuthenticationService({required this.context});

  // Password encryption
  String encryptSHA256(String input) {
    var bytes = utf8.encode(input); // Convert string to bytes
    var digest = sha256.convert(bytes); // Apply SHA-256 hash
    return digest.toString(); // Convert hash to string
  }

  // Helper method to save or update the local user inside Isar cache
  Future<void> _saveUserLocally(MUser user) async {
    final isar = userController.isar;
    await isar.writeTxn(() async {
      // Check if user already exists locally to preserve the Isar auto-increment ID
      final existingUser = await isar.mUsers
          .filter()
          .uidEqualTo(user.uid)
          .findFirst();

      if (existingUser != null) {
        user.id = existingUser.id;
      }
      await isar.mUsers.put(user);
    });
  }

  // Login and Signup both in one function
  Future<void> signInWithEmailPassword(
    BuildContext context,
    bool isLogin,
    String email,
    String password,
    String fullName,
  ) async {
    try {
      // LOGIN
      if (isLogin) {
        UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: email,
          password: encryptSHA256(password),
        );

        String? uid = userCredential.user?.uid;
        if (uid != null) {
          DocumentSnapshot doc = await _firestore
              .collection("Users")
              .doc(uid)
              .get();

          if (doc.exists && doc.data() != null) {
            MUser user = MUser.fromMap(doc.data() as Map<String, dynamic>);
            await _saveUserLocally(user);
          }
        }
        logger.d("Login successful $email");
      }
      // SIGN-UP
      else {
        UserCredential userCredential = await _auth
            .createUserWithEmailAndPassword(
              email: email,
              password: encryptSHA256(password),
            );

        String? uid = userCredential.user?.uid;
        logger.d("Signup successful $email with UID: $uid");

        if (uid != null) {
          String joinedDate = DateFormat(
            "dd MMM yyyy hh:mm a",
          ).format(DateTime.now());

          // Save to Cloud Firestore (encryptedPassword stays empty/null on Firebase)
          await _firestore.collection("Users").doc(uid).set({
            "uid": uid,
            "email": email,
            "fullName": fullName,
            "login_method": "Email and password",
            "joined": joinedDate,
            "encryptedPassword": null,
          });

          // Save identical record to local Isar
          MUser newUser = MUser(
            uid: uid,
            email: email,
            fullName: fullName,
            loginMethod: "Email and password",
            joined: joinedDate,
          );

          await _saveUserLocally(newUser);
          logger.d("User added successfully to Firestore and Isar!");
        }
      }

      String status = isLogin ? "login" : "signup";
      if (!context.mounted) return;
      Navigator.pop(context, status);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_handleFirebaseAuthError(e));
    }
  }

  // Google Sign In
  Future<void> signInWithGoogle(bool isLogin) async {
    try {
      // Initialize once
      await googleSignIn.initialize();

      // Google account picker
      final GoogleSignInAccount googleUser = await googleSignIn.authenticate();

      // Required scopes
      const scopes = ['email', 'profile'];

      // Authorization (NEW API)
      final authorization = await googleUser.authorizationClient
          .authorizeScopes(scopes);

      // Firebase credential
      final credential = GoogleAuthProvider.credential(
        idToken: googleUser.authentication.idToken,
        accessToken: authorization.accessToken,
      );

      // Firebase login
      final userCredential = await _auth.signInWithCredential(credential);

      final firebaseUser = userCredential.user;

      if (firebaseUser == null) {
        throw AuthException(
          "Failed to authenticate with Google. Please try again.",
        );
      }

      final uid = firebaseUser.uid;
      String joinedDate = DateFormat(
        "dd MMM yyyy hh:mm a",
      ).format(DateTime.now());

      MUser? localUser;

      // Create Firestore document only for new users
      if (userCredential.additionalUserInfo?.isNewUser ?? false) {
        await _firestore.collection("Users").doc(uid).set({
          "uid": uid,
          "email": firebaseUser.email,
          "fullName": firebaseUser.displayName,
          "login_method": "Google",
          "joined": joinedDate,
          "encryptedPassword": null,
        });

        localUser = MUser(
          uid: uid,
          email: firebaseUser.email ?? "",
          fullName: firebaseUser.displayName ?? "",
          loginMethod: "Google",
          joined: joinedDate,
        );

        logger.d("New Google user added to Firestore");
      } else {
        // Existing user: Fetch from Firestore to match local database identically
        DocumentSnapshot doc = await _firestore
            .collection("Users")
            .doc(uid)
            .get();

        if (doc.exists && doc.data() != null) {
          // Maps whatever data Firestore contains directly to Isar
          localUser = MUser.fromMap(doc.data() as Map<String, dynamic>);
        }
      }

      // Save/Update local Isar storage
      if (localUser != null) {
        await _saveUserLocally(localUser);
        logger.d("Google user saved locally to Isar.");
      }

      logger.d("Google Sign In Successful: ${firebaseUser.email}");

      String status = "login";
      if (!context.mounted) return;
      Navigator.pop(context, status);
    } on FirebaseAuthException catch (e) {
      logger.d("Firebase Auth Error: ${e.message}");
      throw AuthException(_handleFirebaseAuthError(e));
    } catch (e) {
      logger.d("Unexpected Google Sign-In Error: $e");
      if (e is AuthException) rethrow;

      final errorString = e.toString().toLowerCase();
      if (errorString.contains('sign_in_canceled') ||
          errorString.contains('cancelled') ||
          errorString.contains('canceled')) {
        throw AuthException("Sign-in cancelled.");
      }
      throw AuthException("Google Sign-In failed. Please try again.");
    }
  }

  Future<void> logOutuser() async {
    await _auth.signOut();

    await googleSignIn.signOut();

    // Clear local user data out of Isar on logout instead of utilizing SharedPreferences
    final isar = userController.isar;
    await isar.writeTxn(() async {
      await isar.mUsers.clear();
    });
  }
}

class AuthException implements Exception {
  final String message;
  AuthException(this.message);

  @override
  String toString() => message; // No "Exception: " prefix!
}

String _handleFirebaseAuthError(FirebaseAuthException e) {
  switch (e.code) {
    // Network / Cloud issues
    case 'network-request-failed':
      return "No internet connection. Please check your network and try again.";

    // Login issues
    case 'user-not-found':
    case 'wrong-password':
    case 'invalid-credential':
      return "Invalid email or password. Please try again.";
    case 'user-disabled':
      return "This account has been disabled. Please contact support.";

    // Registration issues
    case 'email-already-in-use':
      return "This email address is already registered. Try logging in.";
    case 'invalid-email':
      return "Please enter a valid email address.";
    case 'weak-password':
      return "Your password is too weak. Please use a stronger password.";

    // Google Sign in / Credential issues
    case 'account-exists-with-different-credential':
      return "An account already exists with this email but using a different sign-in provider.";
    case 'operation-not-allowed':
      return "This sign-in method is currently disabled.";

    // Default fallback
    default:
      return e.message ?? "Authentication failed. Please try again.";
  }
}
