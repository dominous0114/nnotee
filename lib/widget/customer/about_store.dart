import 'dart:convert';
import 'dart:math';

import 'package:dio/dio.dart';
//import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:nnotee/model/reviews.dart';
import 'package:nnotee/model/store_model.dart';
import 'package:nnotee/screen/customer/show_chat.dart';
//import 'package:nnotee/screen/customer/show_chat.dart';
//import 'package:nnotee/screen/store/resetpw_store.dart';
import 'package:nnotee/utility/my_constant.dart';
import 'package:nnotee/utility/my_style.dart';
import 'package:nnotee/utility/normal_dialog.dart';
import 'package:nnotee/widget/store/allReview.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutStore extends StatefulWidget {
  final StoreModel storeModel;
  const AboutStore({Key key, this.storeModel}) : super(key: key);

  @override
  _AboutStoreState createState() => _AboutStoreState();
}

class _AboutStoreState extends State<AboutStore> {
  var result, detail, record;
  int index;
  bool loading;
  double lati, longi;
  List<ReviewsModel> reviewModels;
  List<Widget> reviewCards;
  String requireId, latitude, longitude;
  Location newlocation = Location();
  StoreModel storeModel;
  ReviewsModel reviewsModel;
  double latitude1, latitude2, longitude1, longitude2, distance;
  String distanceString;
  Location location = Location();
  BitmapDescriptor pinLocationIcon;
  @override
  void initState() {
    BitmapDescriptor.fromAssetImage(
      ImageConfiguration(devicePixelRatio: 1.5),
      'images/mymarkermini.png',
    ).then((onValue) {
      pinLocationIcon = onValue;
    });
    super.initState();
    storeModel = widget.storeModel;
    print(storeModel.id);
    readCustomerRecord();
    readDetail();
    readReviews();
    findLatLng1();
  }

