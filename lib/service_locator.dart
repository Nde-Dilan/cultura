import 'package:cultura/data/auth/repository/auth_repository_impl.dart';
import 'package:cultura/data/auth/source/auth_firebase_service.dart';
import 'package:cultura/domain/auth/repository/auth.dart';
import 'package:cultura/domain/auth/usecases/get_user.dart';
import 'package:cultura/domain/auth/usecases/google_login.dart';
import 'package:cultura/domain/auth/usecases/google_register.dart';
import 'package:cultura/domain/auth/usecases/siginup.dart';
import 'package:get_it/get_it.dart';
import 'package:cultura/domain/auth/usecases/signin.dart';

final sl = GetIt.instance;

Future<void> initializeDependencies() async {
  // Services

  sl.registerSingleton<AuthFirebaseService>(AuthFirebaseServiceImpl());

  // Repositories

  sl.registerSingleton<AuthRepository>(AuthRepositoryImpl());

  // Usecases
  sl.registerSingleton<SignupUseCase>(SignupUseCase());
  sl.registerSingleton<SigninUseCase>(SigninUseCase());
  sl.registerSingleton<GetUserUseCase>(GetUserUseCase());
  sl.registerSingleton<LoginWithGoogleUseCase>(LoginWithGoogleUseCase());
   sl.registerSingleton<SignupWithGoogleUseCase>(SignupWithGoogleUseCase());
 }
