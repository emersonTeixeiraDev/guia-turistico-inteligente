import '../../domain/entities/tourist_spot.dart';

class TouristSpotModel extends TouristSpot {
  const TouristSpotModel({
    required super.id,
    required super.name,
    required super.description,
    required super.imageUrl,
    required super.latitude,
    required super.longitude,
    required super.distance,
  });

  // Fábrica específica para o JSON da Overpass API
  factory TouristSpotModel.fromOverpassJson(Map<String, dynamic> json) {
    // Os dados úteis ficam dentro de 'tags'
    final tags = json['tags'] ?? {};

    return TouristSpotModel(
      id: json['id'].toString(),
      name: tags['name'] ?? 'Ponto Turístico (Sem Nome)',
      description: tags['tourism'] != null
          ? 'Tipo: ${tags['tourism']}'
          : 'Local histórico ou turístico.',

      // A Overpass NÃO fornece imagens. Deixamos vazio e a UI mostrará um ícone.
      imageUrl: '',

      latitude: (json['lat'] ?? 0.0).toDouble(),
      longitude: (json['lon'] ?? 0.0).toDouble(),
      distance:
          0, // A API não calcula distância, teríamos que calcular na mão (Geolocator)
    );
  }
}
