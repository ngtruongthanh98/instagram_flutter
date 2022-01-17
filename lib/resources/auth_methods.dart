import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram_flutter/models/user.dart' as model;
import 'package:instagram_flutter/resources/storage_methods.dart';

class AuthMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Sign up user
  Future<String> signUpUser({
    required String email,
    required String password,
    required String username,
    required String bio,
    required Uint8List file,
  }) async {
    String res = "Some errors occured";
    try {
      if (email.isNotEmpty ||
          password.isNotEmpty ||
          username.isNotEmpty ||
          bio.isNotEmpty ||
          file != null) {
        // Register user
        UserCredential cred = await _auth.createUserWithEmailAndPassword(
            email: email, password: password);

        print(cred.user!.uid);

        String photoUrl = await StorageMethods()
            .uploadImageToStorage('profilePics', file, false);

        model.User user = model.User(
          username: username,
          uid: cred.user!.uid,
          email: email,
          bio: bio,
          photoUrl: photoUrl,
          followers: [],
          following: [],
        );

        // Add user details to database
        await _firestore
            .collection('users')
            .doc(cred.user!.uid)
            .set(user.toJson());

        res = "Success";
      }
    } on FirebaseAuthException catch (err) {
      if (err.code == 'invalid-email') {
        res = 'The email is badly formatted';
      } else if (err.code == 'email-already-in-use') {
        res = 'The email is already in use';
      } else if (err.code == 'weak-password') {
        res = 'Password should be at least 6 characters';
      } else {
        res = err.code;
      }
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  // Loging in user
  Future<String> loginUser({
    required String email,
    required String password,
  }) async {
    String res = "Some errors occured";
    try {
      if (email.isNotEmpty || password.isNotEmpty) {
        // Login user
        await _auth.signInWithEmailAndPassword(
            email: email, password: password);

        res = "Success";
      } else {
        res = "Please enter email and password";
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        res = 'User with this email does not exist';
      } else if (e.code == 'wrong-password') {
        res = 'The password is invalid';
      } else {
        res = e.code;
      }
    } catch (err) {
      res = err.toString();
    }
    return res;
  }
}
