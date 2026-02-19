class User {
  String? id;
  String name;
  String surname;
  String email;
  String phone;
  DateTime? birthDate;
  bool localOnly;

  User(
    this.name,
    this.surname,
    this.email,
    this.phone, {
    this.id,
    this.birthDate,
    this.localOnly = false,
  });

  factory User.fromApiJson(Map<String, dynamic> json) {
    return User(
      (json['name'] ?? '').toString(),
      (json['surname'] ?? '').toString(),
      (json['email'] ?? '').toString(),
      (json['phone'] ?? '').toString(),
      id: (json['_id'] ?? '').toString(),
      birthDate: DateTime.tryParse((json['birthDate'] ?? '').toString()),
      localOnly: false,
    );
  }

  String get displayName => '$name $surname'.trim();
}
