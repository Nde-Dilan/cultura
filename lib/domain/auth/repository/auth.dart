import 'package:dartz/dartz.dart';
import 'package:cultura/data/auth/models/user_creation_req.dart';
import 'package:cultura/data/auth/models/user_signin_req.dart';

abstract class AuthRepository {
  Future<Either> signup(UserCreationReq user);
  Future<Either> signin(UserSigninReq user);
  Future<Either> logout();

  Future<Either> loginWithGoogle();
 
  Future<Either> signupWithGoogle();
 
  Future<bool> isLoggedIn();
  Future<Either> getUser();
}
