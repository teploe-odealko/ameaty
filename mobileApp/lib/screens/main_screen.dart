import 'package:coffe_searcher_app/bloc/bottom_navbar_bloc.dart';
import 'package:coffe_searcher_app/screens/tabs/events_screen.dart';
import 'package:coffe_searcher_app/screens/tabs/home_search_search.dart';
import 'package:coffe_searcher_app/screens/tabs/profile_screen.dart';
import 'package:coffe_searcher_app/style/style.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  BottomNavBarBloc _bottomNavBarBloc;
  @override
  void initState() {
    super.initState();
    _bottomNavBarBloc = BottomNavBarBloc();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Style.mainColor,
      /* appBar: PreferredSize(
        preferredSize: Size.fromHeight(50.0),
        child: AppBar(
          backgroundColor: Style.Colors.mainColor,
          title: Text("", style: TextStyle(
            color: Colors.white
          ),),
        ),
      ),*/
      body: SafeArea(
        child: StreamBuilder<NavBarItem>(
          stream: _bottomNavBarBloc.itemStream,
          initialData: _bottomNavBarBloc.defaultItem,
          // ignore: missing_return
          builder: (BuildContext context, AsyncSnapshot<NavBarItem> snapshot) {
            switch (snapshot.data) {
              case NavBarItem.HOME:
                return HomeSearchScreen();
              case NavBarItem.EVENTS:
                return EventsScreen();
              case NavBarItem.PROFILE:
                return ProfileScreen();

            }
          },
        ),
      ),
      bottomNavigationBar: StreamBuilder(
        stream: _bottomNavBarBloc.itemStream,
        initialData: _bottomNavBarBloc.defaultItem,
        builder: (BuildContext context, AsyncSnapshot<NavBarItem> snapshot) {
          return Container(
            child: ClipRRect(

              child: BottomNavigationBar(
                backgroundColor: Style.secondColor,
                iconSize: 20,
                unselectedItemColor: Style.grey,
                unselectedFontSize: 9.5,
                selectedFontSize: 9.5,

                type: BottomNavigationBarType.shifting,
                fixedColor: Style.titleColor,
                currentIndex: snapshot.data.index,
                showSelectedLabels: false,
                showUnselectedLabels: false,
                onTap: _bottomNavBarBloc.pickItem,
                items: [
                  BottomNavigationBarItem(
                    icon: Icon(EvaIcons.homeOutline),
                    activeIcon: Icon(EvaIcons.home),
                    label: "Home",
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.event_available_outlined),
                    activeIcon: Icon(Icons.event_available),
                    label: "Events",
                  ),
                  BottomNavigationBarItem(
                    label: "Profile",
                    icon: Icon(EvaIcons.personOutline),
                    activeIcon: Icon(EvaIcons.person),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
  Widget testScreen() {
    return Container(
      color: Colors.white,
      width: MediaQuery.of(context).size.width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[Text("Test Screen")],
      ),
    );
  }
}

