import 'package:logging/logging.dart';
import 'package:cultura/domain/auth/usecases/get_user.dart';
import 'package:cultura/presentation/main/bloc/display_user_info_state.dart';
import 'package:cultura/service_locator.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

Logger _log = Logger('DisplayInfoCubit.dart');

class UserInfoDisplayCubit extends Cubit<UserInfoDisplayState> {
  UserInfoDisplayCubit() : super(UserInfoLoading());

  void displayUserInfo() async {
    _log.info("Inside the display function: ");
    var returnedData = await sl<GetUserUseCase>().call();

    _log.info("Here's the returned data: $returnedData");
    returnedData.fold(
      (error) {
        emit(LoadUserInfoFailure());
      },
      (data) {
        emit(UserInfoLoaded(user: data));
      },
    );
  }
}
