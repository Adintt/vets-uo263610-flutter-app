import 'package:vets_uo263610_flutter_app/src/api_service.dart';

class AuthService {
  static Future<String> login(String email, String password) {
    return ApiService.login(email, password);
  }

  static Future<void> register({
    required String name,
    required String surname,
    required String email,
    required String phone,
    required DateTime birthDate,
    required String password,
  }) {
    return ApiService.registerUser(
      name: name,
      surname: surname,
      email: email,
      phone: phone,
      birthDate: birthDate,
      password: password,
    );
  }
}
