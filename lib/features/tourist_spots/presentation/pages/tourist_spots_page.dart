import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guia_turistico_inteligente/features/tourist_spots/presentation/bloc/tourist_spot_event.dart';
import 'package:guia_turistico_inteligente/features/tourist_spots/presentation/bloc/tourist_spot_state.dart';

import '../../../../injection_container.dart';
import '../../domain/entities/tourist_spot.dart';
import '../bloc/tourist_spot_bloc.dart';

class TouristSpotsPage extends StatelessWidget {
  const TouristSpotsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<TouristSpotBloc>(),
      child: Scaffold(
        appBar: AppBar(title: Text('Guia Turístico Inteligente')),
        body: buildBody(context),
        floatingActionButton: SearchButton(),
      ),
    );
  }

  Widget buildBody(BuildContext context) {
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
                  'Nenhum local encontrado nesta região.\nTente outro lugar!',
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
              child: Text(
                state.message,
                style: const TextStyle(color: Colors.red, fontSize: 18),
              ),
            );
          }
          return const Center(
            child: Text('Clique na lupa para buscar locais!'),
          );
        },
      ),
    );
  }
}

// Botão Flutuante que dispara o Evento
class SearchButton extends StatelessWidget {
  const SearchButton({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        // Coordenadas da Torre de Belém, Lisboa (Exemplo)
        // No futuro, pegaremos isso do GPS do celular
        context.read<TouristSpotBloc>().add(
          const GetNearbySpotsEvent(lat: 40.7580, lng: -73.9855),
        );
      },
      child: const Icon(Icons.search),
    );
  }
}

// Widget para exibir cada local (Card)
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
          // Exibe imagem ou ícone padrão se não tiver URL
          child: spot.imageUrl.isNotEmpty
              ? Image.network(
                  spot.imageUrl,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) =>
                      const Icon(Icons.image_not_supported),
                )
              : Container(
                  width: 60,
                  height: 60,
                  color: Colors.grey,
                  child: Icon(Icons.location_on),
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
