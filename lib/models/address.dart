class Address {
  final String id;
  final String userId;
  final String title;
  final double latitude;
  final double longitude;
  final String addressText;
  DateTime createdAt;

  Address({
    required this.id,
    required this.userId,
    required this.title,
    required this.latitude,
    required this.longitude,
    required this.addressText,
    required this.createdAt,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['id'],
      userId: json['user_id'],
      title: json['title'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      addressText: json['address_text'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'latitude': latitude,
      'longitude': longitude,
      'address_text': addressText,
      'created_at': createdAt.toIso8601String(),
    };
  }
}