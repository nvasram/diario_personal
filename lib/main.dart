
import 'package:flutter/material.dart';

import 'models/entrada.dart';
import 'screens/inicio_screen.dart';
import 'screens/nueva_entrada_screen.dart';
import 'screens/detalle_screen.dart';

// Punto de inicio de la aplicación
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Diario Personal',
      debugShowCheckedModeBanner: false,

      // Tema principal de la aplicación
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.purple,
        ),
        useMaterial3: true,
      ),

      // Pantalla inicial
      initialRoute: '/',

      // Rutas de navegación
      routes: {
        '/': (context) => const InicioScreen(),

        '/nueva': (context) =>
        const NuevaEntradaScreen(),

        '/detalle': (context) {
          final entrada =
          ModalRoute.of(context)!.settings.arguments
          as Entrada;

          return DetalleScreen(entrada: entrada);
        },
      },
    );
  }
}
