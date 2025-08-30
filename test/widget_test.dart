// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:salon_app/main.dart';
import 'package:salon_app/services/config_service.dart';

void main() {
  setUpAll(() async {
    // CORRECCIÓN: Inicializar TestWidgetsFlutterBinding para tests
    TestWidgetsFlutterBinding.ensureInitialized();

    // DIAGNÓSTICO: Agregar logs detallados para debugging de tests
    debugPrint('🚀 INICIANDO WIDGET TEST');
    debugPrint('📁 Directorio de trabajo: ${Directory.current.path}');

    // Load environment variables for testing
    try {
      await dotenv.load(fileName: ".env");
      debugPrint('✅ Variables de entorno cargadas');
    } catch (e) {
      debugPrint('❌ Error cargando variables de entorno: $e');
    }

    // CORRECCIÓN: ConfigService puede fallar en tests debido a plugins no disponibles
    // Usaremos un try-catch para manejar MissingPluginException
    try {
      await configService.initialize();
      debugPrint('✅ ConfigService inicializado');
    } catch (e) {
      debugPrint('❌ Error inicializando ConfigService: $e');
      debugPrint('🔍 Tipo de error: ${e.runtimeType}');
      debugPrint('📝 Mensaje: ${e.toString()}');
      // En tests, continuamos sin ConfigService si hay errores de plugins
      if (e.toString().contains('MissingPluginException')) {
        debugPrint(
            '⚠️  MissingPluginException detectado - continuando sin ConfigService');
      }
    }
  });

  testWidgets('App initialization smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that our counter starts at 0.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verify that our counter has incremented.
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}
