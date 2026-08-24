// Importamos la librería principal de Flutter para componentes visuales
import 'package:flutter/material.dart';

// Importamos Cloud Firestore para consultar los datos en la nube
import 'package:cloud_firestore/cloud_firestore.dart';

// Importamos la pantalla del detalle de entregas por alumno
import 'package:control_escolar/screens/detalle_actividad_screen.dart';

/// Pantalla que muestra el listado de actividades creadas para una materia específica,
/// consultando los datos en tiempo real desde Firebase Firestore.
class ListaActividadesScreen extends StatelessWidget {
  final String materiaId; // ID único de la materia en Firestore
  final String
  nombreMateria; // Nombre de la materia para mostrarlo en el AppBar

  const ListaActividadesScreen({
    super.key,
    required this.materiaId,
    required this.nombreMateria,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Barra superior con el nombre de la materia seleccionada
      appBar: AppBar(
        title: Text('Actividades de $nombreMateria'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Lista de Prácticas y Tareas',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // StreamBuilder para escuchar las actividades de esta materia en tiempo real
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                // CORREGIDO: Usamos 'idMateria' que es como se guarda en la base de datos
                stream: FirebaseFirestore.instance
                    .collection('actividades')
                    .where('idMateria', isEqualTo: materiaId)
                    .snapshots(),
                builder: (context, snapshot) {
                  // 1. Manejo de errores en la conexión
                  if (snapshot.hasError) {
                    return const Center(
                      child: Text('Error al cargar las actividades.'),
                    );
                  }

                  // 2. Indicador de carga mientras responde Firebase
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final docs = snapshot.data!.docs;

                  // 3. Mensaje si todavía no hay actividades registradas para esta materia
                  if (docs.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.assignment_outlined,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'No hay actividades registradas para esta materia.',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }

                  // 4. Construcción de la lista visual de actividades
                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final doc = docs[index];
                      final data = doc.data() as Map<String, dynamic>;
                      final actividadId = doc.id;

                      // Extracción de datos del documento
                      final titulo = data['titulo'] ?? 'Sin título';
                      final descripcion =
                          data['descripcion'] ?? 'Sin descripción';

                      return Card(
                        elevation: 3,
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: CircleAvatar(
                            backgroundColor: Colors.blueAccent.shade100,
                            child: const Icon(
                              Icons.assignment,
                              color: Colors.blueAccent,
                            ),
                          ),
                          title: Text(
                            titulo,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 6.0),
                            child: Text(
                              descripcion,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: Colors.black87),
                            ),
                          ),
                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                          ),
                          // 5. Al hacer clic, navega al checklist de alumnos pasándole los datos de la actividad
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DetalleActividadScreen(
                                  actividadId: actividadId,
                                  tituloActividad: titulo,
                                  descripcionActividad: descripcion,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
