import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/network/dio_client.dart';
import '../models/user_model.dart';

class AuthRemoteDataSource {
  final DioClient _dioClient;
  final _storage = const FlutterSecureStorage();

  AuthRemoteDataSource(this._dioClient);

  // 1. Kayıt Olma (Register)
  Future<void> register({
    required String username,
    required String email,
    required String password,
    String role = "User",
  }) async {
    await _dioClient.post(
      'Auth/register',
      data: {
        'username': username,
        'email': email,
        'password': password,
        'role': role,
      },
    );
  }

  // 2. Giriş Yapma (Login) ve Token Yakalama
  Future<UserModel> login({
    required String username,
    required String password,
  }) async {
    final response = await _dioClient.post(
      'Auth/login',
      data: {
        'username': username,
        'password': password,
      },
    );

    String? token;

    if (response.data != null) {
      if (response.data is Map<String, dynamic>) {
        // Backend JSON objesi dönüyorsa: {"token": "ey..."} veya {"data": {"token": "ey..."}}
        token = response.data['token'] ??
            response.data['accessToken'] ??
            response.data['data']?['token'];
      } else if (response.data is String) {
        // Backend ham String dönüyorsa
        token = response.data;
      }
    }

    if (token != null && token.isNotEmpty) {
      // Token'ı cihaza yazıyoruz (Dio Interceptor tüm GET/POST'larda bu token'ı gönderecek)
      await _storage.write(key: 'jwt_token', value: token.toString());
      print('=== ALINAN TOKEN ===: $token');
    } else {
      print('=== HATA ===: Backend yanıtında geçerli bir token bulunamadı!');
    }

    if (response.data is Map<String, dynamic> && response.data.containsKey('id')) {
      return UserModel.fromMap(response.data);
    }

    return UserModel(
      id: '0', 
      fullName: username, 
      email: '$username@app.com',
    );
  }
}