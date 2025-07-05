import 'package:dartz/dartz.dart';
import 'package:cultura/core/usecase/usecase.dart';
import 'package:cultura/data/auth/models/user_signin_req.dart';
import 'package:cultura/domain/auth/repository/auth.dart';
import 'package:cultura/service_locator.dart';

class SigninUseCase implements UseCase<Either, UserSigninReq> {
  @override
  Future<Either> call({UserSigninReq? params}) async {
    return sl<AuthRepository>().signin(params!);
  }
}