  Future<Null> checkPreference() async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      String type = preferences.getString('type');
      if (type == 'customer') {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ShowChat(
                    storeModel: storeModel,
                  )),
        );
      } else {
        normalDialog(context, 'กรุณาเข้าสู่ระบบ');
      }
    } catch (e) {}
  }

  Future<Null> checkPreferenceRecord() async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      String type = preferences.getString('type');
      if (type == 'customer') {
        addRecordcusThread();
        Fluttertoast.showToast(
            msg: "เพิ่มไปยังบันทึกไว้เรียบร้อย",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1);
      } else {
        normalDialog(context, 'กรุณาเข้าสู่ระบบ');
      }
    } catch (e) {}
  }

  void openMap() async {
    final url =
        'https://www.google.com/maps/search/?api=1&query=${storeModel.latitude},${storeModel.longitude}';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<Null> readCustomerRecord() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String id = preferences.getString('idcus');
    String url =
        '${MyConstant().domain}/mobile/getRecordCus.php?isAdd=true&customer_id=$id&store_id=${storeModel.id}';
    await Dio().get(url).then((value) {
      setState(() {
        record = json.decode(value.data);
      });
    });
  }

  Future<Null> addRecordcusThread() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String id = preferences.getString('idcus');
    String url =
        '${MyConstant().domain}/mobile/addRecordCus.php?isAdd=true&customer_id=$id&store_id=${storeModel.id}';
    try {
      Response response = await Dio().get(url);
      readCustomerRecord();
      print('res = $response');
    } catch (e) {
      print(e);
    }
  }

  Future<Null> delRecordcusThread() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String id = preferences.getString('idcus');
    String url =
        '${MyConstant().domain}/mobile/delRecordCus.php?isAdd=true&customer_id=$id&store_id=${storeModel.id}';
    try {
      Response response = await Dio().get(url);
      readCustomerRecord();
      print('res = $response');
    } catch (e) {
      print(e);
    }
  }

  Future<Null> readDetail() async {
    setState(() {
      reviewModels = [];
      reviewCards = [];
    });
    String url =
        '${MyConstant().domain}/mobile/getReview.php?isAdd=true&storeId=${storeModel.id}';
    await Dio().get(url).then((value) {
      detail = json.decode(value.data);
      int index = 0;
      for (var map in detail) {
        ReviewsModel model = ReviewsModel.fromJson(map);
        reviewModels.add(model);
        reviewCards.add(createCard(model, index));
        print(reviewCards);
        print('$model,$index');
        index++;
      }
    });
  }

  Future<Null> readReviews() async {
    String url =
        '${MyConstant().domain}/mobile/reviewScoreWhereStore.php?isAdd=true&name=${storeModel.name}';
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

  Future<Null> findLatLng1() async {
    LocationData locationData = await findLocationData();
    setState(() {
      latitude1 = locationData.latitude;
      longitude1 = locationData.longitude;
      latitude2 = double.parse(storeModel.latitude);
      longitude2 = double.parse(storeModel.longitude);
      print(
          'lat1 =$latitude1,lng1=$longitude1,lat2=$latitude2,lng2=$longitude2');
      distance =
          calculateDistance(latitude1, longitude1, latitude2, longitude2);
      var myFormat = NumberFormat('##0.0#', 'en_US');
      distanceString = myFormat.format(distance);
      print('distance ****************************************= $distance');
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

  Future<LocationData> findLocationData() async {
    Location location = Location();
    try {
      return await location.getLocation();
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
            child: Stack(
      children: <Widget>[
        storeModel == null && reviewsModel == null
            ? LinearProgressIndicator()
            : storeModel.name.isEmpty
                ? showNoData(context)
                : showListinfoStore(),
        // editButton()
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
              record == null
                  ? IconButton(
                      onPressed: () {
                        checkPreferenceRecord();
                      },
                      icon: Icon(Icons.bookmark_border_outlined))
                  : IconButton(
                      onPressed: () {
                        delRecordcusThread();
                        Fluttertoast.showToast(
                            msg: "ลบจากที่บันทึกไว้เรียบร้อย",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.BOTTOM,
                            timeInSecForIosWeb: 1);
                      },
                      icon: Icon(Icons.bookmark))
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
                            style: TextStyle(color: Colors.white, fontSize: 10))
                        : Text('0.0',
                            style:
                                TextStyle(color: Colors.white, fontSize: 10)),
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
          Text(
            'รายละเอียดร้าน',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
          ),
          Text(
            '${storeModel.detail}',
            style: TextStyle(fontSize: 15),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 5,
              ),
              Text(
                'ระยะทาง: $distanceString กิโลเมตร',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
              ),
            ],
          ),
          Stack(
            children: [
              showMap(),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        shape: CircleBorder(),
                        primary: Color.fromRGBO(233, 236, 238, 50)),
                    child: Container(
                        width: 40,
                        height: 40,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(shape: BoxShape.circle),
                        child: Icon(
                          Icons.phone_outlined,
                          color: Colors.black,
                        )),
                    onPressed: () {
                      launch('tel://${storeModel.tel}');
                    },
                  ),
                  Text('โทร')
                ],
              ),
              Column(
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        shape: CircleBorder(),
                        primary: Color.fromRGBO(233, 236, 238, 50)),
                    child: Container(
                        width: 40,
                        height: 40,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(shape: BoxShape.circle),
                        child: Icon(
                          Icons.chat,
                          color: Colors.black,
                        )),
                    onPressed: () {
                      checkPreference();
                    },
                  ),
                  Text('แชท')
                ],
              ),
              Column(
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        shape: CircleBorder(),
                        primary: Color.fromRGBO(233, 236, 238, 50)),
                    child: Container(
                        width: 40,
                        height: 40,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(shape: BoxShape.circle),
                        child: Icon(
                          Icons.map,
                          color: Colors.black,
                        )),
                    onPressed: () {
                      openMap();
                    },
                  ),
                  Text('ไปที่ร้าน')
                ],
              ),
            ],
          ),
          SizedBox(
            height: 10,
          ),
          ListTile(
            title:
                Text('โทร: ${storeModel.tel}', style: TextStyle(fontSize: 15)),
            trailing: Icon(Icons.phone_outlined, color: Colors.black),
            onTap: () {},
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
                          )));
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
        position: LatLng(double.parse(storeModel.latitude),
            double.parse(storeModel.longitude)),
        infoWindow: InfoWindow(
            title: '${storeModel.name}',
            snippet:
                'latitude =${storeModel.latitude},longitude =${storeModel.longitude}'),
        //consumeTapEvents: true
      )
    ].toSet();
  }

  Widget showMap() {
    double lat = double.parse(storeModel.latitude);
    double lng = double.parse(storeModel.longitude);
    LatLng latLng = LatLng(lat, lng);
    CameraPosition position = CameraPosition(target: latLng, zoom: 13.0);

    return Container(
      width: 500.0,
      height: 120,
      padding: EdgeInsets.all(10),
      child: GoogleMap(
          initialCameraPosition: position,
          mapType: MapType.normal,
          onMapCreated: (controller) {},
          markers: storeMarker(),
          gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>[
            new Factory<OneSequenceGestureRecognizer>(
              () => new EagerGestureRecognizer(),
            ),
          ].toSet()),

      // child: Image.network('${storeModel.pic}'),
    );
  }

  Widget showNoData(BuildContext context) =>
      MyStyle().titleCenter(context, 'ข้อมูล');
}
