
import 'package:coffe_searcher_app/model/place_response.dart';
import 'package:coffe_searcher_app/repo/app_repo.dart';
import 'package:rxdart/rxdart.dart';

class SearchPlaceBloc{
  final AppRepository _repository = AppRepository();
  final BehaviorSubject<PlaceResponse> _subject =
  BehaviorSubject<PlaceResponse>();

  searchPlace(String token,String restName) async{
    PlaceResponse response = await _repository.searchPlace(token,restName);
    _subject.sink.add(response);
  }

  dispose() {
    _subject.close();
  }

  BehaviorSubject<PlaceResponse> get subject => _subject;

}
final searchBloc = SearchPlaceBloc();