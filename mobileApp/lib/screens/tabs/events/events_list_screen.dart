import 'package:coffe_searcher_app/bloc/auth_user_bloc.dart';
import 'package:coffe_searcher_app/bloc/events_bloc.dart';
import 'package:coffe_searcher_app/bloc/get_curr_event_bloc.dart';
import 'package:coffe_searcher_app/bloc/get_events_bloc.dart';
import 'package:coffe_searcher_app/elements/loader.dart';
import 'package:coffe_searcher_app/model/event_model.dart';
import 'package:coffe_searcher_app/model/events_response.dart';
import 'package:coffe_searcher_app/style/style.dart';
import 'package:coffe_searcher_app/widgets/add_event_widget.dart';
import 'package:flutter/material.dart';

class EventsListScreen extends StatefulWidget {
  @override
  _EventsListScreenState createState() => _EventsListScreenState();
}

class _EventsListScreenState extends State<EventsListScreen> {
  @override
  void initState() {
    getEventsBloc.getEvents(authBloc.subject.value.user.token);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Style.mainColor,
      appBar: AppBar(
        actions: [
          IconButton(
            icon: Icon(
              Icons.refresh,
              color: Style.standardTextColor,
            ),
            onPressed: () {
              getEventsBloc.getEvents("0");
              getEventsBloc.getEvents(authBloc.subject.value.user.token);
            },
          ),
        ],
        toolbarHeight: 80,
        title: Text(
          "Events",
          style: TextStyle(
              fontFamily: "HelveticaNeueBold.ttf",
              color: Style.standardTextColor,
              fontSize: 34,
              fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          addEventWidget(context);
        },
        backgroundColor: Style.titleColor,
        label: Text(
          "add event",
          style: TextStyle(
            color: Style.mainColor,
          ),
        ),
        icon: Icon(
          Icons.add,
          color: Style.mainColor,
        ),
      ),
      body: Column(
        children: [
          Expanded(child: _buildEventsList()),
        ],
      ),
    );
  }

  Widget _buildEventsList() {
    return StreamBuilder(
        stream: getEventsBloc.subject,
        builder: (context, AsyncSnapshot<EventsResponse> snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data.error != null && snapshot.data.error.length > 0) {
              if(snapshot.data.error == "loading"){
                return buildLoadingWidget();
              }
              return Container();
            }
            return ListView.builder(
                itemCount: snapshot.data.events.length,
                itemBuilder: (context, index) {
                  return _buildEventItem(snapshot.data.events[index]);
                });
          } else if (snapshot.hasError) {
            print("hasError");
            return Container();
          } else {
            return buildLoadingWidget();
          }
        });
  }

  Widget _buildEventItem(EventModel eventModel) {
    return Padding(
      padding: const EdgeInsets.only(top: 15, left: 15, right: 15),
      child: Container(
        height: 110,
        decoration: kListItemBoxDecorationStyle,
        child: Row(
          children: [
            Expanded(
              flex: 5,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
              "${DateTime.parse(eventModel.date).hour}:${DateTime.parse(eventModel.date).minute}",
                    textAlign: TextAlign.start,
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Style.standardTextColor,
                    ),
                  ),
                  SizedBox(
                    height: 4,
                  ),
                  Text(
                    "${DateTime.parse(eventModel.date).day}.${DateTime.parse(eventModel.date).month}.${DateTime.parse(eventModel.date).year}",
                    textAlign: TextAlign.start,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Style.titleColor,
                    ),
                  )
                ],
              ),
            ),
            SizedBox(
              width: 8,
            ),
            Expanded(
              flex: 9,
              child: Padding(
                padding: const EdgeInsets.only(top: 16.0, right: 16),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        eventModel.title,
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Style.standardTextColor,
                        ),
                      ),
                      SizedBox(
                        height: 4,
                      ),
                      Text(
                        eventModel.owner,
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Style.titleColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(
              width: 8,
            ),
            Expanded(
              flex: 2,
              child: Container(
                height: 110,
                child: ClipRRect(
                  borderRadius: BorderRadius.only(
                      topRight: Radius.circular(25),
                      bottomRight: Radius.circular(25)),
                  child: RotatedBox(
                    quarterTurns: -1,
                    child: GestureDetector(
                      onTap: () {
                        getCurrentEventBloc.getCurrentEvent("0", eventModel.id);
                        getCurrentEventBloc.getCurrentEvent(authBloc.subject.value.user.token, eventModel.id);
                        getEventsState.pickItem(1);
                      },
                      child: Container(
                        color: Style.titleColor,
                        child: Align(
                          alignment: Alignment.center,
                          child: Text(
                            "Go",
                            style:
                                TextStyle(color: Style.mainColor, fontSize: 17),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
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
