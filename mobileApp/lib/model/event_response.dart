

import 'package:coffe_searcher_app/model/event_model.dart';

class EventResponse {
  final EventModel eventModel;
  String error = "" ;

  EventResponse(this.eventModel);

  EventResponse.fromJson(var data)
      : eventModel = EventModel.fromJson(data),
        error = "";

  EventResponse.withError(String errorValue)
      : eventModel = EventModel(),
        error = errorValue;
}