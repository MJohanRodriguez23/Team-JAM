import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class DefaultFirebaseOptions {
  // Este archivo es un placeholder temporal.
  // Debe ser reemplazado por el archivo generado con `flutterfire configure`.
  static FirebaseOptions? get currentPlatform {
    if (kIsWeb) {
      return null;
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
      case TargetPlatform.iOS:
        return null;
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
        return null;
      case TargetPlatform.fuchsia:
        return null;
    }
  }
}
