import 'package:dartz/dartz.dart';
import '../error/failures.dart';

abstract class UseCases<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

class NoParams {}
