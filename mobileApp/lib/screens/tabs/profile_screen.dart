

import 'package:coffe_searcher_app/bloc/auth_user_bloc.dart';
import 'package:coffe_searcher_app/elements/loader.dart';
import 'package:coffe_searcher_app/model/user_response.dart';
import 'package:coffe_searcher_app/style/style.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {return false;},
      child: StreamBuilder<UserResponse>(
        stream: authBloc.subject.stream,
        builder: (context, AsyncSnapshot<UserResponse> snapshot) {
          if (snapshot.data != null) {
            return Stack(children: [
              Column(
                children: [
                  Expanded(
                      flex: 6,
                      child: Container(
                        decoration: kBoxImageBackgroundStyle,
                      )),
                  Expanded(
                      flex: 8,
                      child: Padding(
                        padding: EdgeInsets.only(top: 40, right: 30, left: 30),
                        child: Column(
                          children: [
                            _buildUserDataText(
                                label: "Smoker:",
                                userData: snapshot.data.user.smoker,
                                icon: Icons.smoking_rooms),
                            _buildUserDataText(
                                label: "Drink Level:",
                                userData: snapshot.data.user.drinkLevel,
                                icon: Icons.local_drink_outlined),
                            _buildUserDataText(
                                label: "Cuisine:",
                                userData: snapshot.data.user.cuisine,
                                icon: Icons.menu_book),
                            _buildUserDataText(
                                label: "Transport:",
                                userData: snapshot.data.user.transport,
                                icon: Icons.car_rental),
                          ],
                        ),
                      )),
                  Expanded(
                      flex: 1,
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: EdgeInsets.only(bottom: 16),
                          child: GestureDetector(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.sensor_door,
                                  color: Colors.red,
                                ),
                                Text(
                                  "Log out",
                                  style: kExitStyleText,
                                ),
                              ],
                            ),
                            onTap: () {
                              //authBloc..authLogOut(getSemestrBloc.subject.value.semesters.length);
                            },
                          ),
                        ),
                      ))
                ],
              ),
              Positioned.fill(
                top: -150,
                child: Align(
                  alignment: Alignment.center,
                  child: Container(
                    margin: EdgeInsets.only(left: 30, right: 30),
                    height: 100,
                    width: 370,
                    decoration: kAlertBoxDecorationStyle,
                    child: _buildNameCard(snapshot.data),
                  ),
                ),
              ),
            ]);
          } else {
            return buildLoadingWidget();
          }
        },
      ),
    );
  }

  Widget _buildNameCard(UserResponse userResponse) {
    return Padding(
      padding: EdgeInsets.only(top: 20, right: 20, left: 20),
      child: Column(children: [
        Text(
          userResponse.user.fullName,
          style: TextStyle(
              color: Style.mainColor,
              fontSize: 28
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(
          height: 8,
        ),
        Text(
          "@${userResponse.user.login}",
          style: TextStyle(
            color: Style.mainColor,
            fontSize: 18
          ),
          textAlign: TextAlign.center,
        ),
      ]),
    );
  }

  Widget _buildUserDataText(
      {@required String label, @required String userData, IconData icon}) {
    return Padding(
      padding: EdgeInsets.only(top: 20),
      child: Container(
        child: Row(
          children: [
            icon != null
                ? Icon(
              icon,
              color: Style.titleColor,
            )
                : SizedBox(),
            SizedBox(
              width: 8,
            ),
            Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: kSpanTextStyle,
                    textAlign: TextAlign.left,
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width - 100,
                    child: Text(
                      userData,
                      style: kDataTextStyle,
                      textAlign: TextAlign.left,
                    ),
                  ),
                ]),
          ],
        ),
      ),
    );
  }
}
