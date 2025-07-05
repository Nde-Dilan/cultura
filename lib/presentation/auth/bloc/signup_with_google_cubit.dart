import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cultura/domain/auth/usecases/google_register.dart';
import 'package:cultura/presentation/auth/bloc/signup_with_google.dart';
import 'package:cultura/service_locator.dart';

class SignupWithGoogleCubit extends Cubit<SignupWithGoogleState> {
  SignupWithGoogleCubit() : super(SignupWithGoogleInitial());

  Future<void> signUpWithGoogle() async {
    emit(SignupWithGoogleLoading());
    try {
      final result = await sl<SignupWithGoogleUseCase>().call();

      result.fold(
        (failure) => emit(SignupWithGoogleError(failure.toString())),
        (success) => emit(SignupWithGoogleSuccess(success.toString())),
      );
    } catch (e) {
      emit(SignupWithGoogleError(e.toString()));
    }
  }
}
