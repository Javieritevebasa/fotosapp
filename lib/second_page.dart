import 'package:flutter/material.dart';
import 'coche.dart';
import 'utils/photo_utils.dart';
import 'dart:io';

class SecondPage extends StatefulWidget {
  final Coche coche;

  SecondPage({required this.coche});

  @override
  _SecondPageState createState() => _SecondPageState();
}

class _SecondPageState extends State<SecondPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Second Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text(
              'Matrícula: ${widget.coche.matricula}',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _takePhoto("vehiculo", context),
              child: Text('Tomar Foto Del Vehículo'),
            ),
            ElevatedButton(
              onPressed: widget.coche.vehiculo != null ? () => _enviar() : null,
              child: Text('Enviar'),
            ),
            SizedBox(height: 20),
            _buildImagePreview(widget.coche.vehiculo, "Imagen vehículo*"),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview(String? imagePath, String name) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              if (imagePath != null && imagePath.isNotEmpty)
                Image.memory(
                  File(imagePath).readAsBytesSync(),
                  fit: BoxFit.contain, // Ajustar a la ventana
                  height: 400, // Tamaño máximo de la imagen
                  width: 400, // Ancho máximo
                ),
              if (imagePath == null || imagePath.isEmpty)
                Container(
                  width: double.infinity,
                  height: 200,
                  color: Color.fromARGB(
                      94, 146, 146, 146), // Color de fondo para la "x"
                  child: Center(
                    child: Text(
                      'Sin Foto',
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(
                            143, 115, 0, 255), // Color del texto "X"
                      ),
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 5), // Espacio entre la imagen y el título
          Center(
            child: Text(
              name,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _enviar() async {
    try {
      // Lógica para enviar
      await PhotoUtils.enviarYEliminar(widget.coche, context);
    } catch (e) {
      print('Error en _enviar: $e');
    }
  }

  Future<void> _takePhoto(String string, BuildContext context) async {
    final String? photoPath =
        await PhotoUtils.takePhoto(widget.coche.matricula + "_" + string);

    if (photoPath != null) {
      setState(() {
        switch (string) {
          case "vehiculo":
            widget.coche.vehiculo = photoPath.toString();
            break;
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Foto tomada correctamente'),
      ));
    }
  }
}
