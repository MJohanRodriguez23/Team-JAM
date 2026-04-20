import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:to_do_ufpso/firebase_options.dart';

class FirebaseBootstrap {
  static bool _firestoreOfflineConfigured = false;

  static Future<void> ensureInitialized() async {
    if (Firebase.apps.isEmpty) {
      final options = DefaultFirebaseOptions.currentPlatform;
      await Firebase.initializeApp(options: options);
    }

    await _configureFirestoreOffline();
  }

  static Future<void> _configureFirestoreOffline() async {
    if (_firestoreOfflineConfigured) {
      return;
    }

    final firestore = FirebaseFirestore.instance;

    if (kIsWeb) {
      firestore.settings = const Settings(
        persistenceEnabled: true,
        webPersistentTabManager: WebPersistentMultipleTabManager(),
      );
      _firestoreOfflineConfigured = true;
      return;
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        firestore.settings = const Settings(persistenceEnabled: true);
        break;
      case TargetPlatform.windows:
      case TargetPlatform.linux:
      case TargetPlatform.fuchsia:
        break;
    }

    _firestoreOfflineConfigured = true;
  }
}
