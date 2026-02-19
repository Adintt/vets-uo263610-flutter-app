import 'package:flutter/material.dart';
import 'package:vets_uo263610_flutter_app/pages/home_page.dart';
import 'package:vets_uo263610_flutter_app/src/auth_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  DateTime? _birthDate;
  final TextEditingController _birthDateController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _repeatPasswordController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _surnameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _birthDateController.dispose();
    _passwordController.dispose();
    _repeatPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _loading = true);

    final name = _nameController.text.trim();
    final surname = _surnameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final birthDate = _birthDate;
    final password = _passwordController.text;

    try {
      await AuthService.register(
        name: name,
        surname: surname,
        email: email,
        phone: phone,
        birthDate: birthDate!,
        password: password,
      );

      final token = await AuthService.login(email, password);
      if (!mounted) {
        return;
      }

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => HomePage(token: token)),
        (_) => false,
      );
    } catch (e) {
      if (!mounted) {
        return;
      }
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('No se pudo registrar'),
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Aceptar'),
            ),
          ],
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registro')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Nombre'),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Introduce el nombre';
                        }
                        final name = v.trim();
                        if (name.length < 2) return 'El nombre debe tener al menos 2 caracteres';
                        if (name.length > 50) return 'El nombre no debe exceder 50 caracteres';
                        final re = RegExp(r"^[A-Za-zÀ-ÿ\s]+$");
                        if (!re.hasMatch(name)) return 'Nombre inválido (solo letras y espacios)';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _surnameController,
                      decoration: const InputDecoration(labelText: 'Apellidos'),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Introduce los apellidos';
                        }
                        final surname = v.trim();
                        if (surname.length < 2) return 'Los apellidos deben tener al menos 2 caracteres';
                        if (surname.length > 100) return 'Los apellidos no deben exceder 100 caracteres';
                        final re = RegExp(r"^[A-Za-zÀ-ÿ\s]+$");
                        if (!re.hasMatch(surname)) return 'Apellidos inválidos (solo letras y espacios)';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(labelText: 'Email'),
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Introduce el email';
                        final email = v.trim();
                        final re = RegExp(r'^[\w\-.]+@([\w\-]+\.)+[A-Za-z]{2,}$');
                        if (!re.hasMatch(email)) return 'Email inválido';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _phoneController,
                      decoration: const InputDecoration(labelText: 'Teléfono (opcional)'),
                      keyboardType: TextInputType.phone,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return null;
                        final phone = v.trim();
                        final re = RegExp(r'^[\d\s\+\-\(\)]+$');
                        if (!re.hasMatch(phone)) return 'Teléfono inválido';
                        if (phone.length < 6) return 'Teléfono demasiado corto';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _birthDateController,
                      decoration:
                          const InputDecoration(labelText: 'Fecha de nacimiento'),
                      readOnly: true,
                      onTap: () async {
                        final now = DateTime.now();
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime(now.year - 20),
                          firstDate: DateTime(1900),
                          lastDate: now,
                        );
                        if (picked != null) {
                          setState(() {
                            _birthDate = picked;
                            _birthDateController.text =
                                '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
                          });
                        }
                      },
                      validator: (v) {
                        if (_birthDate == null) return 'Introduce la fecha de nacimiento';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _passwordController,
                      decoration: const InputDecoration(labelText: 'Contraseña'),
                      obscureText: true,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Introduce la contraseña';
                        if (v.length < 6) return 'La contraseña debe tener al menos 6 caracteres';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _repeatPasswordController,
                      decoration: const InputDecoration(
                        labelText: 'Repetir contraseña',
                      ),
                      obscureText: true,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Repite la contraseña';
                        if (v != _passwordController.text) return 'Las contraseñas no coinciden';
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _submit,
                        child: _loading
                            ? const SizedBox(
                                height: 16,
                                width: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Crear cuenta'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
