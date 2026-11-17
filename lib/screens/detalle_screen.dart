
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/entrada.dart';

// Pantalla para consultar una entrada guardada
class DetalleScreen extends StatelessWidget {
  final Entrada entrada;

  const DetalleScreen({
    super.key,
    required this.entrada,
  });

  // Abrimos Google Maps con las coordenadas guardadas
  Future<void> abrirMapa(BuildContext context) async {
    try {

      final url = Uri.parse(
        'https://www.google.com/maps/search/'
            '?api=1&query=${entrada.latitud},${entrada.longitud}',
      );

      final abierto = await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      );

      if (!abierto) {
        throw Exception('No se pudo abrir el mapa');
      }

    } catch (error) {

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo abrir Google Maps'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        title: const Text('Detalle del diario'),
        backgroundColor: Colors.purple.shade100,
      ),

      // Permite desplazarse si el contenido es largo
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // Título de la entrada
            Text(
              entrada.titulo,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            // Fecha de la entrada
            Text(
              entrada.fecha,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 20),

            // Fotografía guardada
            if (entrada.rutaImagen != null)
              Hero(
                tag: 'imagen_${entrada.id}',
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.file(
                    File(entrada.rutaImagen!),
                    width: double.infinity,
                    height: 250,
                    fit: BoxFit.cover,
                    errorBuilder: (_, error, stackTrace) {
                      return const Center(
                        child: Text('Imagen no disponible'),
                      );
                    },
                  ),
                ),
              ),

            const SizedBox(height: 20),

            // Descripción del día
            Text(
              entrada.descripcion,
              style: const TextStyle(fontSize: 18),
            ),

            const SizedBox(height: 25),

            // Mostramos el botón si existe una ubicación
            if (entrada.latitud != null &&
                entrada.longitud != null)
              ElevatedButton.icon(
                onPressed: () => abrirMapa(context),
                icon: const Icon(Icons.location_on),
                label: const Text('Ver ubicación en Google Maps'),
              )
            else
              const Text('No hay ubicación guardada'),
          ],
        ),
      ),
    );
  }
}
