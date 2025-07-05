import 'package:dartz/dartz.dart';
import 'package:cultura/core/usecase/usecase.dart';
import 'package:cultura/domain/auth/repository/auth.dart';
import 'package:cultura/domain/auth/usecases/no_params.dart';
import 'package:cultura/service_locator.dart';

class LoginWithGoogleUseCase implements UseCase<Either, NoParams> {
  @override
  Future<Either> call({NoParams? params}) async {
    return sl<AuthRepository>().loginWithGoogle();
  }
}
