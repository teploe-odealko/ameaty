import 'package:coffe_searcher_app/bloc/auth_user_bloc.dart';
import 'package:coffe_searcher_app/bloc/events_bloc.dart';
import 'package:coffe_searcher_app/bloc/get_curr_event_bloc.dart';
import 'package:coffe_searcher_app/elements/loader.dart';
import 'package:coffe_searcher_app/model/event_model.dart';
import 'package:coffe_searcher_app/model/event_response.dart';
import 'package:coffe_searcher_app/model/place_model.dart';
import 'package:coffe_searcher_app/style/style.dart';
import 'package:coffe_searcher_app/widgets/add_friends_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class EventItemScreen extends StatefulWidget {
  @override
  _EventItemScreenState createState() => _EventItemScreenState();
}

class _EventItemScreenState extends State<EventItemScreen> {
  /*List<PlaceModel> places = [
    PlaceModel(),
    PlaceModel(),
    PlaceModel(),
    PlaceModel(),
    PlaceModel(),
    PlaceModel(),
  ];*/
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: StreamBuilder(
          stream: getCurrentEventBloc.subject,
          // ignore: missing_return
          builder:
              (BuildContext context, AsyncSnapshot<EventResponse> snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data.error != null &&
                  snapshot.data.error.length > 0) {
                return Container();
              }
              return snapshot.data.eventModel.owner ==
                      authBloc.subject.value.user.login
                  ? FloatingActionButton.extended(
                      onPressed: () {
                        addFriendsWidget(context, EventModel());
                      },
                      backgroundColor: Style.titleColor,
                      label: Text(
                        "add friends",
                        style: TextStyle(
                          color: Style.mainColor,
                        ),
                      ),
                      icon: Icon(
                        Icons.add,
                        color: Style.mainColor,
                      ),
                    )
                  : Container();
            } else {
              return Container();
            }
          }),
      body: StreamBuilder(
          stream: getCurrentEventBloc.subject,
          builder:
              (BuildContext context, AsyncSnapshot<EventResponse> snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data.error != null &&
                  snapshot.data.error.length > 0) {
                if (snapshot.data.error == "loading") {
                  return buildLoadingWidget();
                }
                print("AuthScreen");
                return Container();
              }
              return CustomScrollView(slivers: [
                SliverAppBar(
                  leading: IconButton(
                    icon: Icon(
                      Icons.arrow_back,
                      color: Style.mainColor,
                    ),
                    onPressed: () {
                      getEventsState.goHome();
                    },
                  ),
                  actions: [
                    IconButton(
                      icon: Icon(
                        Icons.refresh,
                        color: Style.mainColor,
                      ),
                      onPressed: () {
                        getCurrentEventBloc.getCurrentEvent(
                            "0", snapshot.data.eventModel.id);
                        getCurrentEventBloc.getCurrentEvent(
                            authBloc.subject.value.user.token,
                            snapshot.data.eventModel.id);
                      },
                    ),
                  ],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(25),
                        bottomRight: Radius.circular(25)),
                  ),
                  floating: false,
                  pinned: true,
                  toolbarHeight: 80,
                  expandedHeight: 240.0,
                  backgroundColor: Style.titleColor,
                  elevation: 0,
                  flexibleSpace: FlexibleSpaceBar(
                    centerTitle: true,
                    //titlePadding: EdgeInsets.all(8),
                    title: Text(
                      snapshot.data.eventModel.title,
                      style: TextStyle(
                          fontFamily: "HelveticaNeueBold.ttf",
                          color: Style.mainColor,
                          fontSize: 34,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                SliverPersistentHeader(
                  delegate: MySliverAppBar(expandedHeight: 70),
                  pinned: true,
                ),
                SliverList(
                  delegate:
                      // ignore: missing_return
                      SliverChildBuilderDelegate(
                          (BuildContext context, int index) {
                            if(snapshot.data.eventModel.isComplete!=null){
                              return Column(
                                children: [
                                  _buildHeaderPlaceList("Result: "),
                                  _buildResultPlaceItem(snapshot.data.eventModel.places[0]),
                                ],
                              );
                            }

                      return Column(
                        children: [
                          index==0?_buildHeaderPlaceList("Choice: "):Container(),
                          _buildPredictPlaceItem(
                              snapshot.data.eventModel.places[index]),
                        ],
                      );

                  }, childCount: snapshot.data.eventModel.places.length),
                )
              ]);
            } else {
              return buildLoadingWidget();
            }
          }),
    );
  }

  Widget _buildHeaderPlaceList(String header) {
    return Padding(
      padding: const EdgeInsets.only(top: 15, left: 15, right: 15),
      child: Container(
        child: Text(
          header,
          style: TextStyle(
              fontFamily: "HelveticaNeueBold.ttf",
              color: Style.standardTextColor,
              fontSize: 24,
              fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildPredictPlaceItem(PlaceModel placeModel) {
    return Padding(
      padding: const EdgeInsets.only(top: 15, left: 15, right: 15),
      child: Dismissible(
        key: Key(placeModel.placeId.toString()),
        onDismissed: (DismissDirection direction) async {
          if (direction == DismissDirection.startToEnd) {
            print("right");
            getCurrentEventBloc.setVote(authBloc.subject.value.user.token, "1", getCurrentEventBloc.subject.value.eventModel.id.toString(), placeModel.placeId);
            getCurrentEventBloc.getCurrentEvent(
                "0", getCurrentEventBloc.subject.value.eventModel.id);
            getCurrentEventBloc.getCurrentEvent(
                authBloc.subject.value.user.token,
                getCurrentEventBloc.subject.value.eventModel.id);
          } else {
            print('left');
            getCurrentEventBloc.setVote(authBloc.subject.value.user.token, "-1", getCurrentEventBloc.subject.value.eventModel.id.toString(), placeModel.placeId);
            getCurrentEventBloc.getCurrentEvent(
                "0", getCurrentEventBloc.subject.value.eventModel.id);
            getCurrentEventBloc.getCurrentEvent(
                authBloc.subject.value.user.token,
                getCurrentEventBloc.subject.value.eventModel.id);
          }
        },
        background: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.centerRight,
                  end: Alignment.centerLeft,
                  colors: [Style.mainColor, Style.titleColor, Style.mainColor],
                  tileMode: TileMode.mirror)),
          child: Align(
            child: Icon(
              Icons.check_circle,
              color: Style.mainColor,
            ),
          ),
        ),
        secondaryBackground: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.centerRight,
                  end: Alignment.centerLeft,
                  colors: [
                    Style.mainColor,
                    Colors.red,
                    Style.mainColor,
                  ],
                  tileMode: TileMode.mirror)),
          child: Icon(
            Icons.cancel,
            color: Style.mainColor,
          ),
        ),
        child: Container(
          height: 140,
          decoration: kListItemBoxDecorationStyle,
          child: Row(
            children: [
              Expanded(
                flex: 5,
                child: Container(
                  width: 110,
                  height: 140,
                  child: ClipRRect(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(25),
                        bottomLeft: Radius.circular(25)),
                    child: Image.network(
                      "https://www.archrevue.ru/images/tb/2/6/4/26496/14507023686857_w1500h1500.jpg",
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 8,
              ),
              Expanded(
                flex: 9,
                child: Padding(
                  padding: const EdgeInsets.only(top: 8.0, right: 8),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          placeModel.name,
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Style.standardTextColor,
                          ),
                        ),
                        SizedBox(
                          height: 3,
                        ),
                        Row(
                          children: [
                            Text(
                              "Cuisine: ",
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Style.standardTextColor,
                              ),
                            ),
                            Text(
                              "${placeModel.cuisine}",
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Style.titleColor,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 3,
                        ),
                        Row(
                          children: [
                            Text(
                              "Smoking Area: ",
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Style.standardTextColor,
                              ),
                            ),
                            Text(
                              "${placeModel.smokingArea}",
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Style.titleColor,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 3,
                        ),
                        Row(
                          children: [
                            Text(
                              "Alcohol: ",
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Style.standardTextColor,
                              ),
                            ),
                            Text(
                              "${placeModel.alcohol}",
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Style.titleColor,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 3,
                        ),
                        Row(
                          children: [
                            Text(
                              "Parking lot: ",
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Style.standardTextColor,
                              ),
                            ),
                            Text(
                              "${placeModel.parkingLot}",
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Style.titleColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildResultPlaceItem(PlaceModel placeModel) {
    return Padding(
      padding: const EdgeInsets.only(top: 15, left: 15, right: 15),
      child: Container(
        height: 140,
        decoration: kListItemBoxDecorationStyle,
        child: Row(
          children: [
            Expanded(
              flex: 5,
              child: Container(
                width: 110,
                height: 140,
                child: ClipRRect(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(25),
                      bottomLeft: Radius.circular(25)),
                  child: Image.network(
                    "https://www.archrevue.ru/images/tb/2/6/4/26496/14507023686857_w1500h1500.jpg",
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            SizedBox(
              width: 8,
            ),
            Expanded(
              flex: 9,
              child: Padding(
                padding: const EdgeInsets.only(top: 8.0, right: 8),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        placeModel.name,
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Style.standardTextColor,
                        ),
                      ),
                      SizedBox(
                        height: 3,
                      ),
                      Row(
                        children: [
                          Text(
                            "Cuisine: ",
                            textAlign: TextAlign.start,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Style.standardTextColor,
                            ),
                          ),
                          Text(
                            "${placeModel.cuisine}",
                            textAlign: TextAlign.start,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Style.titleColor,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 3,
                      ),
                      Row(
                        children: [
                          Text(
                            "Smoking Area: ",
                            textAlign: TextAlign.start,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Style.standardTextColor,
                            ),
                          ),
                          Text(
                            "${placeModel.smokingArea}",
                            textAlign: TextAlign.start,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Style.titleColor,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 3,
                      ),
                      Row(
                        children: [
                          Text(
                            "Alcohol: ",
                            textAlign: TextAlign.start,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Style.standardTextColor,
                            ),
                          ),
                          Text(
                            "${placeModel.alcohol}",
                            textAlign: TextAlign.start,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Style.titleColor,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 3,
                      ),
                      Row(
                        children: [
                          Text(
                            "Parking lot: ",
                            textAlign: TextAlign.start,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Style.standardTextColor,
                            ),
                          ),
                          Text(
                            "${placeModel.parkingLot}",
                            textAlign: TextAlign.start,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Style.titleColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MySliverAppBar extends SliverPersistentHeaderDelegate {
  final double expandedHeight;

  MySliverAppBar({@required this.expandedHeight});

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      child: Stack(
        fit: StackFit.expand,
        overflow: Overflow.visible,
        children: [
          Positioned(
            top: -shrinkOffset - 10,
            left: MediaQuery.of(context).size.width / 6,
            child: Opacity(
              opacity: (1 - shrinkOffset / expandedHeight),
              child: Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(25),
                        bottomRight: Radius.circular(25))),
                borderOnForeground: true,
                elevation: 5,
                child: SizedBox(
                  height: expandedHeight,
                  width: MediaQuery.of(context).size.width / 1.5,
                  child: StreamBuilder(
                      stream: getCurrentEventBloc.subject,
                      // ignore: missing_return
                      builder: (BuildContext context,
                          AsyncSnapshot<EventResponse> snapshot) {
                        if (snapshot.hasData) {
                          if (snapshot.data.error != null &&
                              snapshot.data.error.length > 0) {
                            return Container();
                          }

                          return Container(
                            child: Align(
                              alignment: Alignment.center,
                              child: Text(
                                  "Team: ${snapshot.data.eventModel.users.toString().replaceAll("[", "").replaceAll("]", "")}",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Style.titleColor,
                                ),
                              ),
                            ),
                          );
                        } else {
                          return Container();
                        }
                      }),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  double get maxExtent => expandedHeight;

  @override
  double get minExtent => 0;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) => true;
}
