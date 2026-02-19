import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vets_uo263610_flutter_app/src/user.dart';
import 'package:vets_uo263610_flutter_app/src/vet_clinic.dart';

class ClinicDetailResult {
  final List<String> services;
  final List<User> assignedUsers;

  const ClinicDetailResult({
    required this.services,
    required this.assignedUsers,
  });
}

class ClinicDetailPage extends StatefulWidget {
  final VetClinic clinic;
  final List<String> initialServices;
  final List<User> allUsers;
  final List<User> initialAssignedUsers;

  const ClinicDetailPage({
    super.key,
    required this.clinic,
    required this.initialServices,
    required this.allUsers,
    required this.initialAssignedUsers,
  });

  @override
  State<ClinicDetailPage> createState() => _ClinicDetailPageState();
}

class _ClinicDetailPageState extends State<ClinicDetailPage> {
  static const List<String> _healthServiceTypes = [
    'diagnostic tests',
    'vaccination',
    'identification',
    'internal medicine',
  ];

  static const List<String> _otherServiceTypes = [
    'hairdressing',
    'shop',
    'acupuncture',
  ];

  late List<String> _services;
  late List<User> _assignedUsers;

  @override
  void initState() {
    super.initState();
    _services = [...widget.initialServices];
    _assignedUsers = [...widget.initialAssignedUsers];
  }

  void _saveAndExit() {
    Navigator.pop(
      context,
      ClinicDetailResult(services: _services, assignedUsers: _assignedUsers),
    );
  }

