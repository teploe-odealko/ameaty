

import 'package:coffe_searcher_app/model/events_response.dart';
import 'package:coffe_searcher_app/repo/app_repo.dart';
import 'package:rxdart/rxdart.dart';

class GetEventsBloc{
  final AppRepository _repository = AppRepository();
  final BehaviorSubject<EventsResponse> _subject =
  BehaviorSubject<EventsResponse>();

  getEvents(String token) async{
    EventsResponse response = await _repository.getEvents(token);
    _subject.sink.add(response);
  }
  addEvent(String nameEvent,String token){

  }
  dispose() {
    _subject.close();
  }

  BehaviorSubject<EventsResponse> get subject => _subject;

}
final getEventsBloc = GetEventsBloc();