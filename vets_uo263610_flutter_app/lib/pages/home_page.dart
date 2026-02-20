import 'package:flutter/material.dart';
import 'package:vets_uo263610_flutter_app/pages/clinic_detail_page.dart';
import 'package:vets_uo263610_flutter_app/pages/user_detail_page.dart';
import 'package:vets_uo263610_flutter_app/pages/user_edit_form.dart';
import 'package:vets_uo263610_flutter_app/pages/user_signup_form.dart';
import 'package:vets_uo263610_flutter_app/src/user.dart';
import 'package:vets_uo263610_flutter_app/pages/settings_page.dart';
import 'package:vets_uo263610_flutter_app/pages/vet_clinic_register_form.dart';
import 'package:vets_uo263610_flutter_app/src/api_service.dart';
import 'package:vets_uo263610_flutter_app/src/vet_clinic.dart';

class HomePage extends StatefulWidget {
  final String token;

  const HomePage({super.key, required this.token});

  @override
  State<StatefulWidget> createState() => StateHomePage();
}

class StateHomePage extends State<HomePage> {
  Future<void> _openAddClinic() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => VetClinicRegisterForm(
          onSubmit: (data) async {
            try {
              await ApiService.registerVetClinic(token: widget.token, data: data);
              if (context.mounted) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(this.context).showSnackBar(
                  const SnackBar(content: Text('Clínica registrada correctamente')),
                );
                await _loadData();
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: ${e.toString()}')),
                );
              }
            }
          },
        ),
      ),
    );
  }
  final TextEditingController _searchController = TextEditingController();
  bool _loading = true;
  String? _error;
  List<VetClinic> _clinics = [];
  List<User> _users = [];
  String _search = '';
  int _selectedTab = 0;
  bool _showOnlyFavorites = false;
  final Set<String> _favoriteClinicIds = {};
  final Map<String, List<String>> _customServicesByClinic = {};
  final Map<String, List<User>> _assignedUsersByClinic = {};

  @override
  void initState() {
    super.initState();
    _loadData();
    _searchController.addListener(() {
      setState(() {
        _search = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final results = await Future.wait([
        ApiService.getVets(widget.token),
        ApiService.getUsers(widget.token),
      ]);

      setState(() {
        _clinics = results[0] as List<VetClinic>;
        _users = results[1] as List<User>;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  List<String> _servicesFor(VetClinic clinic) {
    return _customServicesByClinic[clinic.placeId] ?? clinic.services;
  }

  List<User> _assignedUsersFor(VetClinic clinic) {
    return _assignedUsersByClinic[clinic.placeId] ?? const [];
  }

  bool _isFavorite(VetClinic clinic) {
    return _favoriteClinicIds.contains(clinic.placeId);
  }

  void _toggleFavorite(VetClinic clinic) {
    setState(() {
      if (_favoriteClinicIds.contains(clinic.placeId)) {
        _favoriteClinicIds.remove(clinic.placeId);
      } else {
        _favoriteClinicIds.add(clinic.placeId);
      }
    });
  }

  Future<void> _openAddUser() async {
    final newUser = await Navigator.push<User>(
      context,
      MaterialPageRoute(builder: (_) => const UserSignUpForm()),
    );

    if (newUser == null) {
      return;
    }

    setState(() {
      _users = [..._users, newUser..localOnly = true];
    });
  }

  Future<void> _openUserDetail(User user) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => UserDetailPage(user: user)),
    );
  }

  Future<void> _openEditUser(User user) async {
    final editedUser = await Navigator.push<User>(
      context,
      MaterialPageRoute(builder: (_) => UserEditForm(user: user)),
    );

    if (editedUser == null) {
      return;
    }

    setState(() {
      _users = _users.map((current) {
        if (current.email == user.email) {
          return User(
            editedUser.name,
            editedUser.surname,
            editedUser.email,
            editedUser.phone,
            id: current.id,
            birthDate: current.birthDate,
            localOnly: current.localOnly,
          );
        }
        return current;
      }).toList();

      _assignedUsersByClinic.updateAll((_, assignedUsers) {
        return assignedUsers.map((current) {
          if (current.email == user.email) {
            return User(
              editedUser.name,
              editedUser.surname,
              editedUser.email,
              editedUser.phone,
              id: current.id,
              birthDate: current.birthDate,
              localOnly: current.localOnly,
            );
          }
          return current;
        }).toList();
      });
    });
  }

  void _deleteUser(User user) {
    setState(() {
      _users.removeWhere((current) => current.email == user.email);
      _assignedUsersByClinic.updateAll((_, assignedUsers) {
        return assignedUsers
            .where((current) => current.email != user.email)
            .toList();
      });
    });
  }

  void deleteUser(BuildContext context, User user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Borrar usuario"),
        content: Text("¿Está seguro de borrar el usuario: ${user.name}?"),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _users.removeWhere((current) => current.email == user.email);
                _assignedUsersByClinic.updateAll((_, assignedUsers) {
                  return assignedUsers
                      .where((current) => current.email != user.email)
                      .toList();
                });
              });
              Navigator.pop(context);
            },
            child: const Text("Borrar", style: TextStyle(color: Colors.red)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("Cancelar", style: TextStyle(color: Colors.green)),
          ),
        ],
      ),
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

  Future<void> _openClinicDetail(VetClinic clinic) async {
    final result = await Navigator.push<ClinicDetailResult>(
      context,
      MaterialPageRoute(
        builder: (_) => ClinicDetailPage(
          clinic: clinic,
          initialServices: _servicesFor(clinic),
          allUsers: _users,
          initialAssignedUsers: _assignedUsersFor(clinic),
        ),
      ),
    );

    if (result == null) {
      return;
    }

    setState(() {
      _customServicesByClinic[clinic.placeId] = result.services;
      _assignedUsersByClinic[clinic.placeId] = result.assignedUsers;
    });
  }

  @override
  Widget build(BuildContext context) {
    final clinics = _clinics.where((clinic) {
      if (_search.isEmpty) {
        return !_showOnlyFavorites ||
            _favoriteClinicIds.contains(clinic.placeId);
      }
      final matchesSearch =
          clinic.name.toLowerCase().contains(_search) ||
          clinic.address.toLowerCase().contains(_search) ||
          clinic.city.toLowerCase().contains(_search);
      final matchesFavorites =
          !_showOnlyFavorites || _favoriteClinicIds.contains(clinic.placeId);
      return matchesSearch && matchesFavorites;
    }).toList();

    final favoriteClinics = _clinics
        .where((clinic) => _favoriteClinicIds.contains(clinic.placeId))
        .toList();

    final users = _users.where((user) {
      if (_search.isEmpty) {
        return true;
      }
      return user.displayName.toLowerCase().contains(_search) ||
          user.email.toLowerCase().contains(_search) ||
          user.phone.toLowerCase().contains(_search);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _selectedTab == 0
              ? 'Veterinarios'
              : _selectedTab == 1
              ? 'Usuarios'
              : 'Ajustes',
        ),
        actions: [
          IconButton(
            onPressed: _loadData,
            icon: const Icon(Icons.refresh),
            tooltip: 'Recargar',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search),
                labelText: _selectedTab == 0
                    ? 'Buscar veterinario o ciudad'
                    : 'Buscar usuario',
                border: const OutlineInputBorder(),
              ),
            ),
          ),
          if (_selectedTab == 0)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  FilterChip(
                    selected: _showOnlyFavorites,
                    label: const Text('Solo favoritos'),
                    onSelected: (selected) {
                      setState(() {
                        _showOnlyFavorites = selected;
                      });
                    },
                  ),
                ],
              ),
            ),
          if (_selectedTab == 0 && favoriteClinics.isNotEmpty)
            SizedBox(
              height: 54,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  final clinic = favoriteClinics[index];
                  return ActionChip(
                    label: Text(clinic.name),
                    onPressed: () => _openClinicDetail(clinic),
                  );
                },
                separatorBuilder: (_, index) => const SizedBox(width: 8),
                itemCount: favoriteClinics.length,
              ),
            ),
          Expanded(
            child: Builder(
              builder: (context) {
                if (_loading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (_error != null) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Error: $_error',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                if (_selectedTab == 0) {
                  if (clinics.isEmpty) {
                    return const Center(
                      child: Text('No hay clínicas disponibles'),
                    );
                  }
                  return ListView.builder(
                    itemCount: clinics.length,
                    itemBuilder: (context, index) {
                      final clinic = clinics[index];
                      final services = _servicesFor(clinic);
                      final assignedUsers = _assignedUsersFor(clinic);

                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        child: InkWell(
                          onTap: () => _openClinicDetail(clinic),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: (clinic.photo ?? '').isNotEmpty
                                      ? Image.network(
                                          (clinic.photo ?? ''),
                                          width: 100,
                                          height: 80,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) =>
                                                  Container(
                                                    width: 100,
                                                    height: 80,
                                                    color: Colors.grey[200],
                                                    child: const Icon(
                                                      Icons.pets,
                                                      size: 36,
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                        )
                                      : Container(
                                          width: 100,
                                          height: 80,
                                          color: Colors.grey[200],
                                          child: const Icon(
                                            Icons.pets,
                                            size: 36,
                                            color: Colors.grey,
                                          ),
                                        ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              clinic.name,
                                              style: Theme.of(
                                                context,
                                              ).textTheme.titleMedium,
                                            ),
                                          ),
                                          IconButton(
                                            onPressed: () =>
                                                _toggleFavorite(clinic),
                                            icon: Icon(
                                              _isFavorite(clinic)
                                                  ? Icons.favorite
                                                  : Icons.favorite_border,
                                              color: _isFavorite(clinic)
                                                  ? Colors.red
                                                  : null,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: _buildRatingStars(
                                          clinic.rating,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          Icon(
                                            clinic.openNow
                                                ? Icons.check_circle
                                                : Icons.cancel,
                                            color: clinic.openNow
                                                ? Colors.green
                                                : Colors.red,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            clinic.openNow
                                                ? 'Abierto ahora'
                                                : 'Cerrado ahora',
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(clinic.address),
                                      const SizedBox(height: 6),
                                      Text(
                                        '${clinic.city} · Servicios: ${services.length} · Usuarios: ${assignedUsers.length}',
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodySmall,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }

                if (_selectedTab == 1) {
                  if (users.isEmpty) {
                    return const Center(child: Text('No hay usuarios'));
                  }
                  return ListView.builder(
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      final user = users[index];
                      return Dismissible(
                        key: Key(user.email),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          color: Colors.red,
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        confirmDismiss: (direction) async {
                          bool? confirm = await showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text("Borrar usuario"),
                              content: Text(
                                "¿Está seguro de borrar el usuario: ${user.name}?",
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text(
                                    "Borrar",
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: const Text("Cancelar"),
                                ),
                              ],
                            ),
                          );
                          return confirm == true;
                        },
                        onDismissed: (direction) {
                          setState(() {
                            _users.removeWhere(
                              (current) => current.email == user.email,
                            );
                            _assignedUsersByClinic.updateAll((
                              _,
                              assignedUsers,
                            ) {
                              return assignedUsers
                                  .where(
                                    (current) => current.email != user.email,
                                  )
                                  .toList();
                            });
                          });
                        },
                        child: Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          child: ListTile(
                            onTap: () => _openUserDetail(user),
                            onLongPress: () => deleteUser(context, user),
                            title: Text(user.displayName),
                            subtitle: Text('${user.email} · ${user.phone}'),
                            trailing: PopupMenuButton<String>(
                              onSelected: (value) {
                                if (value == 'detail') {
                                  _openUserDetail(user);
                                } else if (value == 'edit') {
                                  _openEditUser(user);
                                } else if (value == 'delete') {
                                  deleteUser(context, user);
                                }
                              },
                              itemBuilder: (context) => const [
                                PopupMenuItem(
                                  value: 'detail',
                                  child: Text('Ver detalle'),
                                ),
                                PopupMenuItem(
                                  value: 'edit',
                                  child: Text('Editar'),
                                ),
                                PopupMenuItem(
                                  value: 'delete',
                                  child: Text('Eliminar'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }

                // Settings tab
                return const SettingsPage();
              },
            ),
          ),
        ],
      ),
      floatingActionButton: _selectedTab == 1
          ? FloatingActionButton.extended(
              onPressed: _openAddUser,
              icon: const Icon(Icons.person_add_alt_1),
              label: const Text('Añadir usuario'),
            )
          : _selectedTab == 0
              ? FloatingActionButton.extended(
                  onPressed: _openAddClinic,
                  icon: const Icon(Icons.add_business),
                  label: const Text('Registrar clínica'),
                )
              : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedTab,
        onDestinationSelected: (index) {
          setState(() {
            _selectedTab = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.pets_outlined),
            selectedIcon: Icon(Icons.pets),
            label: 'Veterinarios',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people),
            label: 'Usuarios',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Ajustes',
          ),
        ],
      ),
    );
  }
}
