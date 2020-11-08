

import 'package:coffe_searcher_app/model/place_model.dart';

class PlaceResponse {
  final List<PlaceModel> places;
  final String error;

  PlaceResponse(this.places, this.error);

  PlaceResponse.fromJson(var data)
      : places = (data["rests"] as List).map((i) => new PlaceModel.fromJson(i)).toList(),
        error = "";

  PlaceResponse.withError(String errorValue)
      : places = List(),
        error = errorValue;
}