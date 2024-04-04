import 'package:flutter/material.dart';
import 'coche.dart';
import 'utils/photo_utils.dart';
import 'dart:io';
import 'package:carousel_slider/carousel_slider.dart';

class SecondPage extends StatefulWidget {
  final Coche coche;
  SecondPage({required this.coche});

  @override
  _SecondPageState createState() => _SecondPageState();
}

class _SecondPageState extends State<SecondPage> {
  int count =0;
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
              onPressed:
                  widget.coche.vehiculos != null ? () => _enviar() : null,
              child: Text('Enviar'),
            ),
            SizedBox(height: 10),
            if (widget.coche.vehiculos!.isNotEmpty)
              CarouselSlider(
                options: CarouselOptions(
                  height: 600.0,
                  enlargeCenterPage: true,
                  aspectRatio: 16 / 9,
                  enableInfiniteScroll: true,
                  viewportFraction: 0.8,
                ),
                  items: widget.coche.vehiculos!.map((path) {
    return Builder(
      builder: (BuildContext context) {
        return Column(
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              margin: EdgeInsets.symmetric(horizontal: 5.0),
              decoration: BoxDecoration(
                color: Colors.grey,
              ),
              child: Image.file(
                File(path),
                fit: BoxFit.cover,
              ),
            ),
                        SizedBox(height: 10),

            ElevatedButton(
              onPressed: () {
                // Eliminar la imagen y actualizar el estado
                setState(() {
                  widget.coche.vehiculos!.remove(path);
                   final File existingFile = File(path);
                  existingFile.deleteSync();
                });
              },
              child: Text('Eliminar'),
            ),
          ],
        );
      },
    );
  }).toList(),
              ),
          ],
        ),
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
    final String? photoPath = await PhotoUtils.takePhoto(
        widget.coche.matricula + "_" + string,
        context,count);

    if (photoPath != null) {
      count++;
      widget.coche.vehiculos!.add(photoPath.toString());
      print(widget.coche.vehiculos);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Foto tomada correctamente'),
      ));
    }
    setState(() {});
  }
}
