import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'firebase_options.dart';
import 'core/constants/app_theme.dart';
import 'core/constants/app_colors.dart';
import 'providers/auth_provider.dart';
import 'providers/medicamento_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'services/notification_service.dart';

void main() async {
  // Asegura que Flutter esté inicializado
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Inicializar servicio de notificaciones
  await NotificationService().initialize();

  // Inicializar locale en español para fechas
  await initializeDateFormatting('es', null);

  // Orientación solo vertical
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Color de la barra de estado
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const FarmaciaApp());
}

class FarmaciaApp extends StatelessWidget {
  const FarmaciaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => MedicamentoProvider()),
      ],
      child: MaterialApp(
        title: 'Farmacia App',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const _AuthWrapper(),
      ),
    );
  }
}

// Decide qué pantalla mostrar según si el usuario está autenticado
class _AuthWrapper extends StatelessWidget {
  const _AuthWrapper();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    switch (auth.status) {
      case AuthStatus.inicial:
        // Pantalla de carga mientras Firebase verifica la sesión
        return const Scaffold(
          backgroundColor: AppColors.background,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.medication_outlined,
                  size: 64,
                  color: AppColors.primary,
                ),
                SizedBox(height: 24),
                CircularProgressIndicator(
                  color: AppColors.primary,
                  strokeWidth: 2,
                ),
              ],
            ),
          ),
        );

      case AuthStatus.autenticado:
        return const DashboardScreen();

      case AuthStatus.noAutenticado:
      case AuthStatus.cargando:
        return const LoginScreen();
    }
  }
}