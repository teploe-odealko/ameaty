


import 'package:coffe_searcher_app/bloc/auth_user_bloc.dart';
import 'package:coffe_searcher_app/elements/loader.dart';
import 'package:coffe_searcher_app/model/user_response.dart';
import 'package:coffe_searcher_app/screens/main_screen.dart';
import 'package:coffe_searcher_app/style/style.dart';
import 'package:flutter/material.dart';

import 'auth_screen.dart';

class AuthCheckScreen extends StatefulWidget {
  @override
  _AuthCheckScreenState createState() => _AuthCheckScreenState();
}

class _AuthCheckScreenState extends State<AuthCheckScreen> {

  @override
  void initState() {
    authBloc..auth("0101", "323da");
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {return false;},
      child: SafeArea(
          child: Container(
            color: Style.mainColor,
            child: StreamBuilder<UserResponse>(
              stream: authBloc.subject.stream,
              builder: (context, AsyncSnapshot<UserResponse> snapshot) {
                if (snapshot.hasData) {
                  if (snapshot.data.error != null &&
                      snapshot.data.error.length > 0) {
                    if(snapshot.data.error == "start"){
                      return AuthScreen();
                    }
                    if(snapshot.data.error == "loading"){
                      return buildLoadingWidget();
                    }
                    print("AuthScreen");
                    return AuthScreen();
                  }
                  print("token = "+snapshot.data.user.token);
                  return MainScreen();
                } else if (snapshot.hasError) {
                  print("hasError");
                  return AuthScreen();
                } else {
                  return buildLoadingWidget();
                }
              },
            ),
          )
      ),
    );
  }
}
