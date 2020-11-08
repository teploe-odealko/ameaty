import 'package:coffe_searcher_app/model/user_response.dart';
import 'package:coffe_searcher_app/repo/app_repo.dart';
import 'package:rxdart/rxdart.dart';

class AuthUserBloc{
  final AppRepository _repository = AppRepository();
  final BehaviorSubject<UserResponse> _subject =
  BehaviorSubject<UserResponse>();

  auth(String login, String password) async{
    UserResponse response = await _repository.userAuth(login, password);
    _subject.sink.add(response);
  }


  dispose() {
    _subject.close();
  }

  BehaviorSubject<UserResponse> get subject => _subject;

}
final authBloc = AuthUserBloc();