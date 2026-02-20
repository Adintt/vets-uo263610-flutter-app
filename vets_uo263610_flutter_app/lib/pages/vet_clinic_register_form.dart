import 'package:flutter/material.dart';

class VetClinicRegisterForm extends StatefulWidget {
  final void Function(Map<String, dynamic>)? onSubmit;
  const VetClinicRegisterForm({Key? key, this.onSubmit}) : super(key: key);

  @override
  State<VetClinicRegisterForm> createState() => _VetClinicRegisterFormState();
}

class _VetClinicRegisterFormState extends State<VetClinicRegisterForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _placeIdController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _latController = TextEditingController();
  final TextEditingController _lngController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _photoController = TextEditingController();
  final TextEditingController _ratingController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _websiteController = TextEditingController();
  final TextEditingController _servicesController = TextEditingController();
  bool _openNow = false;

  @override
  void dispose() {
    _placeIdController.dispose();
    _nameController.dispose();
    _latController.dispose();
    _lngController.dispose();
    _addressController.dispose();
    _photoController.dispose();
    _ratingController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _websiteController.dispose();
    _servicesController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      final Map<String, dynamic> data = {
        'place_id': _placeIdController.text.trim(),
        'name': _nameController.text.trim(),
        'location': {
          'lat': double.tryParse(_latController.text.trim()) ?? 0.0,
          'lng': double.tryParse(_lngController.text.trim()) ?? 0.0,
        },
        'address': _addressController.text.trim(),
        'photo': _photoController.text.trim(),
        'rating': double.tryParse(_ratingController.text.trim()) ?? 0.0,
        'open_now': _openNow,
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'web_site': _websiteController.text.trim(),
        'services': _servicesController.text.trim().isNotEmpty
            ? _servicesController.text.trim().split(',').map((s) => s.trim()).toList()
            : [],
      };
      widget.onSubmit?.call(data);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registrar Clínica Veterinaria')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _placeIdController,
                decoration: const InputDecoration(labelText: 'Place ID *'),
                validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
              ),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nombre *'),
                validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
              ),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _latController,
                      decoration: const InputDecoration(labelText: 'Latitud *'),
                      keyboardType: TextInputType.number,
                      validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _lngController,
                      decoration: const InputDecoration(labelText: 'Longitud *'),
                      keyboardType: TextInputType.number,
                      validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
                    ),
                  ),
                ],
              ),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(labelText: 'Dirección'),
              ),
              TextFormField(
                controller: _photoController,
                decoration: const InputDecoration(labelText: 'URL Foto'),
              ),
              TextFormField(
                controller: _ratingController,
                decoration: const InputDecoration(labelText: 'Valoración'),
                keyboardType: TextInputType.number,
              ),
              SwitchListTile(
                value: _openNow,
                onChanged: (v) => setState(() => _openNow = v),
                title: const Text('Abierto ahora'),
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Teléfono'),
              ),
              TextFormField(
                controller: _websiteController,
                decoration: const InputDecoration(labelText: 'Sitio web'),
              ),
              TextFormField(
                controller: _servicesController,
                decoration: const InputDecoration(labelText: 'Servicios (separados por coma)'),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submit,
                child: const Text('Registrar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
