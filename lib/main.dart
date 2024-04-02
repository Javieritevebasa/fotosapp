import 'package:flutter/material.dart';
import 'configPage.dart';
import 'second_page.dart';
import 'coche.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
       
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _matriculaController = TextEditingController();
  bool isButtonEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Main Page'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ConfigPage()),
              );
            },
            icon: Icon(Icons.settings),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _matriculaController,
              onChanged: (text) {
                setState(() {
                  isButtonEnabled = text.length >= 4;
                });
              },
              decoration: InputDecoration(
                hintText: 'Ingrese la matrícula...',
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: isButtonEnabled
                  ? () {
                      Coche coche = Coche(
                        matricula: _matriculaController.text,
                      );

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SecondPage(coche: coche),
                        ),
                      );
                    }
                  : null,
              child: Text('Ir a la Segunda Página'),
            ),
          ],
        ),
      ),
    );
  }
}
