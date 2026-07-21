import 'package:geolocator/geolocator.dart';

class LocationService {
  Future<Position?> obtenerUbicacion() async {
    try {
      // comprobar q gps este encendido
      bool servicioHabilitado = await Geolocator.isLocationServiceEnabled();

      if (!servicioHabilitado) {
        // aqui alerta para indicar q el gps no está habilitado
        return null;
      }

      // si la app tiene permisos para usar el GPS
      LocationPermission permiso = await Geolocator.checkPermission();

      if (permiso == LocationPermission.denied) {
        permiso = await Geolocator.requestPermission();
        if (permiso == LocationPermission.denied) {
          // otra alerta de negación de acceso al GPS
          return null;
        }
      }

      if (permiso == LocationPermission.deniedForever) {
        return null;
      }

      // obtener las coordenadas
      Position po = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      print('Coordenadas GPS');
      print('latitud ${po.latitude}');
      print('longitud ${po.longitude}');

      return po;
    } catch (e) {
      return null;
    }
  }
}
