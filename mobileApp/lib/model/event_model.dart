
import 'package:coffe_searcher_app/model/place_model.dart';

class EventModel{
  int id;
  String date;
  String description;
  String owner;
  String title;
  String isComplete;
  List<String> users;
  List<PlaceModel> places;

  EventModel();
  EventModel.fromJson(var data):
        id = data["id"],
        date = data["date"],
        description = data["description"],
        owner = data["owner"],
        title = data["title"],
        users = data["users"]!=null?(data["users"] as List).map((i) => i.toString()).toList():List(),
        places = data["preds"]!=null?(data["preds"] as List).map((i) => PlaceModel.fromJson(i)).toList():List(),
        isComplete = data["isComplete"]!=null?data["isComplete"]:null;
}