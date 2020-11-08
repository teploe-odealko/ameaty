

class UserModel{

  String login;
  String password;
  String token;
  String fullName;
  String smoker;
  String cuisine;
  String drinkLevel;
  String transport;


  UserModel();
  UserModel.fromJson(var data):
        token = data["access_token"],
        login = data['user']['username'],
        cuisine = data['user']['cuisine'],
        smoker = data['user']['smoker'],
        fullName = data['user']['full_name'],
        drinkLevel = data['user']['drink_level'],
        transport = data['user']['transport'];
}