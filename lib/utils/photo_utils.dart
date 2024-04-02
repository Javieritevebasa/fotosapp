import 'package:flutter/material.dart';
import 'package:fotosapp/coche.dart';
import 'package:fotosapp/main.dart';
import 'package:ftpconnect/ftpconnect.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:image/image.dart' as ui;
import 'package:flutter_exif_plugin/flutter_exif_plugin.dart' as exif;
class PhotoUtils {
  static Future<String?> takePhoto(String customName) async {
  try {
    await requestPermissions(); // Solicitar permisos antes de continuar

    SharedPreferences prefs = await SharedPreferences.getInstance();
    final ImagePicker _imagePicker = ImagePicker();
    final XFile? pickedFile = await _imagePicker.pickImage(
      source: ImageSource.camera,
      imageQuality: prefs.getInt('quality') ?? 50,
    );

    if (pickedFile != null) {
      // Obtener la ubicación actual
      final Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Obtener el directorio de documentos de la aplicación
      final String appDocPath =  "/storage/emulated/0/Download";

      // Construir la ruta del archivo existente con el nombre personalizado
      final String existingPath = '$appDocPath/$customName.jpg';

      // Comprobar si ya existe un archivo con el mismo nombre
      final File existingFile = File(existingPath);
      if (existingFile.existsSync()) {
        // Si existe, eliminarlo
        existingFile.deleteSync();
      }

      // Obtener los datos EXIF de la imagen
      final exifData = await exif.FlutterExif.fromPath(pickedFile.path);

      // Establecer la ubicación en los datos EXIF
      await exifData.setLatLong(position.latitude, position.longitude);
      // Guardar los cambios en los metadatos EXIF
      await exifData.saveAttributes();

      // Construir la nueva ruta con el nombre personalizado
      final String newPath = '$appDocPath/$customName.jpg';

      // Copiar y renombrar el archivo
      final File renamedFile = await File(pickedFile.path).copy(newPath);

      // Agregar marca de agua
      DateTime now = DateTime.now();
      int year = now.year;
      int month = now.month;
      int day = now.day;
      int hour = now.hour;
      int minute = now.minute;
      int second = now.second;
      ui.Image? originalImage = ui.decodeImage(renamedFile.readAsBytesSync());

      // Marca de agua
      String waterMarkText = '$year-$month-$day $hour:$minute:$second';
      ui.drawString(
        originalImage!,
        ui.arial_48,
        10,
        (originalImage.height - 150),
        color: 0xffb74093,
        waterMarkText,
      );
      File(renamedFile.path).writeAsBytesSync(ui.encodeJpg(originalImage));

      // Devolver la nueva ruta del archivo
      return renamedFile.path;
    } else {
      // Si no se seleccionó ninguna imagen
      return null;
    }
  } catch (e) {
    // Manejar errores al tomar la foto
    print("Error al tomar la foto: $e");
    return null;
  }
}



  static Future<void> requestPermissions() async {
    final plugin = DeviceInfoPlugin();
    final android = await plugin.androidInfo;

    final storageStatus = android.version.sdkInt < 33
        ? await Permission.storage.request()
        : PermissionStatus.granted;

    if (storageStatus == PermissionStatus.granted) {
      print("granted");
    }
    if (storageStatus == PermissionStatus.denied) {
      print("denied");
    }
    if (storageStatus == PermissionStatus.permanentlyDenied) {
      openAppSettings();
    }
    var cameraStatus = await Permission.camera.request();
    var locationStatus = await Permission.location.request();

    if (!(cameraStatus.isGranted &&
        locationStatus.isGranted &&
        storageStatus.isGranted)) {
      // Puedes mostrar un mensaje al usuario o realizar alguna acción si los permisos son denegados.
      print(
          'Se han denegado los permisos de cámara, ubicación o almacenamiento.');
      // Puedes decidir si lanzar una excepción, mostrar un mensaje, o realizar alguna otra acción.
      throw Exception('Permisos denegados');
    }
  }

  static Future<void> enviarYEliminar(Coche coche, BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    final FTPConnect ftpConnect = FTPConnect(
      prefs.getString('ip') ?? '',
      user: prefs.getString('user') ?? '',
      pass: prefs.getString('password') ?? '',
    );
    await ftpConnect.connect();

    try {
      showDialog(
          context: context,
          builder: (context) {
            return const Center(child: CircularProgressIndicator());
          });
      await ftpConnect.changeDirectory('/fotos/');
      List<String> imagePaths = [
        coche.vehiculo!,
       
      ];      

      for (String imagePath in imagePaths) {
        final File imageFile = File(imagePath);

        // Subir la imagen al servidor FTP
        await ftpConnect.uploadFile(
          imageFile,
        );

        // Eliminar la imagen local después de subirla al servidor
        await imageFile.delete();
      }
    } catch (e) {
      print('Error al enviar las imágenes por FTP: $e');
    } finally {
      await ftpConnect.disconnect();
      Navigator.push(context, MaterialPageRoute(builder: (context) => MyApp()));
    }
  }
}
