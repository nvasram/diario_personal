
import 'package:geolocator/geolocator.dart';

// Servicio para obtener la ubicación del usuario
class UbicacionService {

  Future<Position> obtenerUbicacion() async {

    // Revisamos si el GPS está activado
    bool gpsActivo = await Geolocator.isLocationServiceEnabled();

    if (!gpsActivo) {
      throw Exception('Activa la ubicación del dispositivo');
    }

    // Revisamos los permisos de ubicación
    LocationPermission permiso =
    await Geolocator.checkPermission();

    // Solicitamos permiso si todavía no lo tenemos
    if (permiso == LocationPermission.denied) {
      permiso = await Geolocator.requestPermission();
    }

    // Verificamos si el usuario rechazó el permiso
    if (permiso == LocationPermission.denied ||
        permiso == LocationPermission.deniedForever) {
      throw Exception('No se concedió el permiso de ubicación');
    }

    // Obtenemos las coordenadas actuales
    return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 20),
      ),
    );
  }
}
