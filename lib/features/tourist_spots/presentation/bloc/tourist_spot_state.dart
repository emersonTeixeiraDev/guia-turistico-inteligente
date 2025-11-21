import 'package:equatable/equatable.dart';
import 'package:guia_turistico_inteligente/features/tourist_spots/domain/entities/tourist_spot.dart';

abstract class TouristSpotState extends Equatable {
  const TouristSpotState();

  @override
  List<Object> get props => [];
}

class TouristSpotInitial extends TouristSpotState {}

class TouristSpotLoading extends TouristSpotState {}

class TouristSpotLoaded extends TouristSpotState {
  final List<TouristSpot> spots;

  const TouristSpotLoaded({required this.spots});

  @override
  List<Object> get props => [spots];
}

class TouristSpotError extends TouristSpotState {
  final String message;

  const TouristSpotError({required this.message});

  @override
  List<Object> get props => [message];
}
