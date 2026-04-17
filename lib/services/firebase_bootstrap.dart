import 'package:firebase_core/firebase_core.dart';
import 'package:to_do_ufpso/firebase_options.dart';

class FirebaseBootstrap {
  static Future<void> ensureInitialized() async {
    if (Firebase.apps.isNotEmpty) {
      return;
    }

    final options = DefaultFirebaseOptions.currentPlatform;
    await Firebase.initializeApp(options: options);
  }
}
