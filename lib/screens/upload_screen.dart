import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/upload_service.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  // Instancias del selector de imágenes y del servicio de subida
  final ImagePicker _picker = ImagePicker();
  final UploadService _uploadService = UploadService();

  // Variables de estado
  XFile? _selectedImage;
  bool _isUploading = false;
  Map<String, dynamic>? _serverResponse;
  String? _uploadedImageUrl;

  /// Método para seleccionar una imagen (cámara o galería)
  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 85, // Optimización de tamaño de imagen
      );

      if (image != null) {
        setState(() {
          _selectedImage = image;
          _serverResponse = null; // Limpiar respuesta previa
          _uploadedImageUrl = null; // Limpiar URL previa al cambiar imagen
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Imagen seleccionada con éxito'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('Error al seleccionar imagen: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al seleccionar la imagen: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Método para subir la imagen seleccionada al servidor
  Future<void> _uploadImage() async {
    if (_selectedImage == null) return;

    setState(() {
      _isUploading = true;
      _serverResponse = null;
    });

    final response = await _uploadService.uploadImage(_selectedImage!.path);

    setState(() {
      _isUploading = false;
      _serverResponse = response;
      if (response != null) {
        // Obtenemos la URL devuelta por el servidor (o simulamos una de Lorem Picsum si no existe la llave)
        _uploadedImageUrl = response['url'] ?? response['location'] ?? 'https://picsum.photos/id/237/800/600';
      }
    });

    if (response != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Archivo subido exitosamente al servidor!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al subir el archivo al servidor'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Subida de Archivos'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Cabecera explicativa para clase
            const Text(
              'Ejemplo Clase: Subir Archivo (Imagen)',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Selecciona una imagen de la galería o toma una foto para visualizarla localmente y luego subirla.',
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // 2. Área de previsualización de la imagen
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Container(
                height: 280,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: _uploadedImageUrl != null
                    ? Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              _uploadedImageUrl!,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return const Center(child: CircularProgressIndicator());
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return const Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.error_outline, color: Colors.red, size: 48),
                                      SizedBox(height: 8),
                                      Text('Error al cargar la imagen desde la URL'),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.85),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.cloud_done, color: Colors.white, size: 16),
                                  SizedBox(width: 4),
                                  Text(
                                    'Desde URL (Servidor)',
                                    style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      )
                    : _selectedImage != null
                        ? Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.file(
                                  File(_selectedImage!.path),
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                ),
                              ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.orange.withOpacity(0.85),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.insert_drive_file, color: Colors.white, size: 16),
                                      SizedBox(width: 4),
                                      Text(
                                        'Vista Local',
                                        style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          )
                        : const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.image_outlined,
                                size: 80,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Ninguna imagen seleccionada',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
              ),
            ),
            const SizedBox(height: 20),

            // Mostrar URL pública seleccionable si ya se subió
            if (_uploadedImageUrl != null) ...[
              Text(
                'URL pública de la imagen (Servidor):',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 4),
              SelectableText(
                _uploadedImageUrl!,
                style: const TextStyle(
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 16),
            ],

            // 3. Botones para Seleccionar Imagen (Origen)
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Cámara'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Galería'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 4. Botón de Subida
            if (_isUploading)
              const Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 12),
                    Text('Subiendo archivo al servidor...'),
                  ],
                ),
              )
            else
              ElevatedButton.icon(
                onPressed: _selectedImage != null ? _uploadImage : null,
                icon: const Icon(Icons.cloud_upload),
                label: const Text('Subir al Servidor'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            
            // 5. Mostrar la respuesta de httpbin.org si existe
            if (_serverResponse != null) ...[
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 12),
              const Text(
                'Respuesta del Servidor (Echo):',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Text(
                    const JsonEncoder.withIndent('  ').convert({
                      'headers': _serverResponse!['headers'],
                      'files': _serverResponse!['files'], // Aquí se ve el archivo recibido
                      'form': _serverResponse!['form'],   // Aquí se ven los parámetros extras
                    }),
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                      color: Colors.lightGreenAccent,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
