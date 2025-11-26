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
          sl<TouristSpotBloc>()..add(GetSpotsByCurrentLocationEvent()),

      child: Scaffold(
        appBar: AppBar(title: const Text('Guia Turístico Inteligente')),
        body: const TouristSpotsBody(),
        floatingActionButton: const SearchButton(),
      ),
    );
  }
}

class TouristSpotsBody extends StatelessWidget {
  const TouristSpotsBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: BlocBuilder<TouristSpotBloc, TouristSpotState>(
        builder: (context, state) {
          if (state is TouristSpotLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is TouristSpotLoaded) {
            if (state.spots.isEmpty) {
              return const Center(
                child: Text(
                  'Nenhum local encontrado nesta região.\nTente aumentar o raio de busca!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
              );
            }
            return ListView.builder(
              itemCount: state.spots.length,
              itemBuilder: (context, index) {
                final spot = state.spots[index];
                return SpotCard(spot: spot);
              },
            );
          } else if (state is TouristSpotError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red, fontSize: 18),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      // Botão de tentar novamente
                      onPressed: () {
                        context.read<TouristSpotBloc>().add(
                          GetSpotsByCurrentLocationEvent(),
                        );
                      },
                      child: const Text('Tentar Novamente'),
                    ),
                  ],
                ),
              ),
            );
          }
          return const Center(child: Text('Inicializando GPS...'));
        },
      ),
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
          // Futuro: Ir para detalhes
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Imagem
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
                          child: const Icon(Icons.image_not_supported),
                        ),
                      )
                    : Container(
                        width: 80,
                        height: 80,
                        color: Colors.grey[300],
                        child: const Icon(Icons.location_on),
                      ),
              ),
              const SizedBox(width: 12),

              // 2. Textos e Informações
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Título e Nota
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
                        // 🆕 Exibe a nota se for maior que 0
                        if (spot.rating > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.amber[100],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.star,
                                  size: 14,
                                  color: Colors.amber,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  spot.rating.toStringAsFixed(1),
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

                    // 🆕 Descrição da IA (Resumo)
                    Text(
                      spot.description, // Agora é o texto gerado pela IA!
                      style: TextStyle(color: Colors.grey[700], fontSize: 13),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 6),

                    // Distância
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 12,
                          color: Colors.blue,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatDistance(spot.distance),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.blue,
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

  // Função auxiliar para formatar metros em Km
  String _formatDistance(double meters) {
    if (meters >= 1000) {
      return '${(meters / 1000).toStringAsFixed(1)} km';
    }
    return '${meters.toStringAsFixed(0)} m';
  }
}
