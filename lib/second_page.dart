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
              onPressed: widget.coche.vehiculos != null ? () => _enviar() : null,
              child: Text('Enviar'),
            ),
            SizedBox(height: 20),
            CarouselSlider(
              options: CarouselOptions(
                aspectRatio: 16 / 9,
                enlargeCenterPage: true,
              ),
              items: widget.coche.vehiculos!.map((imagePath) {
                return Builder(
                  builder: (BuildContext context) {
                    return Container(
                      width: MediaQuery.of(context).size.width,
                      margin: EdgeInsets.symmetric(horizontal: 5.0),
                      decoration: BoxDecoration(
                        color: Colors.grey,
                      ),
                      child: Image.file(
                        File(imagePath),
                        fit: BoxFit.cover,
                      ),
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
    final String? photoPath =
        await PhotoUtils.takePhoto(widget.coche.matricula + "_" + string);

    if (photoPath != null) {
      widget.coche.vehiculos!.add(photoPath.toString());
      print(widget.coche.vehiculos);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Foto tomada correctamente'),
      ));
    }
  }
}