  Future<void> _addService() async {
    final controller = TextEditingController();
    final newService = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Añadir servicio'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Servicio',
              hintText: 'Ej. cirugía general',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, controller.text.trim()),
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );

    if (newService == null || newService.isEmpty) {
      return;
    }

    if (_services.any((service) =>
        service.toLowerCase().trim() == newService.toLowerCase().trim())) {
      _showMessage('El servicio ya existe en esta clínica');
      return;
    }

    setState(() {
      _services.add(newService);
    });
  }

  Future<void> _associateUser() async {
    final assignedEmails = _assignedUsers.map((user) => user.email).toSet();
    final availableUsers = widget.allUsers
        .where((user) => !assignedEmails.contains(user.email))
        .toList();

    if (availableUsers.isEmpty) {
      _showMessage('No hay más usuarios disponibles para asociar');
      return;
    }

    User? selectedUser = availableUsers.first;

    final userToAssign = await showDialog<User>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Asociar usuario'),
              content: DropdownButtonFormField<User>(
                initialValue: selectedUser,
                items: availableUsers
                    .map(
                      (user) => DropdownMenuItem<User>(
                        value: user,
                        child: Text('${user.displayName} (${user.email})'),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  setDialogState(() {
                    selectedUser = value;
                  });
                },
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(context, selectedUser),
                  child: const Text('Asociar'),
                ),
              ],
            );
          },
        );
      },
    );

    if (userToAssign == null) {
      return;
    }

    setState(() {
      _assignedUsers.add(userToAssign);
    });
  }

  void _removeAssignedUser(User user) {
    setState(() {
      _assignedUsers.removeWhere((current) => current.email == user.email);
    });
  }

  void _removeService(String service) {
    setState(() {
      _services.remove(service);
    });
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  bool _containsService(String service) {
    return _services
        .map((current) => current.toLowerCase().trim())
        .contains(service.toLowerCase().trim());
  }

  Future<void> _launchExternal(Uri uri) async {
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      _showMessage('No se pudo abrir el recurso');
    }
  }

  Future<void> _callClinic() async {
    if (widget.clinic.phone.isEmpty) {
      _showMessage('La clínica no tiene teléfono disponible');
      return;
    }
    await _launchExternal(Uri(scheme: 'tel', path: widget.clinic.phone));
  }

  Future<void> _mailClinic() async {
    if (widget.clinic.email.isEmpty) {
      _showMessage('La clínica no tiene correo disponible');
      return;
    }
    await _launchExternal(Uri(scheme: 'mailto', path: widget.clinic.email));
  }

  Future<void> _openWebsite() async {
    if (widget.clinic.website.isEmpty) {
      _showMessage('La clínica no tiene web disponible');
      return;
    }
    await _launchExternal(Uri.parse(widget.clinic.website));
  }

  Future<void> _shareWebsite() async {
    if (widget.clinic.website.isEmpty) {
      _showMessage('La clínica no tiene web disponible para compartir');
      return;
    }
    await SharePlus.instance.share(
      ShareParams(text: 'Mira esta clínica: ${widget.clinic.website}'),
    );
  }

  List<Widget> _buildRatingStars(double rating) {
    final stars = List<Widget>.generate(
      rating.floor(),
      (index) => const Icon(Icons.star, color: Colors.amber, size: 18),
    );
    if (stars.isEmpty) {
      stars.add(const Icon(Icons.star_border, color: Colors.grey, size: 18));
    }
    return stars;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.clinic.name),
        actions: [
          IconButton(
            onPressed: _saveAndExit,
            icon: const Icon(Icons.save),
            tooltip: 'Guardar cambios',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
                leading: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: (widget.clinic.photo ?? '').isNotEmpty
                    ? Image.network(
                        (widget.clinic.photo ?? ''),
                        width: 72,
                        height: 72,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 72,
                          height: 72,
                          color: Colors.grey[200],
                          child: const Icon(Icons.pets, color: Colors.grey),
                        ),
                      )
                    : Container(
                        width: 72,
                        height: 72,
                        color: Colors.grey[200],
                        child: const Icon(Icons.pets, color: Colors.grey),
                      ),
              ),
              title: Text(widget.clinic.name),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Row(children: _buildRatingStars(widget.clinic.rating)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        widget.clinic.openNow ? Icons.check_circle : Icons.cancel,
                        color: widget.clinic.openNow ? Colors.green : Colors.red,
                      ),
                      const SizedBox(width: 6),
                      Text(widget.clinic.openNow ? 'Abierta ahora' : 'Cerrada ahora'),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(widget.clinic.address),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ExpansionTile(
              title: const Text('Servicios de salud'),
              leading: const Icon(Icons.local_hospital, color: Colors.green),
              children: _healthServiceTypes
                  .where(_containsService)
                  .map(
                    (service) => ListTile(
                      leading: const Icon(Icons.check_circle_outline),
                      title: Text(service),
                    ),
                  )
                  .toList(),
            ),
          ),
          Card(
            child: ExpansionTile(
              title: const Text('Otros servicios'),
              leading: const Icon(Icons.pets, color: Colors.green),
              children: _otherServiceTypes
                  .where(_containsService)
                  .map(
                    (service) => ListTile(
                      leading: const Icon(Icons.check_circle_outline),
                      title: Text(service),
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton.icon(
                onPressed: _callClinic,
                icon: const Icon(Icons.phone),
                label: const Text('Llamar'),
              ),
              FilledButton.icon(
                onPressed: _mailClinic,
                icon: const Icon(Icons.email),
                label: const Text('Email'),
              ),
              FilledButton.icon(
                onPressed: _openWebsite,
                icon: const Icon(Icons.public),
                label: const Text('Web'),
              ),
              FilledButton.icon(
                onPressed: _shareWebsite,
                icon: const Icon(Icons.share),
                label: const Text('Compartir'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Servicios',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ),
              IconButton(
                onPressed: _addService,
                icon: const Icon(Icons.add_circle_outline),
                tooltip: 'Añadir servicio',
              ),
            ],
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _services
                .map(
                  (service) => InputChip(
                    label: Text(service),
                    onDeleted: () => _removeService(service),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Usuarios asociados',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ),
              IconButton(
                onPressed: _associateUser,
                icon: const Icon(Icons.person_add_alt_1),
                tooltip: 'Asociar usuario',
              ),
            ],
          ),
          if (_assignedUsers.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text('No hay usuarios asociados a esta clínica.'),
            ),
          ..._assignedUsers.map(
            (user) => Card(
              child: ListTile(
                title: Text(user.displayName),
                subtitle: Text(user.email),
                trailing: IconButton(
                  onPressed: () => _removeAssignedUser(user),
                  icon: const Icon(Icons.remove_circle_outline),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
