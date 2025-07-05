import 'package:dartz/dartz.dart';
import 'package:cultura/core/usecase/usecase.dart';
import 'package:cultura/domain/auth/repository/auth.dart';
import 'package:cultura/service_locator.dart';

class GetUserUseCase implements UseCase<Either, dynamic> {
  @override
  Future<Either> call({dynamic params}) async {
    return await sl<AuthRepository>().getUser();
  }
}
