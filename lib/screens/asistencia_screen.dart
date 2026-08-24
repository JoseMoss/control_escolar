import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

// Modelo interno para manejar el estado del alumno en la lista
class AlumnoAsistencia {
  final String idAlumno;
  final String nombreCompleto;
  String estado; // 'Presente', 'Retardo', 'Falta'

  AlumnoAsistencia({
    required this.idAlumno,
    required this.nombreCompleto,
    this.estado = 'Presente', // Por defecto todos inician presentes
  });

  Map<String, dynamic> toJson() {
    return {
      'idAlumno': idAlumno,
      'nombreCompleto': nombreCompleto,
      'estado': estado,
    };
  }
}

class AsistenciaScreen extends StatefulWidget {
  final String materiaId;
  final String nombreMateria;
  final String
  gradoMateria; // Recibe el grado para filtrar a los alumnos correctos

  const AsistenciaScreen({
    super.key,
    required this.materiaId,
    required this.nombreMateria,
    required this.gradoMateria,
  });

  @override
  State<AsistenciaScreen> createState() => _AsistenciaScreenState();
}

class _AsistenciaScreenState extends State<AsistenciaScreen> {
  bool isLoading = true;
  List<AlumnoAsistencia> alumnosLista = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _cargarAlumnos();
  }

  // Carga los alumnos filtrando por el grado o grupo de la materia seleccionada
  Future<void> _cargarAlumnos() async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('alumnos')
          .where('grado', isEqualTo: widget.gradoMateria)
          .get();

      setState(() {
        alumnosLista = querySnapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          String nombre = data['nombre'] ?? 'Sin nombre';
          return AlumnoAsistencia(idAlumno: doc.id, nombreCompleto: nombre);
        }).toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error al cargar alumnos: $e')));
    }
  }

  // Guarda la asistencia general del día en Firestore
  Future<void> _guardarAsistencia() async {
    String fechaHoy = DateTime.now().toIso8601String().split('T')[0];
    String documentoId = '${fechaHoy}_${widget.materiaId}';

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );

      Map<String, dynamic> datosAsistencia = {
        'fecha': fechaHoy,
        'materiaId': widget.materiaId,
        'materia': widget.nombreMateria,
        'grado': widget.gradoMateria,
        'timestamp': FieldValue.serverTimestamp(),
        'registros': alumnosLista.map((a) => a.toJson()).toList(),
      };

      await _firestore
          .collection('asistencias')
          .doc(documentoId)
          .set(datosAsistencia);

      Navigator.pop(context); // Quitar indicador de carga
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Asistencia guardada correctamente en la nube!'),
        ),
      );
      Navigator.pop(context); // Regresar a la lista de materias
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error al guardar: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Asistencia: ${widget.nombreMateria}'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : alumnosLista.isEmpty
          ? Center(
              child: Text(
                'No hay alumnos registrados para el grado: ${widget.gradoMateria}',
                textAlign: TextAlign.center,
              ),
            )
          : ListView.builder(
              itemCount: alumnosLista.length,
              itemBuilder: (context, index) {
                final alumno = alumnosLista[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            '${index + 1}. ${alumno.nombreCompleto}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        // Botones rápidos P / R / F
                        ToggleButtons(
                          isSelected: [
                            alumno.estado == 'Presente',
                            alumno.estado == 'Retardo',
                            alumno.estado == 'Falta',
                          ],
                          onPressed: (int indexButton) {
                            setState(() {
                              if (indexButton == 0) alumno.estado = 'Presente';
                              if (indexButton == 1) alumno.estado = 'Retardo';
                              if (indexButton == 2) alumno.estado = 'Falta';
                            });
                          },
                          color: Colors.grey,
                          selectedColor: Colors.white,
                          fillColor: _obtenerColorBoton(alumno.estado),
                          borderRadius: BorderRadius.circular(8),
                          constraints: const BoxConstraints(
                            minHeight: 36,
                            minWidth: 45,
                          ),
                          children: const [
                            Text(
                              'P',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'R',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'F',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: alumnosLista.isEmpty ? null : _guardarAsistencia,
        label: const Text('Guardar Asistencia'),
        icon: const Icon(Icons.save),
      ),
    );
  }

  Color _obtenerColorBoton(String estado) {
    switch (estado) {
      case 'Presente':
        return Colors.green;
      case 'Retardo':
        return Colors.orange;
      case 'Falta':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }
}
