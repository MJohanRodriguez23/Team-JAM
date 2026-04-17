import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:to_do_ufpso/services/auth_service.dart';
import 'package:to_do_ufpso/services/firebase_bootstrap.dart';

class FirebaseAuthService implements AuthService {
  FirebaseAuthService({FirebaseAuth? firebaseAuth})
    : _firebaseAuth = firebaseAuth;

  final FirebaseAuth? _firebaseAuth;

  @override
  Future<void> register({
    required String email,
    required String password,
  }) async {
    await _runWithInitialization(
      action: () => _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      ),
      fallbackMessage:
          'Ocurrio un error inesperado al crear la cuenta. Intenta nuevamente.',
    );
  }

  @override
  Future<void> login({required String email, required String password}) async {
    await _runWithInitialization(
      action: () =>
          _auth.signInWithEmailAndPassword(email: email, password: password),
      fallbackMessage:
          'Ocurrio un error inesperado al iniciar sesion. Intenta nuevamente.',
    );
  }

  Future<void> _runWithInitialization({
    required Future<void> Function() action,
    required String fallbackMessage,
  }) async {
    await _ensureFirebaseInitialized();

    try {
      await action();
    } on FirebaseAuthException catch (error) {
      throw AuthFailure(_mapFirebaseError(error));
    } on FirebaseException {
      throw const AuthFailure(
        'No fue posible conectar con Firebase. Revisa la configuracion del proyecto.',
      );
    } catch (_) {
      throw AuthFailure(fallbackMessage);
    }
  }

  FirebaseAuth get _auth => _firebaseAuth ?? FirebaseAuth.instance;

  Future<void> _ensureFirebaseInitialized() async {
    if (Firebase.apps.isNotEmpty) {
      return;
    }

    try {
      await FirebaseBootstrap.ensureInitialized();
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
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Las credenciales ingresadas no son correctas.';
      case 'user-disabled':
        return 'Esta cuenta fue deshabilitada. Contacta al administrador.';
      default:
        return 'No se pudo completar la autenticacion. Intenta nuevamente.';
    }
  }
}
