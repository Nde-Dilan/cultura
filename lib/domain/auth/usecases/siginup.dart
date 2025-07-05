import 'package:dartz/dartz.dart';
import 'package:cultura/core/usecase/usecase.dart';
import 'package:cultura/data/auth/models/user_creation_req.dart';
import 'package:cultura/domain/auth/repository/auth.dart';
import 'package:cultura/service_locator.dart';

class SignupUseCase implements UseCase<Either, UserCreationReq> {
  @override
  Future<Either> call({UserCreationReq? params}) async {
    return await sl<AuthRepository>().signup(params!);
  }
}
