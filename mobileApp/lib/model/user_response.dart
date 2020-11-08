import 'package:coffe_searcher_app/model/user_model.dart';

class UserResponse {
  final UserModel user;
  final String error;

  UserResponse(this.user, this.error);

  UserResponse.fromJson(var data)
      : user = UserModel.fromJson(data),
        error = "";

  UserResponse.withError(String errorValue)
      : user = UserModel(),
        error = errorValue;
}