import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:nnotee/model/reviews.dart';
import 'package:nnotee/model/store_model.dart';
import 'package:nnotee/screen/store/edit_infor_store.dart';
import 'package:nnotee/utility/banstore.dart';
import 'package:nnotee/utility/my_constant.dart';
import 'package:nnotee/utility/my_style.dart';
import 'package:nnotee/widget/store/allReview.dart';
import 'package:shared_preferences/shared_preferences.dart';
//import 'package:url_launcher/url_launcher.dart';

class InfotmationStore extends StatefulWidget {
  @override
  _InfotmationStoreState createState() => _InfotmationStoreState();
}

class _InfotmationStoreState extends State<InfotmationStore> {
  StoreModel storeModel;
  var result, detail;
  int index;
  bool loading;
  double lati, longi;
  List<ReviewsModel> reviewModels;
  List<Widget> reviewCards;
  String requireId, latitude, longitude;
  ReviewsModel reviewsModel;
  double latitude1, latitude2, longitude1, longitude2, distance;
  String distanceString;
  BitmapDescriptor pinLocationIcon;

  @override
  void initState() {
    BanStore().readdataBan(context);
    readDataStore();
    readDetail();
    readReviews();
    BitmapDescriptor.fromAssetImage(
      ImageConfiguration(devicePixelRatio: 1.5),
      'images/mymarkermini.png',
    ).then((onValue) {
      pinLocationIcon = onValue;
    });
    super.initState();
  }

  Future<Null> readDataStore() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String id = preferences.getString('idst');

