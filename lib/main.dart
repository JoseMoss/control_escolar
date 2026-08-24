// Importamos la librería principal de Flutter para los componentes visuales
import 'package:flutter/material.dart';

// Importamos la librería base de Firebase para poder inicializarla
import 'package:firebase_core/firebase_core.dart';

// Importamos el archivo de configuración generado por Firebase para tu plataforma
import 'firebase_options.dart';

// Importamos el archivo de la pantalla principal
import 'package:control_escolar/screens/home_screen.dart';

// La función main ahora es asíncrona (async) porque necesitamos esperar
// a que Firebase se conecte a la nube antes de encender toda la aplicación.
void main() async {
  // 1. Aseguramos que los motores nativos de Flutter estén completamente listos
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Inicializamos Firebase utilizando las opciones configuradas para tu proyecto
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // 3. Arrancamos la aplicación una vez que la conexión a la nube está lista
  runApp(const ControlEscolarApp());
}

class ControlEscolarApp extends StatelessWidget {
  const ControlEscolarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Control Escolar Cómputo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
      ),
      home: const HomeScreen(), // Llamamos a la clase importada desde home_screen.dart
    );
  }
}
