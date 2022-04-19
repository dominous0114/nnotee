import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
//import 'package:flutter/rendering.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:nnotee/model/customer_model.dart';
import 'package:nnotee/model/store_model.dart';
import 'package:nnotee/screen/customer/show_stores.dart';
import 'package:nnotee/utility/banstore.dart';
import 'package:nnotee/utility/my_constant.dart';

class CardStoreRate extends StatefulWidget {
  @override
  _CardStoreRateState createState() => _CardStoreRateState();
}

class _CardStoreRateState extends State<CardStoreRate> {
  double latitude1, latitude2, longitude1, longitude2, distance;
  String distanceString;
  List<CustomerModel> customerModels = [];
  List<StoreModel> storeModels = [];
  List<Widget> shopCards = [];
  List<StoreModel> storeList = [];
  List<Marker> allMarkers = [];
  BitmapDescriptor pinLocationIcon;

  @override
  void initState() {
    BanStore().readdataBan(context);
    BitmapDescriptor.fromAssetImage(
      ImageConfiguration(devicePixelRatio: 1.5),
      'images/mymarkermini.png',
    ).then((onValue) {
      pinLocationIcon = onValue;
    });
    readStoreFromDistance();
    super.initState();
  }

  Future<LocationData> findLocationData() async {
    Location location = Location();
    try {
      return location.getLocation();
    } catch (e) {
      return null;
    }
  }

  Future<Null> readStoreFromDistance() async {
    LocationData locationData = await findLocationData();
    String url =
        '${MyConstant().domain}/mobile/getStore.php?isAdd=true&isType=rate&latitude=${locationData.latitude}&longitude=${locationData.longitude}';
    print('${locationData.latitude},${locationData.longitude}');
    await Dio().get(url).then((value) {
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

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        scrollDirection: Axis.horizontal, child: Row(children: shopCards));
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
