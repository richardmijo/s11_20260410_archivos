class UploadService {
  /// Sube un archivo de imagen al servidor.
  /// [filePath] es la ruta local del archivo en el dispositivo.
  /// 
  /// TODO: Implementar esta lógica con los estudiantes en clase usando la librería 'dio'.
  Future<Map<String, dynamic>?> uploadImage(String filePath) async {
    print('Simulación de subida iniciada (Dio) para: $filePath');

    // Simulamos un retraso de red de 2 segundos para ver el spinner de carga en la UI.
    await Future.delayed(const Duration(seconds: 2));

    // Retornamos una respuesta simulada con la estructura que se espera ver en pantalla.
    // Esto evita errores en la UI antes de implementar la llamada real con Dio.
    return {
      'headers': {
        'Content-Type': 'multipart/form-data; boundary=...',
        'User-Agent': 'Flutter Class Client (Simulated - Dio)'
      },
      'files': {
        'file': filePath.split('/').last, // Nombre del archivo simulado
      },
      'url': 'https://picsum.photos/id/237/800/600', // URL simulada de red para visualización
      'form': {
        'description': 'Simulado - Implementar Dio FormData en clase',
        'uploaded_at': DateTime.now().toIso8601String(),
      }
    };
  }
}
