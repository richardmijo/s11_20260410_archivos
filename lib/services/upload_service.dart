import 'package:minio/io.dart';
import 'package:minio/minio.dart';

class UploadService {
  // pantron singleton

  final Minio _minio = Minio(
    endPoint: 's3.uidehub.tech',
    accessKey: 'admin_uidehub',
    secretKey: 'gOggAJFliVtNFlX7aibcb/MCaVrpN/cQtLkUMPLaUlU=',
    useSSL: true,
  );

  static const String _bucketName = 'lojago';

  // subir la imagen a minio
  Future<Map<String, dynamic>?> uploadImage(String filePath) async {
    try {
      final String fileName =
          '${DateTime.now().microsecondsSinceEpoch}_${filePath.split('/').last}';
      // /home/images/nomrbre.jpg

      // subir imagen
      await _minio.fPutObject(_bucketName, fileName, filePath);

      print('Imagen subida a MinIO');

      // url de la imagen para consumo
      final String fileUrl = await _minio.presignedGetObject(
        _bucketName,
        fileName,
        expires: 3600,
      );

      return {'url': fileUrl, 'fileName': fileName, 'bucket': _bucketName};
    } catch (e) {
      print('Erro durante la subida de la imange a MinIo: $e');
      return null;
    }
  }

  Future<String> getImageUrl(String fileName) async {
    // url de la imagen para consumo
    return await _minio.presignedGetObject(
      _bucketName,
      fileName,
      expires: 86400,
    );
  }

  // otros métodos
  Future<String> getOtrosMetodos(String fileName) async {
    _minio.makeBucket('nombre_bucket');

    _minio.bucketExists('nombre_a_comprobar');

    _minio.removeBucket('');

    _minio.fGetObject(
      _bucketName,
      'nombre_archivo.jpg',
      'lugar_a_guardar_en_dispotivo',
    );

    return await _minio.presignedGetObject(
      _bucketName,
      fileName,
      expires: 86400,
    );
  }
}
