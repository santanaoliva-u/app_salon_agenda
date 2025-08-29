import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:salon_app/provider/user_provider.dart';
import 'package:salon_app/screens/introduction/splash_screen.dart';
import 'package:salon_app/screens/settings/settings_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:salon_app/services/api_config_service.dart';
import 'package:salon_app/l10n/app_localizations.dart';

// Firebase solo se importa si no estamos en Linux
// y solo si se quiere soportar web/Android/iOS
import 'package:firebase_core/firebase_core.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // DIAGNÓSTICO: Agregar logs detallados de inicialización
  debugPrint('🚀 INICIANDO APLICACIÓN SALON BOOKING');
  debugPrint('📱 Plataforma: ${kIsWeb ? "Web" : "Móvil"}');
  debugPrint(
      '🔧 Flutter version: ${WidgetsBinding.instance.platformDispatcher.locale}');

  // Load environment variables
  try {
    await dotenv.load(fileName: ".env");
    debugPrint('✅ Variables de entorno cargadas correctamente');
  } catch (e) {
    debugPrint('❌ Error cargando variables de entorno: $e');
  }

  // Initialize API configuration service
  final apiConfigService = ApiConfigService();
  try {
    await apiConfigService.initialize();
    debugPrint('✅ ApiConfigService inicializado');
    debugPrint(
        '🔑 Google Maps configurado: ${apiConfigService.hasValidGoogleMapsKey}');
    debugPrint('🔥 Firebase habilitado: ${apiConfigService.firebaseEnabled}');
  } catch (e) {
    debugPrint('❌ Error inicializando ApiConfigService: $e');
  }

  // Inicializar Firebase solo en plataformas no web y si está habilitado
  if (!kIsWeb && apiConfigService.firebaseEnabled) {
    try {
      await Firebase.initializeApp();
      debugPrint('✅ Firebase inicializado correctamente');
    } catch (e) {
      debugPrint('❌ Error inicializando Firebase: $e');
      // En Linux, Firebase puede no estar configurado, deshabilitarlo automáticamente
      if (e.toString().contains('channel-error') ||
          e.toString().contains('Linux')) {
        debugPrint(
            '🔧 Detectado Linux - Firebase no disponible en esta plataforma');
        debugPrint('🔄 Deshabilitando Firebase automáticamente');
        await apiConfigService.toggleFirebase(false);
      } else {
        debugPrint('� Continuando sin Firebase - modo limitado');
      }
    }
  } else if (!kIsWeb && !apiConfigService.firebaseEnabled) {
    debugPrint('🔄 Firebase deshabilitado por configuración del usuario');
  } else {
    debugPrint('🌐 Plataforma web - Firebase no inicializado');
  }

  debugPrint('🎯 Ejecutando runApp...');
  runApp(MyApp(apiConfigService: apiConfigService));
}

class MyApp extends StatelessWidget {
  final ApiConfigService apiConfigService;

  const MyApp({super.key, required this.apiConfigService});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<UserProvider>(
          create: (_) => UserProvider(),
        ),
        ChangeNotifierProvider<ApiConfigService>.value(
          value: apiConfigService,
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Salon App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          primaryColor: const Color(0xff721c80),
          colorScheme: ColorScheme.fromSwatch(
            primarySwatch: Colors.blue,
          ).copyWith(
            primary: const Color(0xff721c80),
            secondary: const Color(0xff721c80),
          ),
        ),
        locale: const Locale('es'), // Set Spanish as default locale
        localizationsDelegates: [
          const AppLocalizationsDelegate(),
          // Agregar delegates de Flutter para soporte completo
          DefaultMaterialLocalizations.delegate,
          DefaultCupertinoLocalizations.delegate,
          DefaultWidgetsLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en', ''), // English
          Locale('es', ''), // Spanish
        ],
        routes: {
          '/settings': (context) => const SettingsScreen(),
        },
        home: const SplashScreen(),
      ),
    );
  }
}
