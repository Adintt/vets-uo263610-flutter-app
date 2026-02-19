import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:vets_uo263610_flutter_app/src/api_config.dart';
import 'package:vets_uo263610_flutter_app/src/user.dart';
import 'package:vets_uo263610_flutter_app/src/vet_clinic.dart';

class ApiService {
  static Future<String> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/users/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode != 200) {
      throw Exception('Credenciales inválidas');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final token = (json['token'] ?? '').toString();
    if (token.isEmpty) {
      throw Exception('No se pudo obtener token de sesión');
    }
    return token;
  }

  static Future<List<VetClinic>> getVets(String token) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/vets'),
      headers: {'token': token},
    );

    if (response.statusCode != 200) {
      throw Exception('No se pudieron cargar las clínicas');
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final results = (body['results'] as List?) ?? [];
    return results
        .map((item) => VetClinic.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  static Future<List<User>> getUsers(String token) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/users'),
      headers: {'token': token},
    );

    if (response.statusCode != 200) {
      throw Exception('No se pudieron cargar los usuarios');
    }

    final body = jsonDecode(response.body);
    if (body is! List) {
      return [];
    }

    return body
        .whereType<Map<String, dynamic>>()
        .map(User.fromApiJson)
        .toList();
  }

  static Future<void> registerUser({
    required String name,
    required String surname,
    required String email,
    required String phone,
    required DateTime birthDate,
    required String password,
  }) async {
    final endpoints = [
      '/users/signUp',
    ];

    final payload = {
      'name': name,
      'surname': surname,
      'email': email,
      'birthDate': birthDate.toIso8601String(),
      'password': password,
    };

    String lastError = 'No se pudo completar el registro';
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}${endpoints.first}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return;
    }

    final errorText = _extractErrorMessage(response.body);
    if (errorText != null && errorText.isNotEmpty) {
      lastError = errorText;
    }

    if (response.statusCode == 401 || response.statusCode == 403) {
      throw Exception(
        'El backend no permite registro público (requiere token). Usa una cuenta existente o solicita habilitar el alta de usuarios.',
      );
    }

    throw Exception(lastError);
  }

  static String? _extractErrorMessage(String responseBody) {
    try {
      final parsed = jsonDecode(responseBody);
      if (parsed is Map<String, dynamic>) {
        final message = parsed['message'] ?? parsed['error'];
        if (message != null) {
          return message.toString();
        }
      }
      if (parsed is String) {
        return parsed;
      }
    } catch (_) {
      if (responseBody.trim().isNotEmpty) {
        return responseBody.trim();
      }
    }
    return null;
  }
}
