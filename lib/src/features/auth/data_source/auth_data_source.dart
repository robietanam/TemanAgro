import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../src/core/providers/firebase_providers.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:path/path.dart';

class AuthDataSource {
  final FirebaseAuth _firebaseAuth;
  final FirebaseStorage _firebaseStorage;
  final FirebaseFirestore _firebaseFirestore;
  final Ref _ref; // use for reading other providers

  AuthDataSource(this._firebaseAuth, this._firebaseFirestore,
      this._firebaseStorage, this._ref);

  Future<String> saveFile(
      String userId, String filePath, String dateIMG) async {
    Reference? profileImagesRef;
    Reference storageRef = _firebaseStorage.ref();

    final fileImage = File(filePath);
    final fileName = basenameWithoutExtension(fileImage.path);
    profileImagesRef = storageRef.child("profile_photo/${userId}.jpg");
    await profileImagesRef.putFile(fileImage);
    final downloadURL = await profileImagesRef.getDownloadURL();
    print(downloadURL);

    return downloadURL;
  }

  Future<String?> checkReferral({required String referral}) async {
    Iterable isKode;
    print("LAH KODE REFERAL");
    final FirebaseFirestore db = _firebaseFirestore;
    final kodeRef =
        db.collection('kodeRef').where("token", isEqualTo: int.parse(referral));
    isKode =
        await kodeRef.get().then((value) => value.docs.map((e) => e.data()));
    print("kode ref : ${isKode}");
    if (isKode.isEmpty) {
      return null;
    } else {
      print(isKode);
      print(isKode.first['idAdmin']);
      return isKode.first['idAdmin'];
    }
  }

  Future<Either<String, String>> saveUser(
      {required User user,
      String? filePath,
      String? nama,
      String? phone,
      String? photoURL,
      String? idAdmin,
      String? namaUsaha,
      String? role}) async {
    final String dateIMG = DateFormat('yyyy-MM-dd-kk').format(DateTime.now());
    final FirebaseFirestore db = _firebaseFirestore;
    DocumentReference ref = db.collection('users').doc(user.uid);

    Map<String, dynamic>? oldUserData;

    try {
      DocumentSnapshot doc = await ref.get();

      String? downloadURL;

      if (filePath != null) {
        print("GET Image");
        photoURL = await saveFile(user.uid, filePath, dateIMG);
      } else {
        ErrorDescription("Gagal Save file");
      }

      print("ADADSADDSD");
      print(photoURL);
      Map<String, dynamic> toSave = {
        'uid': user.uid,
        'email': user.email,
        'photoURL': photoURL,
        'displayName': nama,
        'Nama': nama,
        'phone': phone,
        'namaUsaha': namaUsaha,
        'lastUpdate': dateIMG,
        'role': role,
      };

      if (doc.exists) {
        print("SADADSDASD");
        oldUserData = doc.data() as Map<String, dynamic>;
        Map<String, dynamic> toSave = {
          'uid': user.uid,
          'email': user.email,
          'photoURL': photoURL ?? oldUserData['photoURL'],
          'displayName': nama ?? oldUserData['displayName'],
          'Nama': nama ?? oldUserData['firstName'],
          'phone': phone ?? oldUserData['lastName'],
          'namaUsaha': namaUsaha ?? oldUserData['namaUsaha'],
          'lastUpdate': dateIMG
        };
      }
      if (role == "Pemilik") {
        toSave.addEntries({
          'role': role,
          'premium': 0,
        }.entries);
      }
      if (role == "Pegawai") {
        ref = db.collection('users').doc(user.uid);
        DocumentReference refAdmin = db.collection('users').doc(idAdmin);
        List list = [];
        await refAdmin.get().then((value) {
          final data = value.data() as Map<String, dynamic>;
          print("data : ${data}");
          if (data['idPegawai'] != null) {
            list = [...data['idPegawai'], user.uid];
          } else {
            list.add(user.uid);
          }
          print('list : ${list}');

          toSave.addEntries({'role': role, 'idAdmin': idAdmin}.entries);
        });
        await refAdmin.set({'idPegawai': list}, SetOptions(merge: true));
      }
      print("to save : ${toSave}");

      await ref.set(toSave, SetOptions(merge: true));

      return right("Sukses Menyimpan Data");
    } on FirebaseException catch (e) {
      return left(e.message ?? "Gagal Menyimpan");
    }
  }

  User? getCurrentUser() {
    User? user = _firebaseAuth.currentUser;
    return user;
  }

