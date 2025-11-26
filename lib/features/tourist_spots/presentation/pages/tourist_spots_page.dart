import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../injection_container.dart';
import '../../domain/entities/tourist_spot.dart';
import '../bloc/tourist_spot_bloc.dart';
import '../bloc/tourist_spot_event.dart';
import '../bloc/tourist_spot_state.dart';

class TouristSpotsPage extends StatelessWidget {
  const TouristSpotsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          sl<TouristSpotBloc>()
            ..add(const GetSpotsByCurrentLocationEvent(radiusKm: 2)),

      child: Scaffold(
        appBar: AppBar(title: const Text('Guia Turístico Inteligente')),
        body: const TouristSpotsBody(),
        floatingActionButton: const SearchButton(),
      ),
    );
  }
}

class TouristSpotsBody extends StatefulWidget {
  const TouristSpotsBody({super.key});

  @override
  State<TouristSpotsBody> createState() => _TouristSpotsBodyState();
}

class _TouristSpotsBodyState extends State<TouristSpotsBody> {
  // Começa visualmente em 2km para bater com a busca inicial
  double _currentRadius = 2.0;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TouristSpotBloc, TouristSpotState>(
      builder: (context, state) {
        if (state is TouristSpotLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is TouristSpotLoaded) {
          // CASO 1: LISTA VAZIA -> MOSTRA O SLIDER
          if (state.spots.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.travel_explore,
                      size: 80,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Nada encontrado num raio de ${_currentRadius.toInt()} km.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Tente expandir a busca:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),

                    // 🎚️ O Slider só aparece aqui
                    Slider(
                      value: _currentRadius,
                      min: 2, // Mínimo exigido
                      max: 50,
                      divisions: 48,
                      label: '${_currentRadius.toInt()} km',
                      activeColor: Colors.blue,
                      onChanged: (value) {
                        setState(() {
                          _currentRadius = value;
                        });
                      },
                      onChangeEnd: (value) {
                        // Dispara nova busca com o raio novo
                        context.read<TouristSpotBloc>().add(
                          GetSpotsByCurrentLocationEvent(radiusKm: value),
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          }

          // CASO 2: TEM ITENS -> MOSTRA SÓ A LISTA (Slider some)
          return Column(
            children: [
              // Um pequeno aviso discreto de qual raio foi usado (opcional, boa UX)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Mostrando locais em um raio de ${_currentRadius.toInt()} km',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: state.spots.length,
                  itemBuilder: (context, index) {
                    return SpotCard(spot: state.spots[index]);
                  },
                ),
              ),
            ],
          );
        } else if (state is TouristSpotError) {
          // Em caso de erro, mostramos o botão de tentar de novo
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 60, color: Colors.red),
                  const SizedBox(height: 10),
                  Text(
                    state.message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red, fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      context.read<TouristSpotBloc>().add(
                        // Tenta de novo com o raio atual
                        GetSpotsByCurrentLocationEvent(
                          radiusKm: _currentRadius,
                        ),
                      );
                    },
                    child: const Text('Tentar Novamente'),
                  ),
                ],
              ),
            ),
          );
        }
        return const SizedBox();
      },
    );
  }
}

class SearchButton extends StatelessWidget {
  const SearchButton({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        context.read<TouristSpotBloc>().add(GetSpotsByCurrentLocationEvent());
      },
      child: const Icon(Icons.my_location),
    );
  }
}

class SpotCard extends StatelessWidget {
  final TouristSpot spot;

  const SpotCard({super.key, required this.spot});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          // Futuramente aqui vai para a tela de detalhes
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Imagem do Local
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: spot.imageUrl.isNotEmpty
                    ? Image.network(
                        spot.imageUrl,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stack) => Container(
                          width: 80,
                          height: 80,
                          color: Colors.grey[300],
                          child: const Icon(
                            Icons.broken_image,
                            color: Colors.grey,
                          ),
                        ),
                      )
                    : Container(
                        width: 80,
                        height: 80,
                        color: Colors.grey[300],
                        child: const Icon(
                          Icons.location_on,
                          color: Colors.grey,
                        ),
                      ),
              ),
              const SizedBox(width: 12),

              // 2. Informações (Texto)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Linha do Título e da Nota
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            spot.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),

                        // ⭐ AQUI ESTÁ A NOTA!
                        if (spot.rating > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.amber[100], // Fundo amarelinho
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.star,
                                  size: 14,
                                  color: Colors.amber,
                                ), // Estrela
                                const SizedBox(width: 4),
                                Text(
                                  spot.rating.toStringAsFixed(1), // Ex: "4.8"
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 4),

                    // Descrição Inteligente (IA)
                    Text(
                      spot.description,
                      style: TextStyle(color: Colors.grey[700], fontSize: 13),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 6),

                    // Distância Real
                    Row(
                      children: [
                        const Icon(
                          Icons.directions_walk,
                          size: 14,
                          color: Colors.blue,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatDistance(spot.distance),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.blue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Funçãozinha auxiliar para deixar a distância bonita (km ou m)
  String _formatDistance(double meters) {
    if (meters >= 1000) {
      return '${(meters / 1000).toStringAsFixed(1)} km';
    }
    return '${meters.toStringAsFixed(0)} m';
  }
}
