import 'package:get_it/get_it.dart';
import '../network/dio_client.dart';
import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';

// Invoice Importları
import '../../features/invoice/data/datasources/invoice_remote_data_source.dart';
                   
 import '../../features/invoice/presentation/cubit/invoice_cubit.dart';

final GetIt getIt = GetIt.instance;

void setupServiceLocator() {
  // 1. Network Client
  getIt.registerLazySingleton<DioClient>(() => DioClient());

  // 2. Auth Data Source & Cubit
  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSource(getIt<DioClient>()),
  );

  getIt.registerFactory<AuthCubit>(
    () => AuthCubit(getIt<AuthRemoteDataSource>()),
  );

  // 3. Invoice Data Source
  getIt.registerLazySingleton<InvoiceRemoteDataSource>(
    () => InvoiceRemoteDataSource(getIt<DioClient>()),
  );

  getIt.registerFactory<InvoiceCubit>(
  () => InvoiceCubit(getIt<InvoiceRemoteDataSource>()),
);
}