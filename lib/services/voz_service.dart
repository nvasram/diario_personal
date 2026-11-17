
import 'package:speech_to_text/speech_to_text.dart';

// Servicio para convertir la voz en texto
class VozService {
  final SpeechToText voz = SpeechToText();

  // Preparamos el reconocimiento de voz
  Future<bool> iniciar({
    required Function(String) alCambiarEstado,
    required Function(String) alError,
  }) async {
    return await voz.initialize(
      onStatus: alCambiarEstado,
      onError: (error) {
        alError(error.errorMsg);
      },
    );
  }

  // Comenzamos a escuchar al usuario
  Future<void> escuchar(Function(String) alReconocer) async {
    await voz.listen(
      listenOptions: SpeechListenOptions(
        localeId: 'es_MX',
      ),
      onResult: (resultado) {
        alReconocer(resultado.recognizedWords);
      },
    );
  }

  // Detenemos el reconocimiento de voz
  Future<void> detener() async {
    await voz.stop();
  }

  // Cancelamos el reconocimiento cuando ya no se necesita
  Future<void> cancelar() async {
    await voz.cancel();
  }

  // Consultamos si el micrófono está escuchando
  bool get escuchando => voz.isListening;
}
