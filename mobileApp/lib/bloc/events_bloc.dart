import 'dart:async';

enum EventsStateItem { LISTEVENTS, EVENT}

class EventsStateBloc {
  final StreamController<EventsStateItem> _eventsCotroller =
      StreamController<EventsStateItem>.broadcast();

  EventsStateItem defaultItem = EventsStateItem.LISTEVENTS;

  Stream<EventsStateItem> get itemStream => _eventsCotroller.stream;

  void pickItem(int i) {
    switch (i) {
      case 0:
        _eventsCotroller.sink.add(EventsStateItem.LISTEVENTS);
        break;
      case 1:
        _eventsCotroller.sink.add(EventsStateItem.EVENT);
        break;
    }
  }
  void goHome(){
    _eventsCotroller.sink.add(EventsStateItem.LISTEVENTS);
  }
  close() {
    _eventsCotroller?.close();
  }
}
final getEventsState = EventsStateBloc();