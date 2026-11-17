
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/entrada.dart';
import '../services/database_helper.dart';
import '../services/imagen_service.dart';
import '../services/ubicacion_service.dart';
import '../services/voz_service.dart';

// Pantalla para crear una entrada del diario
class NuevaEntradaScreen extends StatefulWidget {
  const NuevaEntradaScreen({super.key});

  @override
  State<NuevaEntradaScreen> createState() =>
      _NuevaEntradaScreenState();
}

class _NuevaEntradaScreenState
    extends State<NuevaEntradaScreen> {

  // Controladores de los campos de texto
  final tituloController = TextEditingController();
  final descripcionController = TextEditingController();

  // Servicios que utilizaremos
  final imagenService = ImagenService();
  final ubicacionService = UbicacionService();
  final vozService = VozService();

  String? rutaImagen;
  bool escuchando = false;
  bool guardando = false;
  String textoAnterior = '';

  // Mostramos mensajes al usuario
  void mostrarMensaje(String mensaje) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje)),
    );
  }

  // Seleccionamos una imagen desde la cámara o galería
  Future<void> seleccionarImagen(ImageSource origen) async {
    try {
      final ruta = await imagenService.seleccionarImagen(origen);

      if (!mounted) return;

      if (ruta != null) {
        setState(() {
          rutaImagen = ruta;
        });
      }
    } catch (error) {
      mostrarMensaje('No se pudo obtener la imagen');
    }
  }

  // Activamos o detenemos el dictado por voz
  Future<void> activarMicrofono() async {
    try {
      if (escuchando) {
        await vozService.detener();

        if (!mounted) return;

        setState(() {
          escuchando = false;
        });

        return;
      }

      final disponible = await vozService.iniciar(
        alCambiarEstado: (estado) {
          if (!mounted) return;

          setState(() {
            escuchando = estado == 'listening';
          });
        },
        alError: (error) {
          if (!mounted) return;

          setState(() {
            escuchando = false;
          });

          // Mostramos el error específico del micrófono
          mostrarMensaje('Error de voz: $error');
        },
      );

      if (!mounted) return;

      if (!disponible) {
        mostrarMensaje(
          'El reconocimiento de voz no está disponible',
        );
        return;
      }

      // Conservamos el texto que ya escribió el usuario
      textoAnterior = descripcionController.text.trim();

      await vozService.escuchar((texto) {
        if (!mounted) return;

        descripcionController.text = textoAnterior.isEmpty
            ? texto
            : '$textoAnterior $texto';

        descripcionController.selection =
            TextSelection.collapsed(
              offset: descripcionController.text.length,
            );
      });

    } catch (error) {
      mostrarMensaje('No se pudo activar el micrófono');
    }
  }

  // Guardamos la entrada en SQLite
  Future<void> guardarEntrada() async {

    // Validamos que los campos no estén vacíos
    if (tituloController.text.trim().isEmpty ||
        descripcionController.text.trim().isEmpty) {
      mostrarMensaje('Completa el título y la descripción');
      return;
    }

    setState(() {
      guardando = true;
    });

    try {

      // Detenemos el micrófono antes de guardar
      await vozService.detener();

      double? latitud;
      double? longitud;

      // Intentamos obtener la ubicación actual
      try {
        final posicion =
        await ubicacionService.obtenerUbicacion();

        latitud = posicion.latitude;
        longitud = posicion.longitude;

      } catch (error) {
        mostrarMensaje(
          'No se pudo obtener la ubicación. '
              'La entrada se guardará sin GPS.',
        );
      }

      if (!mounted) return;

      // Obtenemos la fecha actual
      final hoy = DateTime.now();
      final fecha = '${hoy.day}/${hoy.month}/${hoy.year}';

      // Creamos una entrada con los datos del formulario
      final entrada = Entrada(
        titulo: tituloController.text.trim(),
        descripcion: descripcionController.text.trim(),
        fecha: fecha,
        rutaImagen: rutaImagen,
        latitud: latitud,
        longitud: longitud,
      );

      // Guardamos los datos en la base de datos
      await DatabaseHelper.instancia.guardarEntrada(entrada);

      if (!mounted) return;

      mostrarMensaje('Entrada guardada correctamente');

      // Regresamos a la pantalla principal
      Navigator.pop(context, true);

    } catch (error) {
      mostrarMensaje('Error al guardar la entrada');

    } finally {
      if (mounted) {
        setState(() {
          guardando = false;
        });
      }
    }
  }

  // Liberamos los recursos al cerrar la pantalla
  @override
  void dispose() {
    vozService.cancelar();
    tituloController.dispose();
    descripcionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        title: const Text('Nueva entrada'),
        backgroundColor: Colors.purple.shade100,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [

            // Campo para escribir el título
            TextField(
              controller: tituloController,
              decoration: const InputDecoration(
                labelText: 'Título',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.edit),
              ),
            ),

            const SizedBox(height: 20),

            // Campo para escribir la descripción
            TextField(
              controller: descripcionController,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: '¿Qué hiciste hoy?',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),

            // Botón para dictar por voz
            OutlinedButton.icon(
              onPressed: guardando ? null : activarMicrofono,
              icon: Icon(
                escuchando ? Icons.mic_off : Icons.mic,
              ),
              label: Text(
                escuchando
                    ? 'Detener dictado'
                    : 'Dictar por voz',
              ),
            ),

            const SizedBox(height: 20),

            // Mostramos la fotografía seleccionada
            if (rutaImagen != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  File(rutaImagen!),
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              )
            else
              Container(
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.image_outlined,
                  size: 60,
                  color: Colors.grey,
                ),
              ),

            const SizedBox(height: 12),

            // Botones de cámara y galería
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: guardando
                        ? null
                        : () => seleccionarImagen(
                      ImageSource.camera,
                    ),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Cámara'),
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: guardando
                        ? null
                        : () => seleccionarImagen(
                      ImageSource.gallery,
                    ),
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Galería'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Información sobre la ubicación
            const ListTile(
              leading: Icon(Icons.location_on),
              title: Text('Ubicación GPS'),
              subtitle: Text(
                'Se obtendrá automáticamente al guardar',
              ),
            ),

            const SizedBox(height: 20),

            // Botón para guardar la entrada
            ElevatedButton.icon(
              onPressed: guardando ? null : guardarEntrada,
              icon: guardando
                  ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              )
                  : const Icon(Icons.save),
              label: Text(
                guardando
                    ? 'Guardando...'
                    : 'Guardar entrada',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
