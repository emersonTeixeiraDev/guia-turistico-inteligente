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
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 4,
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: spot.imageUrl.isNotEmpty
              ? Image.network(
                  spot.imageUrl,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stack) =>
                      const Icon(Icons.image_not_supported),
                )
              : Container(
                  width: 60,
                  height: 60,
                  color: Colors.grey,
                  child: const Icon(Icons.location_on),
                ),
        ),
        title: Text(
          spot.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('${spot.distance.toStringAsFixed(0)}m de distância'),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      ),
    );
  }
}
