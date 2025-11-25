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
    super.rating,
  });

  // Fábrica específica para o JSON da Overpass API
  factory TouristSpotModel.fromOverpassJson(Map<String, dynamic> json) {
    final tags = json['tags'] ?? {};

    String category = 'tourist_attraction';
    String displayType = 'Ponto Turístico';

    if (tags.containsKey('tourism')) {
      category = tags['tourism'];
      displayType = 'Turismo (${tags['tourism']})';
    } else if (tags.containsKey('historic')) {
      category = 'historical_site';
      displayType = 'Histórico (${tags['historic']})';
    } else if (tags.containsKey('natural')) {
      category = tags['natural'];
      displayType = 'Natureza (${tags['natural']})';
    } else if (tags.containsKey('religion')) {
      category = 'cathedral';
      displayType = 'Religioso (${tags['religion']})';
    }

    category = category.replaceAll('_', ' ');

    return TouristSpotModel(
      id: json['id'].toString(),
      name: tags['name'] ?? 'Local Interessante',
      description:
          displayType, // Descrição provisória (será substituída pela IA)
      imageUrl:
          'https://loremflickr.com/400/400/$category?random=${json['id']}',
      latitude: (json['lat'] ?? 0.0).toDouble(),
      longitude: (json['lon'] ?? 0.0).toDouble(),
      distance: 0,
      rating: 0.0, // Começa com 0 até a IA analisar
    );
  }

  // Permite alterar valores específicos mantendo o resto igual
  TouristSpotModel copyWith({
    String? name,
    String? description,
    String? imageUrl,
    double? rating,
  }) {
    return TouristSpotModel(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      latitude: latitude,
      longitude: longitude,
      distance: distance,
      rating: rating ?? this.rating,
    );
  }
}
