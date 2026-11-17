
// Modelo que representa una entrada del diario
class Entrada {
  final int? id;
  final String titulo;
  final String descripcion;
  final String fecha;
  final String? rutaImagen;
  final double? latitud;
  final double? longitud;

  // Constructor para crear una entrada
  Entrada({
    this.id,
    required this.titulo,
    required this.descripcion,
    required this.fecha,
    this.rutaImagen,
    this.latitud,
    this.longitud,
  });

  // Convertimos la entrada en un mapa para guardarla en SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'titulo': titulo,
      'descripcion': descripcion,
      'fecha': fecha,
      'rutaImagen': rutaImagen,
      'latitud': latitud,
      'longitud': longitud,
    };
  }

  // Convertimos los datos de SQLite en una entrada
  factory Entrada.fromMap(Map<String, dynamic> map) {
    return Entrada(
      id: map['id'] as int?,
      titulo: map['titulo'] as String,
      descripcion: map['descripcion'] as String,
      fecha: map['fecha'] as String,
      rutaImagen: map['rutaImagen'] as String?,
      latitud: (map['latitud'] as num?)?.toDouble(),
      longitud: (map['longitud'] as num?)?.toDouble(),
    );
  }
}
