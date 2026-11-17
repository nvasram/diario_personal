
import 'dart:io';
import 'package:flutter/material.dart';
import '../models/entrada.dart';
import '../services/database_helper.dart';

// Pantalla principal del diario
class InicioScreen extends StatefulWidget {
  const InicioScreen({super.key});

  @override
  State<InicioScreen> createState() => _InicioScreenState();
}

class _InicioScreenState extends State<InicioScreen> {

  late Future<List<Entrada>> entradas;

  // Cargamos las entradas al iniciar la pantalla
  @override
  void initState() {
    super.initState();
    cargarEntradas();
  }

  void cargarEntradas() {
    entradas = DatabaseHelper.instancia.obtenerEntradas();
  }

  // Abrimos el formulario y actualizamos la lista al regresar
  Future<void> nuevaEntrada() async {
    await Navigator.pushNamed(context, '/nueva');

    if (!mounted) return;

    setState(() {
      cargarEntradas();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        title: const Text('Diario Personal'),
        backgroundColor: Colors.purple.shade100,
      ),

      // Menú lateral de la aplicación
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.purple.shade100,
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.menu_book, size: 55),
                  SizedBox(height: 10),
                  Text(
                    'Mi diario personal',
                    style: TextStyle(fontSize: 22),
                  ),
                ],
              ),
            ),

            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Inicio'),
              onTap: () {
                Navigator.pop(context);
              },
            ),

            ListTile(
              leading: const Icon(Icons.add),
              title: const Text('Nueva entrada'),
              onTap: () {
                Navigator.pop(context);
                nuevaEntrada();
              },
            ),
          ],
        ),
      ),

      // Cargamos los datos de SQLite
      body: FutureBuilder<List<Entrada>>(
        future: entradas,
        builder: (context, snapshot) {

          // Mostramos un indicador mientras cargan los datos
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // Mostramos un mensaje si ocurre un error
          if (snapshot.hasError) {
            return const Center(
              child: Text('Error al cargar las entradas'),
            );
          }

          final lista = snapshot.data ?? [];

          // Mensaje cuando el diario está vacío
          if (lista.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.menu_book_outlined,
                    size: 80,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 15),
                  Text(
                    'Aún no tienes entradas',
                    style: TextStyle(fontSize: 20),
                  ),
                  SizedBox(height: 8),
                  Text('Agrega un recuerdo de tu día'),
                ],
              ),
            );
          }

          // Mostramos las entradas en una lista
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: lista.length,
            itemBuilder: (context, index) {

              final entrada = lista[index];

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(

                  // Imagen con animación Hero
                  leading: entrada.rutaImagen != null
                      ? Hero(
                    tag: 'imagen_${entrada.id}',
                    child: Image.file(
                      File(entrada.rutaImagen!),
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (_, error, stackTrace) {
                        return const Icon(Icons.broken_image);
                      },
                    ),
                  )
                      : const Icon(
                    Icons.menu_book,
                    size: 40,
                  ),

                  title: Text(entrada.titulo),
                  subtitle: Text(entrada.fecha),
                  trailing: const Icon(Icons.chevron_right),

                  // Abrimos el detalle de la entrada
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/detalle',
                      arguments: entrada,
                    );
                  },
                ),
              );
            },
          );
        },
      ),

      // Botón para agregar una entrada
      floatingActionButton: FloatingActionButton.extended(
        onPressed: nuevaEntrada,
        icon: const Icon(Icons.add),
        label: const Text('Nueva entrada'),
      ),
    );
  }
}
