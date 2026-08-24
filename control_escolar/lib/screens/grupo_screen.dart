// Importamos las librerías necesarias de Flutter y Firebase Firestore
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Importamos la pantalla de registro para poder usar el botón de agregar alumno filtrado
import 'registro_alumno_screen.dart';

// Esta pantalla recibe el nombre del grado o semestre seleccionado (ej. "1° Secundaria" o "Preparatoria - Semestre 3")
class GrupoScreen extends StatelessWidget {
  final String nombreGrado;

  const GrupoScreen({super.key, required this.nombreGrado});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          nombreGrado,
        ), // Muestra el título del grado o semestre arriba
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),

      // StreamBuilder escucha en tiempo real los cambios en la base de datos de Firebase
      body: StreamBuilder<QuerySnapshot>(
        // Consultamos la colección 'alumnos' filtrando únicamente los que coincidan con este grado
        stream: FirebaseFirestore.instance
            .collection('alumnos')
            .where('grado', isEqualTo: nombreGrado)
            .snapshots(),
        builder: (context, snapshot) {
          // 1. Si la conexión está cargando, mostramos un círculo de carga en pantalla
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // 2. Si ocurre algún error en la consulta
          if (snapshot.hasError) {
            return Center(
              child: Text('Error al cargar los datos: ${snapshot.error}'),
            );
          }

          // 3. Obtenemos los documentos de la consulta
          final documentos = snapshot.data?.docs ?? [];

          // 4. Si no hay alumnos registrados en este grado aún
          if (documentos.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  'No hay alumnos registrados en $nombreGrado.\nPresiona el botón "+" para agregar el primero.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
            );
          }

          // 5. Si hay alumnos, los construimos en una lista deslizante (ListView)
          return ListView.builder(
            itemCount: documentos.length,
            itemBuilder: (context, index) {
              // Extraemos los datos de cada alumno individualmente
              final alumnoData =
                  documentos[index].data() as Map<String, dynamic>;

              final nombre = alumnoData['nombre'] ?? '';
              final apellidoPaterno = alumnoData['apellidoPaterno'] ?? '';
              final apellidoMaterno = alumnoData['apellidoMaterno'] ?? '';
              final tutor = alumnoData['nombreTutor'] ?? 'Sin tutor';
              final telefono = alumnoData['numeroTutor'] ?? 'Sin teléfono';
              final esAdventista = alumnoData['esAdventista'] ?? false;

              // Retornamos una tarjeta (Card) bonita para cada alumno
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blueAccent,
                    child: Text(
                      nombre.isNotEmpty ? nombre[0].toUpperCase() : 'A',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    '$nombre $apellidoPaterno $apellidoMaterno',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('Tutor: $tutor\nTel: $telefono'),
                  isThreeLine: true,
                  // Icono o indicador visual si es adventista
                  trailing: esAdventista
                      ? const Tooltip(
                          message: 'Alumno Adventista',
                          child: Icon(Icons.star, color: Colors.amber),
                        )
                      : null,
                ),
              );
            },
          );
        },
      ),

      // Botón flotante para registrar un alumno nuevo ya pre-asignado a este grado
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  RegistroAlumnoScreen(gradoPredefinido: nombreGrado),
            ),
          );
        },
        label: const Text('Registrar Alumno'),
        icon: const Icon(Icons.person_add),
      ),
    );
  }
}
