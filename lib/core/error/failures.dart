import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final List<dynamic> properties;
  const Failure([this.properties = const <dynamic>[]]);

  @override
  List<Object> get props => [properties];
}

// Falha genérica de Servidor (API 500, 404, etc)
class ServerFailure extends Failure {}

class ServerException extends Failure {}

// Falha de Cache/Banco Local
class CacheFailure extends Failure {}

// Falha de Conexão
class OfflineFailure extends Failure {}
