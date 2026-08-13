class UserModel {
  final String? id;
  final String email;
  final String? fullName;
  final String? token;

  UserModel({
    this.id,
    required this.email,
    this.fullName,
    this.token,
  });

  // 1. Backend'den gelen JSON haritasını Dart nesnesine çevirir
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as String?,
      email: map['email'] ?? '',
      fullName: map['fullName'] as String?,
      token: map['token'] as String?,
    );
  }

  // 2. Dart nesnesini Backend'e göndermek üzere JSON haritasına çevirir
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'email': email,
      if (fullName != null) 'fullName': fullName,
      if (token != null) 'token': token,
    };
  }
}