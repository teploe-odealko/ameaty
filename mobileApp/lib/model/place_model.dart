

class PlaceModel{
  String placeId;
  String name;
  String cuisine;
  String alcohol;
  String smokingArea;
  String parkingLot;
  PlaceModel();


  PlaceModel.fromJson(var data):
        placeId = data['placeID'],
        name = data['name'],
        cuisine = data['cuisine'],
        alcohol = data['alcohol'],
        parkingLot = data['parking_lot'],
        smokingArea = data['smoking_area'];
}