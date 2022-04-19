import 'dart:async';
import 'dart:convert';
import 'dart:math';
//import 'dart:typed_data';
//import 'dart:ui' as ui;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
//import 'package:flutter/rendering.dart';
//import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:nnotee/Services/storeServices.dart';
//import 'package:nnotee/model/customer_model.dart';
import 'package:nnotee/model/store_model.dart';
import 'package:nnotee/screen/customer/show_all_distance.dart';
import 'package:nnotee/screen/customer/show_all_rating.dart';
import 'package:nnotee/screen/customer/show_stores.dart';
import 'package:nnotee/utility/my_constant.dart';
import 'package:nnotee/utility/my_style.dart';
import 'package:nnotee/widget/customer/searchStore.dart';
import 'package:nnotee/widget/store/card_store_rate.dart';

import 'home.dart';
//import 'package:pull_to_refresh/pull_to_refresh.dart';

class HomeMap extends StatefulWidget {
  @override
  _HomeMapState createState() => _HomeMapState();
}

class _HomeMapState extends State<HomeMap> {
  double latitude1, latitude2, longitude1, longitude2, distance;
  String distanceString;
  List<StoreModel> storeModels = [];
  List<Widget> shopCards = [];
  List<StoreModel> storeList = [];
  List<Marker> allMarkers = [];
  Completer<GoogleMapController> _controller = Completer();
  BitmapDescriptor pinLocationIcon;

  @override
  void initState() {
    getStore();
    BitmapDescriptor.fromAssetImage(
      ImageConfiguration(devicePixelRatio: 1.5),
      'images/mymarkermini.png',
    ).then((onValue) {
      pinLocationIcon = onValue;
    });
    readStoreFromDistance();
    setCustomMapPin();
    super.initState();
  }

