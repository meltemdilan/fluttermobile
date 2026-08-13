import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/app_constants.dart';

class DioClient {
  late final Dio _dio;
  final _storage = const FlutterSecureStorage();

  DioClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.baseUrl, // https://10.0.2.2:7012/api/
        connectTimeout: AppConstants.connectTimeout,
        receiveTimeout: AppConstants.receiveTimeout,
        followRedirects: true,
        maxRedirects: 5,
        headers: const {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // SSL Sertifika Doğrulamasını Baypas Etme (Localhost HTTPS için şarttır)
    _dio.httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: () {
        final client = HttpClient();
        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) => true;
        return client;
      },
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          try {
            final token = await _storage.read(key: AppConstants.tokenKey);
            if (token != null && token.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          } catch (e) {
            print(">>> [STORAGE ERROR]: Token okunamadı -> $e");
          }

          print(">>> [OUTGOING REQ]: ${options.method} -> ${options.uri}");
          return handler.next(options);
        },
        onResponse: (response, handler) {
          print(">>> [RESPONSE]: ${response.statusCode} -> ${response.realUri}");
          return handler.next(response);
        },
        onError: (DioException e, handler) {
          print(">>> [DIO ERROR]: ${e.type} | ${e.message}");
          if (e.response != null) {
            print(">>> [ERROR DATA]: ${e.response?.statusCode} -> ${e.response?.data}");
          }
          return handler.next(e);
        },
      ),
    );
  }

  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
    return await _dio.get(path, queryParameters: queryParameters);
  }

  Future<Response> post(String path, {dynamic data}) async {
    return await _dio.post(path, data: data);
  }

  Future<Response> delete(String path) async {
    return await _dio.delete(path);
  }
}