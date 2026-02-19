class VetClinic {
  final String id;
  final String placeId;
  final String name;
  final String address;
  final bool openNow;
  final double rating;
  final List<String> services;
  final String email;
  final String phone;
  final String website;
  final String? photo;

  const VetClinic({
    required this.id,
    required this.placeId,
    required this.name,
    required this.address,
    required this.openNow,
    required this.rating,
    required this.services,
    required this.email,
    required this.phone,
    required this.website,
    this.photo,
  });

  factory VetClinic.fromJson(Map<String, dynamic> json) {
    return VetClinic(
      id: (json['_id'] ?? '').toString(),
      placeId: (json['place_id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      address: (json['address'] ?? '').toString(),
      openNow: json['open_now'] == true,
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      services: (json['services'] as List?)
              ?.map((service) => service.toString())
              .toList() ??
          const [],
      email: (json['email'] ?? '').toString(),
      phone: (json['phone'] ?? '').toString(),
      website: (json['web_site'] ?? '').toString(),
      photo: _extractPhoto(json),
    );
  }

  static String? _extractPhoto(Map<String, dynamic> json) {
    // Try several possible keys/formats that backend might provide
    if (json.containsKey('photo')) {
      final v = json['photo'];
      if (v != null) return v.toString();
    }
    if (json.containsKey('photo_url')) {
      final v = json['photo_url'];
      if (v != null) return v.toString();
    }
    if (json.containsKey('photoUrl')) {
      final v = json['photoUrl'];
      if (v != null) return v.toString();
    }
    if (json.containsKey('photos')) {
      final photos = json['photos'];
      if (photos is List && photos.isNotEmpty) {
        final first = photos.first;
        if (first is String) return first;
        if (first is Map) {
          if (first.containsKey('url') && first['url'] != null) return first['url'].toString();
          if (first.containsKey('photo') && first['photo'] != null) return first['photo'].toString();
        }
      }
    }
    return null;
  }

  String get city {
    final segments = address.split(',').map((segment) => segment.trim()).toList();
    if (segments.length >= 2) {
      return segments[segments.length - 2];
    }
    return address;
  }
}
