import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegistroMateriaScreen extends StatefulWidget {
  const RegistroMateriaScreen({super.key});

  @override
  State<RegistroMateriaScreen> createState() => _RegistroMateriaScreenState();
}

class _RegistroMateriaScreenState extends State<RegistroMateriaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _descController = TextEditingController();

  // Lista de grados para que la materia sepa a quién pertenece
  // (Usamos el mismo formato que ya corregimos en RegistroAlumnoScreen)
  final List<String> _grados = [
    '1° Secundaria',
    '2° Secundaria',
    '3° Secundaria',
    'Prepa - 1er Semestre',
    'Prepa - 2do Semestre',
    'Prepa - 3er Semestre',
    'Prepa - 4to Semestre',
    'Prepa - 5to Semestre',
    'Prepa - 6to Semestre',
  ];

  String? _gradoSeleccionado;

  Future<void> _guardarMateria() async {
    if (_formKey.currentState!.validate()) {
      await FirebaseFirestore.instance.collection('materias').add({
        'nombre': _nombreController.text,
        'descripcion': _descController.text,
        'grado': _gradoSeleccionado,
        'fechaCreacion': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Materia registrada con éxito')),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Nueva Materia")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(
                  labelText: 'Nombre de la Materia',
                ),
                validator: (val) => val!.isEmpty ? 'Campo requerido' : null,
              ),
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(
                  labelText: 'Descripción breve',
                ),
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: _gradoSeleccionado,
                decoration: const InputDecoration(labelText: 'Asignar a Grado'),
                items: _grados
                    .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                    .toList(),
                onChanged: (val) => setState(() => _gradoSeleccionado = val),
                validator: (val) => val == null ? 'Selecciona un grado' : null,
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _guardarMateria,
                child: const Text("Guardar Materia"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
