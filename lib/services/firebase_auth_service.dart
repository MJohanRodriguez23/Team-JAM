import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:to_do_ufpso/firebase_options.dart';
import 'package:to_do_ufpso/services/auth_service.dart';

class FirebaseAuthService implements AuthService {
  FirebaseAuthService({FirebaseAuth? firebaseAuth})
    : _firebaseAuth = firebaseAuth;

  final FirebaseAuth? _firebaseAuth;

  @override
  Future<void> register({
    required String email,
    required String password,
  }) async {
    await _ensureFirebaseInitialized();

    try {
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (error) {
      throw AuthFailure(_mapFirebaseError(error));
    } on FirebaseException {
      throw const AuthFailure(
        'No fue posible conectar con Firebase. Revisa la configuracion del proyecto.',
      );
    } catch (_) {
      throw const AuthFailure(
        'Ocurrio un error inesperado al crear la cuenta. Intenta nuevamente.',
      );
    }
  }

  FirebaseAuth get _auth => _firebaseAuth ?? FirebaseAuth.instance;

  Future<void> _ensureFirebaseInitialized() async {
    if (Firebase.apps.isNotEmpty) {
      return;
    }

    try {
      final options = DefaultFirebaseOptions.currentPlatform;

      if (options != null) {
        await Firebase.initializeApp(options: options);
        return;
      }

      await Firebase.initializeApp();
    } on UnsupportedError {
      throw const AuthFailure(
        'Firebase no esta configurado todavia. Sigue la guia en docs/09_registro_real.md.',
      );
    } on FirebaseException {
      throw const AuthFailure(
        'Firebase no esta configurado todavia. Sigue la guia en docs/09_registro_real.md.',
      );
    } catch (_) {
      throw const AuthFailure(
        'Firebase no esta configurado todavia. Sigue la guia en docs/09_registro_real.md.',
      );
    }
  }

  String _mapFirebaseError(FirebaseAuthException error) {
    switch (error.code) {
      case 'email-already-in-use':
        return 'Ese correo ya esta registrado. Intenta iniciar sesion.';
      case 'invalid-email':
        return 'El correo ingresado no es valido.';
      case 'weak-password':
        return 'La contrasena es demasiado debil. Usa al menos 6 caracteres.';
      case 'network-request-failed':
        return 'No fue posible conectarse a internet. Verifica tu conexion.';
      case 'operation-not-allowed':
        return 'El registro con correo y contrasena no esta habilitado en Firebase.';
      default:
        return 'No se pudo crear la cuenta. Intenta nuevamente.';
    }
  }
}