    String url =
        '${MyConstant().domain}/mobile/getStoreWhereId.php?isAdd=true&id=$id';
    await Dio().get(url).then((value) {
      print('value = $value');
      var result = json.decode(value.data);
      for (var map in result) {
        setState(() {
          storeModel = StoreModel.fromJson(map);
        });

        print('name =${storeModel.name}');
      }
    });
  }

  Future<Null> readDetail() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String id = preferences.getString('idst');
    setState(() {
      reviewModels = [];
      reviewCards = [];
    });
    String url =
        '${MyConstant().domain}/mobile/getReview.php?isAdd=true&storeId=$id';
    await Dio().get(url).then((value) {
      detail = json.decode(value.data);
      int index = 0;
      for (var map in detail) {
        ReviewsModel model = ReviewsModel.fromJson(map);
        reviewModels.add(model);
        if (index < 5) {
          reviewCards.add(createCard(model, index));
        }
        print(reviewCards);
        print('$model,$index');
        index++;
      }
    });
  }

  Future<Null> readReviews() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String id = preferences.getString('idst');
    String url =
        '${MyConstant().domain}/mobile/reviewScoreWhereId.php?isAdd=true&id=$id';
    await Dio().get(url).then((value) {
      print('value = $value');
      result = json.decode(value.data);
      for (var map in result) {
        setState(() {
          reviewsModel = ReviewsModel.fromJson(map);
        });
        print('name =${reviewsModel.name}');
      }
    });
  }

  void routeToAppInfo() {
    MaterialPageRoute materialPageRoute = MaterialPageRoute(
      builder: (context) => EditInfoStore(),
    );
    Navigator.push(context, materialPageRoute).then((value) => readDataStore());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            'รายละเอียดร้าน',
            style: TextStyle(color: Colors.black38),
          ),
          actions: [
            IconButton(
                color: Colors.black38,
                onPressed: () {
                  routeToAppInfo();
                },
                icon: Icon(Icons.edit))
          ],
        ),
        body: storeModel == null || storeModel.detail == null
            ? LinearProgressIndicator()
            : SingleChildScrollView(
                child: Stack(
                children: [
                  showListinfoStore(),
                ],
              )));
  }

  Widget showListinfoStore() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          showImage(),
          MyStyle().mySizebox(),
          Row(
            children: [
              SizedBox(
                width: 5,
              ),
              Text(
                '${storeModel.name}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
              SizedBox(
                width: 15,
              ),
              Container(
                height: 32,
                width: 70,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: Colors.green),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 15,
                    ),
                    Text('OFFICIAL',
                        style: TextStyle(color: Colors.white, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(
            children: [
              SizedBox(
                width: 5,
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
                    result != null
                        ? Text('${reviewsModel.rate}',
                            style: TextStyle(color: Colors.white, fontSize: 12))
                        : Text('0.0',
                            style:
                                TextStyle(color: Colors.white, fontSize: 12)),
                    Icon(
                      Icons.star,
                      color: Colors.white,
                      size: 15,
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 15,
              ),
              result != null
                  ? Text(
                      '${reviewsModel.num} เรตติ้ง (${reviewsModel.num} รีวิว)')
                  : Text('0 เรตติ้ง (0 รีวิว)')
            ],
          ),
          SizedBox(height: 10),
          Row(
            children: [
              SizedBox(
                width: 5.0,
              ),
              Text(
                'รายละเอียดร้าน',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
              ),
            ],
          ),
          storeModel.detail != ''
              ? Text(
                  '${storeModel.detail}',
                  style: TextStyle(fontSize: 15),
                )
              : Text(
                  'กรุณาใส่รายละเอียดเพิ่มเติม',
                  style: TextStyle(fontSize: 20, color: Colors.red),
                ),
          SizedBox(
            height: 10,
          ),
          Container(
              width: 500,
              decoration: BoxDecoration(color: Colors.black38),
              child: Row(
                children: [
                  Icon(Icons.report),
                  SizedBox(
                    width: 350,
                    child: Text(
                        'เวลาทำการหรือบริการอาจมีการเปลี่ยนแปลง กรุณาติดต่อร้านซ่อมโดยตรงสำหรับข้อมูลเพิ่มเติม'),
                  )
                ],
              )),
          MyStyle().mySizebox(),
          Stack(
            children: [
              showMap(),
            ],
          ),
          SizedBox(
            height: 10,
          ),
          ListTile(
            title:
                Text('โทร: ${storeModel.tel}', style: TextStyle(fontSize: 15)),
            trailing: Icon(Icons.phone_outlined, color: Colors.black),
          ),
          ListTile(
            title: Text('อีเมล: ${storeModel.email}',
                style: TextStyle(fontSize: 15)),
            trailing: Icon(Icons.email_outlined, color: Colors.black),
          ),
          Container(
            padding: EdgeInsets.all(10),
            child: Divider(
              color: Colors.black38,
            ),
          ),
          ListTile(
            title: result != null
                ? Text('${reviewsModel.num} รีวิว',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800))
                : Text('0 รีวิว', style: TextStyle(fontSize: 15)),
            trailing: Text(
              'ดูทั้งหมด',
              style: TextStyle(color: Colors.blue),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => AllReview(
                          storeModel: storeModel,
                        )),
              );
            },
          ),
          Row(
            children: [
              SizedBox(
                width: 15,
              ),
              result != null
                  ? Column(
                      children: [
                        Text('${reviewsModel.rate}',
                            style: TextStyle(fontSize: 60)),
                        Text(
                          'จาก ${reviewsModel.num} เรตติ้ง',
                          style: TextStyle(color: Colors.black54),
                        )
                      ],
                    )
                  : Column(
                      children: [
                        Text('0.0', style: TextStyle(fontSize: 60)),
                        Text(
                          'จาก 0 เรตติ้ง',
                          style: TextStyle(color: Colors.black54),
                        )
                      ],
                    ),
              SizedBox(
                width: 20,
              ),
              Column(
                children: [
                  RatingBarIndicator(
                    rating: 5,
                    itemSize: 15,
                    direction: Axis.horizontal,
                    itemCount: 5,
                    itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                    itemBuilder: (context, _) => Icon(
                      Icons.star,
                      color: Colors.amber,
                    ),
                  ),
                  RatingBarIndicator(
                    rating: 4,
                    itemSize: 15,
                    direction: Axis.horizontal,
                    itemCount: 5,
                    itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                    itemBuilder: (context, _) => Icon(
                      Icons.star,
                      color: Colors.amber,
                    ),
                  ),
                  RatingBarIndicator(
                    rating: 3,
                    itemSize: 15,
                    direction: Axis.horizontal,
                    itemCount: 5,
                    itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                    itemBuilder: (context, _) => Icon(
                      Icons.star,
                      color: Colors.amber,
                    ),
                  ),
                  RatingBarIndicator(
                    rating: 2,
                    itemSize: 15,
                    direction: Axis.horizontal,
                    itemCount: 5,
                    itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                    itemBuilder: (context, _) => Icon(
                      Icons.star,
                      color: Colors.amber,
                    ),
                  ),
                  RatingBarIndicator(
                    rating: 1,
                    itemSize: 15,
                    direction: Axis.horizontal,
                    itemCount: 5,
                    itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                    itemBuilder: (context, _) => Icon(
                      Icons.star,
                      color: Colors.amber,
                    ),
                  ),
                ],
              )
            ],
          ),
          SizedBox(
            height: 10,
          ),
          detail != null
              ? Column(
                  children: reviewCards,
                )
              : Text('ยังไม่มีการรีวิว')
        ],
      );
  Widget createCard(ReviewsModel reviewModel, int index) {
    return Container(
      width: 500.0,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Row(
            children: [
              SizedBox(
                width: 10,
              ),
              Column(
                children: [
                  CircleAvatar(
                    radius: 30.0,
                    backgroundImage: NetworkImage('${reviewModel.pic}'),
                    backgroundColor: Colors.transparent,
                  ),
                  Text(
                    reviewModel.name,
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ],
              ),
              SizedBox(
                width: 80,
              ),
              Column(
                children: [
                  Text('คะแนน'),
                  RatingBarIndicator(
                    rating: double.parse(reviewModel.score),
                    itemSize: 15,
                    direction: Axis.horizontal,
                    itemCount: 5,
                    itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                    itemBuilder: (context, _) => Icon(
                      Icons.star,
                      color: Colors.amber,
                    ),
                  ),
                  Text(reviewModel.detail),
                ],
              )
            ],
          ),
        ],
      ),
    );
  }

  Container showImage() {
    return Container(
        width: 500.0,
        height: 200,
        child: DecoratedBox(
            decoration: new BoxDecoration(
                image: new DecorationImage(
          image: NetworkImage('${storeModel.pic}'),
          fit: BoxFit.fill,
          // child: Image.network('${storeModel.pic}'),
        ))));
  }

  Set<Marker> storeMarker() {
    return <Marker>[
      Marker(
          markerId: MarkerId('storeID'),
          icon: pinLocationIcon,
          position: LatLng(double.parse(storeModel.latitude),
              double.parse(storeModel.longitude)),
          infoWindow: InfoWindow(
              title: 'ตำแหน่งร้านซ่อม',
              snippet:
                  'latitude =${storeModel.latitude},longitude =${storeModel.longitude}')),
    ].toSet();
  }

  Container showMap() {
    double lat = double.parse(storeModel.latitude);
    double lng = double.parse(storeModel.longitude);
    LatLng latLng = LatLng(lat, lng);
    CameraPosition position = CameraPosition(target: latLng, zoom: 16.0);

    return Container(
      width: 500.0,
      height: 200,
      child: GoogleMap(
        initialCameraPosition: position,
        mapType: MapType.normal,
        onMapCreated: (controller) {},
        markers: storeMarker(),
      ),
    );
  }
}
