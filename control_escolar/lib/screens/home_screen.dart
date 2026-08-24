import 'package:flutter/material.dart';
import 'package:control_escolar/screens/grupo_screen.dart';
import 'package:control_escolar/screens/prepa_semestres_screen.dart';
import 'package:control_escolar/screens/registro_alumno_screen.dart';
import 'package:control_escolar/screens/registroMateriaScreen.dart';
// ADICIÓN: Importamos la pantalla de registro de actividades
import 'package:control_escolar/screens/registro_actividad_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Barra superior de la aplicación
      appBar: AppBar(
        title: const Text('Control Escolar - Cómputo'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          // Botón para registrar Materia
          IconButton(
            icon: const Icon(Icons.library_add),
            tooltip: 'Registrar Materia',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const RegistroMateriaScreen(),
                ),
              );
            },
          ),
          // ADICIÓN: Botón para registrar Actividad
          IconButton(
            icon: const Icon(Icons.assignment_add),
            tooltip: 'Registrar Actividad',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const RegistroActividadScreen(),
                ),
              );
            },
          ),
        ],
      ),

      // Cuerpo central de la pantalla principal
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Selecciona el Grado y Nivel',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.extent(
                maxCrossAxisExtent: 300,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.3,
                children: const [
                  GradoCard(
                    titulo: '1° Secundaria',
                    icono: Icons.school,
                    esPrepa: false,
                  ),
                  GradoCard(
                    titulo: '2° Secundaria',
                    icono: Icons.school,
                    esPrepa: false,
                  ),
                  GradoCard(
                    titulo: '3° Secundaria',
                    icono: Icons.school,
                    esPrepa: false,
                  ),
                  GradoCard(
                    titulo: 'Preparatoria',
                    icono: Icons.computer,
                    esPrepa: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      // Botón flotante para dar de alta un nuevo alumno
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const RegistroAlumnoScreen(),
            ),
          );
        },
        label: const Text('Nuevo Alumno'),
        icon: const Icon(Icons.person_add),
      ),
    );
  }
}

class GradoCard extends StatelessWidget {
  final String titulo;
  final IconData icono;
  final bool esPrepa;

  const GradoCard({
    super.key,
    required this.titulo,
    required this.icono,
    required this.esPrepa,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          if (esPrepa) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const PrepaSemestresScreen(),
              ),
            );
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => GrupoScreen(nombreGrado: titulo),
              ),
            );
          }
        },
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icono, size: 50, color: Colors.blueAccent),
            const SizedBox(height: 12),
            Text(
              titulo,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