  Future<bool> sendEmailVerif(User user) async {
    if (!user.emailVerified) {
      await user.sendEmailVerification();
      return true;
    } else {
      return false;
    }
  }

  Future<Either<String, User>> signup(
      {required String email,
      required String password,
      String? filePath,
      required nama,
      required phone,
      String? namaUsaha,
      String? referral,
      required role}) async {
    try {
      print("GET RUNER");

      final FirebaseFirestore db = _firebaseFirestore;

      final response = await _firebaseAuth.createUserWithEmailAndPassword(
          email: email, password: password);
      // final response = await _firebaseAuth.sendSignInLinkToEmail(
      //     email: email,
      //     actionCodeSettings: ActionCodeSettings(url: "google.com"));

      final String dateIMG = DateFormat('yyyy-MM-dd-kk').format(DateTime.now());
      final user = response.user;
      Iterable? isKode;
      String? downloadURL;
      if (filePath != null) {
        print("GET RUN IMAGE");
        downloadURL = await saveFile(user!.uid, filePath, dateIMG);
      } else {
        ErrorDescription("Gagal Save file");
      }

      if (role == "Pegawai" && referral != null) {
        final kodeRef = db
            .collection('kodeRef')
            .where("token", isEqualTo: int.parse(referral));
        isKode = await kodeRef.get().then((value) => value.docs.map((e) {
              final id = e.id;

              db.collection('kodeRef').doc(id).delete();
              return e.data();
            }));
      }

      if (user != null) {
        final verif = await sendEmailVerif(user);
        if (verif) {
          print("VERIF TERKIRIM");
          right(left(user));
        }
        print("GET RUN");
        await saveUser(
            user: user,
            filePath: filePath,
            nama: nama,
            phone: phone,
            photoURL: downloadURL,
            namaUsaha: namaUsaha,
            idAdmin: isKode?.first['idAdmin'],
            role: role);
      } else {
        ErrorDescription("Gagal Membuat Akun");
      }

      return right(user!);
    } on FirebaseAuthException catch (e) {
      String message = 'Gagal Signup.';

      return left(message);
    }
  }

  Future<Either<String, Either<User?, User?>>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = response.user;
      if (user != null) {
        final verif = await sendEmailVerif(user);
        if (verif) {
          return right(left(user));
        }
      }

      return right(right(user));
    } on FirebaseAuthException catch (e) {
      String message = 'Gagal Login';
      if (e.code == 'user-not-found') {
        message = 'Akun tidak ditemukan';
      }
      return left(message);
    }
  }

  Future<Either<String, GoogleSignInAccount>> continueWithGoogle(
      {String? role}) async {
    try {
      final googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      String dateIMG = DateFormat('yyyy-MM-dd-kk').format(DateTime.now());

      if (googleUser != null) {
        await GoogleSignIn().disconnect();
        return right(googleUser);
      } else {
        return left('Unknown Error');
      }
    } on FirebaseAuthException catch (e) {
      return left(e.message ?? 'Unknow Error');
    }
  }
  // Future<Either<String, User>> continueWithGoogle({String? role}) async {
  //   try {
  //     final googleSignIn = GoogleSignIn();
  //     final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
  //     String dateIMG = DateFormat('yyyy-MM-dd-kk').format(DateTime.now());

  //     if (googleUser != null) {
  //       final GoogleSignInAuthentication googleAuth =
  //           await googleUser.authentication;
  //       final AuthCredential credential = GoogleAuthProvider.credential(
  //         accessToken: googleAuth.accessToken,
  //         idToken: googleAuth.idToken,
  //       );

  //       final response = await _firebaseAuth.signInWithCredential(credential);
  //       final user = response.user;
  //       if (user != null && role != null) {
  //         saveUser(user: user, role: role);
  //       } else {
  //         return left('Email tidak terdaftar');
  //       }

  //       return right(response.user!);
  //     } else {
  //       return left('Unknown Error');
  //     }
  //   } on FirebaseAuthException catch (e) {
  //     return left(e.message ?? 'Unknow Error');
  //   }
  // }

  Future<Either<String, String>> userSignOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      GoogleSignIn().disconnect();
      print("Sign OUT");
      return right("Success Log Out");
    } on FirebaseAuthException catch (e) {
      return left("Error Logout" + e.toString());
    }
  }
}

final authDataSourceProvider = Provider<AuthDataSource>(
  (ref) => AuthDataSource(
      ref.read(firebaseAuthProvider),
      ref.read(firebaseFirestoreProvider),
      ref.read(firebaseStorageProvider),
      ref),
);
