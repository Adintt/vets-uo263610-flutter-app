import 'package:flutter/material.dart';
import 'package:vets_uo263610_flutter_app/src/user.dart';

class UserDetailPage extends StatelessWidget {
  final User user;
  const UserDetailPage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalle usuario')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Nombre'),
              subtitle: Text('${user.name} ${user.surname}'),
            ),
            const Divider(),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Email'),
              subtitle: Text(user.email),
            ),
            const Divider(),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Teléfono'),
              subtitle: Text(user.phone),
            ),
            const Divider(),
            const SizedBox(height: 12),
            const Text(
              'Vista de solo lectura',
              style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
