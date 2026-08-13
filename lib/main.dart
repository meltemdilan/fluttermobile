import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/init/service_locator.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'features/auth/presentation/views/login_view.dart';
import 'features/invoice/presentation/cubit/invoice_cubit.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Service Locator senkron çağrılıyor
  setupServiceLocator();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(
          create: (context) => getIt<AuthCubit>(),
        ),
        BlocProvider<InvoiceCubit>(
          create: (context) => getIt<InvoiceCubit>(),
        ),
      ],
      child: MaterialApp(
        title: 'MdgInvoiceManager',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
          useMaterial3: true,
        ),
        home: const LoginView(),
      ),
    );
  }
}