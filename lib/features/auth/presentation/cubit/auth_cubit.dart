import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import '../../data/datasources/auth_remote_data_source.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRemoteDataSource _authRemoteDataSource;

  AuthCubit(this._authRemoteDataSource) : super(AuthInitial());

  // 1. Giriş Yap (Login)
  Future<void> login(String username, String password) async {
    emit(AuthLoading());
    try {
      final user = await _authRemoteDataSource.login(
        username: username,
        password: password,
      );
      emit(AuthSuccess(user));
    } on DioException catch (e) {
      // Backend'den dönen özel hata mesajı varsa onu al, yoksa durum kodunu göster
      final errorMessage = e.response?.data is Map && e.response?.data['message'] != null
          ? e.response?.data['message']
          : 'Giriş başarısız! (Hata Kodu: ${e.response?.statusCode ?? "Bağlantı Hatası"})';
      emit(AuthFailure(errorMessage));
    } catch (e) {
      emit(AuthFailure('Giriş yapılırken beklenmeyen bir hata oluştu.'));
    }
  }

  // 2. Kayıt Ol (Register)
  Future<void> register(String username, String email, String password) async {
    emit(AuthLoading());
    try {
      await _authRemoteDataSource.register(
        username: username,
        email: email,
        password: password,
      );
      // Kayıt başarılı olduğunda kullanıcıyı bilgilendir veya otologin akışına al
      emit(AuthInitial()); 
    } on DioException catch (e) {
      final errorMessage = e.response?.data is Map && e.response?.data['message'] != null
          ? e.response?.data['message']
          : 'Kayıt işlemi başarısız! (Hata Kodu: ${e.response?.statusCode})';
      emit(AuthFailure(errorMessage));
    } catch (e) {
      emit(AuthFailure('Kayıt olunurken bir hata oluştu.'));
    }
  }
}