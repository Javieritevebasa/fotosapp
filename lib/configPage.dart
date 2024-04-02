import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ConfigPage extends StatefulWidget {
  @override
  _ConfigPageState createState() => _ConfigPageState();
}

class _ConfigPageState extends State<ConfigPage> {
  final TextEditingController _ipController = TextEditingController();
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  int _selectedQuality = 50; // Valor predeterminado
  List<int> _qualityOptions = List.generate(99, (index) => index + 1);

  @override
  void initState() {
    super.initState();
    _loadConfigValues();
  }

  Future<void> _loadConfigValues() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _ipController.text = prefs.getString('ip') ?? '';
      _userController.text = prefs.getString('user') ?? '';
      _passwordController.text = prefs.getString('password') ?? '';
      _selectedQuality = prefs.getInt('quality') ?? 50;
    });
  }

  Future<void> _saveConfigValues() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('ip', _ipController.text);
    prefs.setString('user', _userController.text);
    prefs.setString('password', _passwordController.text);
    prefs.setInt('quality', _selectedQuality);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Configuración'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _ipController,
              decoration: InputDecoration(labelText: 'Dirección IP'),
            ),
            TextField(
              controller: _userController,
              decoration: InputDecoration(labelText: 'Usuario'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Contraseña'),
              obscureText: true,
            ),
            // DropdownButton para seleccionar la calidad de la imagen
            DropdownButton<int>(
              value: _selectedQuality,
              onChanged: (newValue) {
                setState(() {
                  _selectedQuality = newValue!;
                });
              },
              items: _qualityOptions.map((quality) {
                return DropdownMenuItem<int>(
                  value: quality,
                  child: Text('$quality'),
                );
              }).toList(),
              hint: Text('Seleccionar calidad de imagen'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _saveConfigValues();
                // Puedes agregar más lógica aquí si es necesario
                Navigator.pop(context); // Vuelve a la página anterior
              },
              child: Text('Guardar Configuración'),
            ),
          ],
        ),
      ),
    );
  }
}