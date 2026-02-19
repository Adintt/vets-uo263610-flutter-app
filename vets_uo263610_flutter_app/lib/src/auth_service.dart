class AuthService {
  // Credenciales de ejemplo. Reemplazar por integración real más tarde.
  static const String _validEmail = 'admin@admin.com';
  static const String _validPassword = 'admin123';

  static Future<bool> login(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return email == _validEmail && password == _validPassword;
  }
}
