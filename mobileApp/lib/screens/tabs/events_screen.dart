
import 'package:coffe_searcher_app/bloc/events_bloc.dart';

import 'package:coffe_searcher_app/screens/tabs/events/event_item.dart';
import 'package:coffe_searcher_app/screens/tabs/events/events_list_screen.dart';
import 'package:coffe_searcher_app/style/style.dart';
import 'package:flutter/material.dart';

class EventsScreen extends StatefulWidget {
  @override
  _EventsScreenState createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async{
        getEventsState.goHome();
        return false;
      },
      child: Scaffold(
        backgroundColor: Style.mainColor,
        body: StreamBuilder(
          stream: getEventsState.itemStream,
          initialData: getEventsState.defaultItem,
          // ignore: missing_return
          builder: (context, AsyncSnapshot<EventsStateItem> snapshot){
            switch(snapshot.data){
              case EventsStateItem.LISTEVENTS:
                return EventsListScreen();
              case EventsStateItem.EVENT:
                return EventItemScreen();
            }
          },
        ),
      ),
    );
  }

}
