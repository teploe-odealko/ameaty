
import 'package:coffe_searcher_app/bloc/auth_user_bloc.dart';
import 'package:coffe_searcher_app/bloc/search_bloc.dart';

import 'package:coffe_searcher_app/model/place_model.dart';
import 'package:coffe_searcher_app/model/place_response.dart';
import 'package:coffe_searcher_app/style/style.dart';

import 'package:flutter/material.dart';


class HomeSearchScreen extends StatefulWidget {
  @override
  _HomeSearchScreenState createState() => _HomeSearchScreenState();
}

class _HomeSearchScreenState extends State<HomeSearchScreen> {
  final _searchController = TextEditingController();


  @override
  void initState() {
    _searchController.addListener(_onSearchChanged);
    super.initState();
  }

  _onSearchChanged() {
    searchBloc.searchPlace(authBloc.subject.value.user.token,_searchController.text);
  }
  @override
  void dispose() {
    _searchController.dispose();
    _searchController.removeListener(_onSearchChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: ()async{
        return false;
      },
      child: Scaffold(
        backgroundColor: Style.mainColor,
        appBar: AppBar(
          toolbarHeight: 80,
          title: Text(
            "Ameaty",
            style: TextStyle(
                fontFamily: "HelveticaNeueBold.ttf",
                color: Style.standardTextColor,
                fontSize: 34,
                fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        body: Column(
          children: [
            Container(
              child: _buildSearchTextField(),
            ),
            Expanded(
                flex: 5,
                child: Container(
                  child: _buildResultsList(),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchTextField() {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            alignment: Alignment.centerLeft,
            decoration: kBoxDecorationStyle,
            height: 60.0,
            child: TextField(
              controller: _searchController,
              style: TextStyle(
                color: Style.standardTextColor,
                fontFamily: 'OpenSans',
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.only(top: 14.0),
                prefixIcon: Icon(
                  Icons.search,
                  color: Style.titleColor,
                ),
                hintText: 'Search...',
                hintStyle: kHintTextStyle,
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildResultsList() {


    return StreamBuilder(
      stream: searchBloc.subject,
      // ignore: missing_return
      builder: (context,AsyncSnapshot<PlaceResponse> snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data.error != null &&
              snapshot.data.error.length > 0) {
            return Container();
          }
          return ListView.builder(
              itemCount: snapshot.data.places.length,
              itemBuilder: (context, index) {
                return _buildPlaceItem(snapshot.data.places[index]);
              });
        }else{
          return Container();
        }
      }
    );
  }
  Widget _buildPlaceItem(PlaceModel placeModel) {
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
