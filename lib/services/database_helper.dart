
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/entrada.dart';

// Clase encargada de manejar la base de datos
class DatabaseHelper {

  // Utilizamos una sola instancia de la base de datos
  static final DatabaseHelper instancia = DatabaseHelper._();

  DatabaseHelper._();

  Database? _database;

  // Abrimos la base de datos cuando sea necesario
  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await iniciarDatabase();
    return _database!;
  }

  // Creamos la base de datos y la tabla de entradas
  Future<Database> iniciarDatabase() async {
    final ruta = join(
      await getDatabasesPath(),
      'diario.db',
    );

    return await openDatabase(
      ruta,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE entradas (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            titulo TEXT NOT NULL,
            descripcion TEXT NOT NULL,
            fecha TEXT NOT NULL,
            rutaImagen TEXT,
            latitud REAL,
            longitud REAL
          )
        ''');
      },
    );
  }

  // Guardamos una nueva entrada
  Future<int> guardarEntrada(Entrada entrada) async {
    final db = await database;

    return await db.insert(
      'entradas',
      entrada.toMap(),
    );
  }

  // Consultamos todas las entradas guardadas
  Future<List<Entrada>> obtenerEntradas() async {
    final db = await database;

    final resultado = await db.query(
      'entradas',
      orderBy: 'id DESC',
    );

    return resultado.map((map) {
      return Entrada.fromMap(map);
    }).toList();
  }
}
