import 'dart:async';

enum AuthStateItem { AUTH, isAUTH, REG}

class AuthStateBloc {
  final StreamController<AuthStateItem> _navBarController =
      StreamController<AuthStateItem>.broadcast();

  AuthStateItem defaultItem = AuthStateItem.AUTH;

  Stream<AuthStateItem> get itemStream => _navBarController.stream;

  void pickItem(int i) {
    switch (i) {
      case 0:
        _navBarController.sink.add(AuthStateItem.AUTH);
        break;
      case 1:
        _navBarController.sink.add(AuthStateItem.isAUTH);
        break;
      case 2:
        _navBarController.sink.add(AuthStateItem.REG);
        break;
    }
  }

  close() {
    _navBarController?.close();
  }
}
final getAuthStateBloc = AuthStateBloc();