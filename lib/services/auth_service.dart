abstract class AuthService {
  Future<void> register({required String email, required String password});
  Future<void> signInWithGitHub();
}

class AuthFailure implements Exception {
  const AuthFailure(this.message);

  final String message;
}
