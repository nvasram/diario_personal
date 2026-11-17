
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

// Servicio para tomar fotos o seleccionar imágenes
class ImagenService {
  final ImagePicker picker = ImagePicker();

  // Obtenemos una imagen desde la cámara o galería
  Future<String?> seleccionarImagen(ImageSource origen) async {
    final imagen = await picker.pickImage(
      source: origen,
      imageQuality: 80,
    );

    // Si el usuario cancela, no guardamos nada
    if (imagen == null) {
      return null;
    }

    // Obtenemos una carpeta permanente de la aplicación
    final directorio = await getApplicationDocumentsDirectory();

    final nombre = '${DateTime.now().millisecondsSinceEpoch}'
        '${path.extension(imagen.path)}';

    final nuevaRuta = path.join(directorio.path, nombre);

    // Copiamos la imagen para que no se pierda
    final archivo = await File(imagen.path).copy(nuevaRuta);

    return archivo.path;
  }
}
