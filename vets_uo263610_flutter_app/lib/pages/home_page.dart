import 'package:flutter/material.dart';
import 'package:vets_uo263610_flutter_app/src/user.dart';

class HomePage extends StatefulWidget {
  //final String _title;
  const HomePage({super.key}); // recibimos el titulo en el constructor
  @override
  State<StatefulWidget> createState() => StateHomePage();
}

class StateHomePage extends State<HomePage> {
  List<User> users = [
    User("Pedro", "Alvarez", "pedro.alvarez.com", "034-999-999-977"),
    User("María", "Alvarez", "maria.alvarez.com", "034-999-999-978"),
    User("Teresa", "Almonte", "teresa.almonte.com", "034-999-999-979"),
    User("Juan", "Almonte", "juan.almonte.com", "034-999-999-988"),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Listado de clientes")),
      body: ListView.builder(
        itemCount: users.length,
        itemBuilder: (context, index) {
          return ListTile(
            onTap: () {},
            onLongPress: () {},
            title: Text("${users[index].name} ${users[index].surname}"),
            subtitle: Text("${'Teléfono:'}${users[index].phone}"),
            leading: CircleAvatar(
              child: Text(users[index].name.substring(0, 1)),
            ),
            trailing: const Icon(Icons.call, color: Colors.black),
          );
        },
      ),
    );
  }
}
