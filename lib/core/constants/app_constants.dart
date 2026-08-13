class AppConstants {
  static const String baseUrl = 'https://10.0.2.2:7012/api/'; 

  static const String tokenKey = 'jwt_token';
  static const String userRoleKey = 'user_role';

  static const Duration connectTimeout = Duration(seconds: 45);
  static const Duration receiveTimeout = Duration(seconds: 45);
}