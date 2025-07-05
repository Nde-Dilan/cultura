import 'package:dartz/dartz.dart';
import 'package:cultura/data/auth/models/user.dart';
import 'package:cultura/data/auth/models/user_creation_req.dart';
import 'package:cultura/data/auth/models/user_signin_req.dart';
import 'package:cultura/data/auth/source/auth_firebase_service.dart';
import 'package:cultura/domain/auth/repository/auth.dart';
import 'package:cultura/service_locator.dart';

class AuthRepositoryImpl extends AuthRepository {
  @override
  Future<Either> signup(UserCreationReq user) async {
    return await sl<AuthFirebaseService>().signup(user);
  }

  @override
  Future<Either> loginWithGoogle() async {
    return await sl<AuthFirebaseService>().loginWithGoogle();
  }

   

  @override
  Future<Either> signupWithGoogle() async {
    return await sl<AuthFirebaseService>().signupWithGoogle();
  }

  

  @override
  Future<Either> signin(UserSigninReq user) async {
    return await sl<AuthFirebaseService>().signin(user);
  }

  @override
  Future<bool> isLoggedIn() async {
    return await sl<AuthFirebaseService>().isLoggedIn();
  }

  @override
  Future<Either> getUser() async {
    var user = await sl<AuthFirebaseService>().getUser();
    return user.fold(
      (error) {
        return Left(error);
      },
      (data) {
        return Right(UserModel.fromMap(data).toEntity());
      },
    );
  }

  @override
  Future<Either> logout() async {
    return await sl<AuthFirebaseService>().logout();
  }
}
