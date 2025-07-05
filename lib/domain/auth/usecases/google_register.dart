import 'package:dartz/dartz.dart';
import 'package:cultura/core/usecase/usecase.dart';
import 'package:cultura/domain/auth/repository/auth.dart';
import 'package:cultura/domain/auth/usecases/no_params.dart';
import 'package:cultura/service_locator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignupWithGoogleUseCase implements UseCase<Either, NoParams> {
  @override
  Future<Either> call({NoParams? params}) async {
    final result = await sl<AuthRepository>().signupWithGoogle();

    if (result.isRight()) {
      // Set onboarding flag for new users
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('has_completed_onboarding', false);
    }

    return result;
  }
}
