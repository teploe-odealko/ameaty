

import 'package:coffe_searcher_app/model/event_model.dart';

class EventsResponse {
  final List<EventModel> events;
  final String error;

  EventsResponse(this.events, this.error);

  EventsResponse.fromJson(var data)
      : events = (data["events"] as List).map((i) => new EventModel.fromJson(i)).toList(),
        error = "";

  EventsResponse.withError(String errorValue)
      : events = List(),
        error = errorValue;
}