  void setCustomMapPin() async {
    pinLocationIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 1.5), 'images/mymarkermini.png');
  }

  Future<LocationData> findLocationData() async {
    Location location = Location();
    try {
      return location.getLocation();
    } catch (e) {
      return null;
    }
  }

  void routeToAppInfo() {
    MaterialPageRoute materialPageRoute = MaterialPageRoute(
      builder: (context) => SearchStore(),
    );
    Navigator.push(context, materialPageRoute);
  }

  Container showMap() {
    LatLng latLng = LatLng(latitude1, longitude1);
    CameraPosition cameraPosition = CameraPosition(
      target: latLng,
      zoom: 13.0,
      //bearing: 192.8334901395799,
      tilt: 59.440717697143555,
    );
    return Container(
      width: 500.0,
      height: 250.0,
      child: GoogleMap(
          initialCameraPosition: cameraPosition,
          mapType: MapType.normal,
          onMapCreated: (GoogleMapController controller) {
            _controller.complete(controller);
          },
          markers: Set<Marker>.of(allMarkers),
          gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>[
            new Factory<OneSequenceGestureRecognizer>(
              () => new EagerGestureRecognizer(),
            ),
          ].toSet()),
    );
  }

  Future<Null> readStoreFromDistance() async {
    LocationData locationData = await findLocationData();
    String url =
        '${MyConstant().domain}/mobile/getStore.php?isAdd=true&isType=distance&latitude=${locationData.latitude}&longitude=${locationData.longitude}';
    print('${locationData.latitude},${locationData.longitude}');
    await Dio().get(url).then((value) {
      print('value = $value');
      var result = json.decode(value.data);
      int index = 0;
      for (var map in result) {
        StoreModel model = StoreModel.fromJson(map);
        String name = model.name;
        if (name.isNotEmpty) {
          print('*******************${model.name}');
          if (mounted)
            setState(() {
              latitude1 = locationData.latitude;
              longitude1 = locationData.longitude;
              latitude2 = double.parse(model.latitude);
              longitude2 = double.parse(model.longitude);
              distance = calculateDistance(
                  latitude1, longitude1, latitude2, longitude2);
              var myFormat = NumberFormat('##0.0#', 'en_US');
              distanceString = myFormat.format(distance);
              storeModels.add(model);
              if (index < 5) {
                shopCards.add(createCard(model, index, distance));
              }
              print(shopCards);
              print('$model, $index, $distance');
              index++;
            });
        }
      }
    });
  }

  double calculateDistance(double latitude1, double longitude1,
      double latitude2, double longitude2) {
    double distance = 0;

    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((latitude2 - latitude1) * p) / 2 +
        c(latitude1 * p) *
            c(latitude2 * p) *
            (1 - c((longitude2 - longitude1) * p)) /
            2;
    distance = 12742 * asin(sqrt(a));

    return distance;
  }

  getStore() {
    StoreServices.getStoreMarker().then((storeModel) {
      if (mounted)
        setState(() {
          storeList = storeModel;
          for (int i = 0; i < storeList.length; i++) {
            LatLng latlng = new LatLng(double.parse(storeList[i].latitude),
                double.parse(storeList[i].longitude));
            this.allMarkers.add(Marker(
                markerId: MarkerId(storeList[i].id.toString()),
                position: latlng,
                infoWindow: InfoWindow(
                  title: '${storeList[i].name}',
                  snippet: 'กดเพื่อดูรายละเอียด',
                  onTap: () {
                    print('----------------${storeList[i].detail}');
                    MaterialPageRoute route = MaterialPageRoute(
                      builder: (context) => ShowStores(
                        storeModel: storeList[i],
                      ),
                    );
                    Navigator.push(context, route);
                  },
                ),
                icon: pinLocationIcon));
          }
        });
    });
  }

  Future _refreshData() async {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => Home()),
      (Route<dynamic> route) => false,
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'ร้านซ่อมใกล้ฉัน',
          style: TextStyle(color: Colors.black38),
        ),
        actions: [
          IconButton(
              color: Colors.black38,
              onPressed: () {
                routeToAppInfo();
              },
              icon: Icon(Icons.search))
        ],
      ),
      body: shopCards.length == 0
          ? latitude1 == null
              ? LinearProgressIndicator()
              : RefreshIndicator(
                  onRefresh: _refreshData,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            showMap(),
                          ],
                        ),
                        Column(
                          children: [Text('ไม่มีร้านซ่อมใกล้คุณ')],
                        )
                      ],
                    ),
                  ),
                )
          : RefreshIndicator(
              child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          showMap(),
                        ],
                      ),
                      MyStyle().mySizebox(),
                      Row(
                        children: [
                          SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            flex: 7,
                            child: Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Text(
                                'Top 5 ร้านซ่อมใกล้ฉัน',
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.w800),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => AllDistance()),
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: Text('ดูทั้งหมด',
                                    style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w800)),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(children: shopCards)),
                      Row(
                        children: [
                          SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            flex: 7,
                            child: Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Text(
                                'Top 5 ร้านที่มีเรตติ้งมากที่สุด',
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.w800),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => AllRating()),
                                  );
                                },
                                child: Text('ดูทั้งหมด',
                                    style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w800)),
                              ),
                            ),
                          ),
                        ],
                      ),
                      CardStoreRate()
                    ],
                  )),
              onRefresh: _refreshData),
    );
  }

  Widget createCard(StoreModel storeModel, int index, double distance) {
    return Stack(
      children: [
        Container(
          width: 150.0,
          child: GestureDetector(
            onTap: () {
              print('Index  $index');
              MaterialPageRoute route = MaterialPageRoute(
                builder: (context) => ShowStores(
                  storeModel: storeModels[index],
                ),
              );
              Navigator.push(context, route);
            },
            child: Card(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Container(
                    width: 80.0,
                    height: 80.0,
                    child: DecoratedBox(
                        decoration: new BoxDecoration(
                            image: new DecorationImage(
                      image: NetworkImage('${storeModel.pic}'),
                      fit: BoxFit.fill,
                      // child: Image.network('${storeModel.pic}'),
                    )))),
                SizedBox(
                  width: 100,
                ),
                Column(
                  children: [
                    Text(
                      storeModel.name,
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                    Text('$distanceString กิโลเมตร'),
                  ],
                )
              ],
            )),
          ),
        ),
        Container(
          height: 32,
          width: 45,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5), color: Colors.red),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                width: 5,
              ),
              Text(storeModel.rate != null ? '${storeModel.rate}' : '0.0',
                  style: TextStyle(color: Colors.white, fontSize: 10)),
              Icon(
                Icons.star,
                color: Colors.white,
                size: 15,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
