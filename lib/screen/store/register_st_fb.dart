import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:location/location.dart';
import 'package:nnotee/model/store_model.dart';
import 'package:nnotee/utility/my_constant.dart';
import 'package:nnotee/utility/my_style.dart';
import 'package:nnotee/utility/normal_dialog.dart';

class RegisterStoreFB extends StatefulWidget {
  final profile;
  const RegisterStoreFB({Key key, this.profile}) : super(key: key);

  @override
  _RegisterStoreFBState createState() => _RegisterStoreFBState();
}

class _RegisterStoreFBState extends State<RegisterStoreFB> {
  String name, user, password, email, tel, urlImage;
  double latitude, longitude;
  File file;
  Location newlocation = Location();
  var profile;
  BitmapDescriptor pinLocationIcon;
  @override
  void initState() {
    profile = widget.profile;
    email = profile['email'];
    findLatLng();
    super.initState();
    BitmapDescriptor.fromAssetImage(
      ImageConfiguration(devicePixelRatio: 1.5),
      'images/mymarkermini.png',
    ).then((onValue) {
      pinLocationIcon = onValue;
    });
  }

  Future<Null> findLatLng() async {
    LocationData locationData = await findLocationData();
    setState(() {
      latitude = locationData.latitude;
      longitude = locationData.longitude;
    });
    print('lat =$latitude, lng = $longitude');
  }

  Future<LocationData> findLocationData() async {
    Location location = Location();
    try {
      return location.getLocation();
    } catch (e) {
      return null;
    }
  }

  Future<Null> checkAuthen() async {
    String urlStore =
        '${MyConstant().domain}/mobile/getStoreWhereUser.php?isAdd=true&user=${profile["id"]}';
    try {
      Response response = await Dio().get(urlStore);
      print('res =$response');
      var result = json.decode(response.data);
      print('result = $result');
      if (result == null) {
        build(context);
      } else {
        for (var map in result) {
          StoreModel storeModel = StoreModel.fromJson(map);
          if (profile['id'] == storeModel.password) {
            //normalDialog(context, )
            Navigator.pop(context);
          } else {
            normalDialog(context, 'Username หรือ Password ไม่ถูกต้อง');
          }
        }
      }
    } catch (e) {}
  }

  Future<Null> checkEmail() async {
    String url =
        '${MyConstant().domain}/mobile/getStoreWhereEmail.php?isAdd=true&email=$email';
    try {
      Response response = await Dio().get(url);
      print('res = $response');
      if (response.toString() == 'null') {
        checkTel();
      } else {
        normalDialog(
            context, 'E-mail $email ถูกใช้งานแล้วกรุณาเปลี่ยน E-mail ใหม่');
      }
    } catch (e) {}
  }

  Future<Null> checkTel() async {
    String url =
        '${MyConstant().domain}/mobile/getStoreWhereTel.php?isAdd=true&tel=$tel';
    try {
      Response response = await Dio().get(url);
      print('res = $response');
      if (response.toString() == 'null') {
        registerThread();
      } else {
        normalDialog(context,
            'เบอร์โทรศัพท์ $tel ถูกใช้งานแล้วกรุณาเปลี่ยน เบอร์โทรศัพท์ ใหม่');
      }
    } catch (e) {}
  }

  Future<Null> registerThread() async {
    String url =
        '${MyConstant().domain}/mobile/addStore.php?isAdd=true&Name=$name&User=${profile["id"]}&Password=${profile["id"]}&email=$email&latitude=$latitude&tel=$tel&longitude=$longitude&urlImage=$urlImage';
    try {
      print(url);
      Response response = await Dio().get(url);
      print('res = $response');
      if (response.toString() == 'true') {
        Navigator.pop(context);
        Fluttertoast.showToast(
            msg: "สมัครสมาชิกสำเร็จแล้ว",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1);
      } else {
        normalDialog(context, 'ไม่สามารถสมัครได้');
      }
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
              color: Colors.black38,
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(
                Icons.arrow_back_ios_new_outlined,
              )),
          title: Text('ร้านซ่อมรถ', style: TextStyle(color: Colors.black38)),
        ),
        body: SingleChildScrollView(
            child: Center(
                child: Column(children: <Widget>[
          SizedBox(
            height: 40,
          ),
          imageUploader(),
          MyStyle().mySizebox(),
          showAppname(),
          MyStyle().mySizebox(),
          nameForm(),
          MyStyle().mySizebox(),
          emailForm(),
          MyStyle().mySizebox(),
          telForm(),
          MyStyle().mySizebox(),
          Column(
            children: [
              Container(
                  width: 500,
                  decoration: BoxDecoration(color: Colors.black38),
                  child: Row(
                    children: [
                      Icon(Icons.report),
                      SizedBox(
                        width: 300,
                        child: Text(
                            'ปักหมุดร้านซ่อมของท่านด้านล่างนี้ หมุดสามารถย้ายจุดได้โดยการกดค้างที่หมุดและลาก'),
                      )
                    ],
                  )),
            ],
          ),
          MyStyle().mySizebox(),
          // latitudeForm(),
          // MyStyle().mySizebox(),
          // longitudeForm(),
          // MyStyle().mySizebox(),
          latitude == null ? MyStyle().showProgess() : showMap(),
          MyStyle().mySizebox(),
          registerButton(),
        ]))));
  }

  imageUploader() {
    return Stack(
      children: [
        imageProfile(),
        imageIcon(),
      ],
    );
  }

  Widget alertImageDialog() => SimpleDialog(
        title: Text('รูปที่ท่านเลือกต้องเป็นรูปหน้าร้านเท่านั้น'),
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _onEditPressed();
                  },
                  child: Text('ตกลง')),
            ],
          )
        ],
      );

  Widget alertRegisDialog() => SimpleDialog(
        title: Text(
            'ท่านจะยังไม่สามรถเข้าสู่ระบบได้จนกว่าผู้ดูแลจะทำการยืนยันร้านซ่อมของท่าน'),
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    uploadImage();
                  },
                  child: Text('ตกลง')),
            ],
          )
        ],
      );

  imageProfile() {
    return ClipOval(
      child: InkWell(
        child: file == null
            ? Image.asset(
                'images/imageplus5.png',
                height: 128,
                width: 128,
                fit: BoxFit.cover,
              )
            : Image.file(
                file,
                height: 128,
                width: 128,
                fit: BoxFit.cover,
              ),
        onTap: () {
          showDialog(
              barrierDismissible: false,
              context: context,
              builder: (context) => alertImageDialog());
        },
      ),
    );
  }

  imageIcon() {
    return Positioned(
        bottom: 0,
        right: 4,
        child: ClipOval(
          child: Container(
            padding: EdgeInsets.all(3),
            color: Colors.white,
            child: ClipOval(
              child: Container(
                padding: EdgeInsets.all(8),
                color: Colors.blue,
                child: Icon(
                  Icons.edit,
                  size: 20,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ));
  }

  void _onEditPressed() {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return Container(
            height: 150,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  leading: Icon(Icons.add_a_photo),
                  title: Text('กล้องถ่ายภาพ'),
                  onTap: () {
                    chooseImage(ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.add_photo_alternate),
                  title: Text('แกลเลอรี่'),
                  onTap: () {
                    chooseImage(ImageSource.gallery);
                  },
                )
              ],
            ),
          );
        });
  }

  Widget selectImageDialog() => SimpleDialog(
        title: Text('กรุณาเลือกแหล่งที่มาของภาพ'),
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              IconButton(
                  onPressed: () => chooseImage(ImageSource.camera),
                  icon: Icon(
                    Icons.add_a_photo,
                    size: 36.0,
                  )),
              TextButton(
                  onPressed: () => chooseImage(ImageSource.camera),
                  child: Text('กล้องภ่ายภาพ')),
              IconButton(
                  onPressed: () => chooseImage(ImageSource.gallery),
                  icon: Icon(
                    Icons.add_photo_alternate,
                    size: 36.0,
                  )),
              TextButton(
                  onPressed: () => chooseImage(ImageSource.gallery),
                  child: Text('แกลเลอรี่')),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [],
              ),
            ],
          )
        ],
      );

  Future<Null> uploadImage() async {
    Random random = Random();
    int i = random.nextInt(100000000);
    String nameImage = 'store$i.jpg';

    String url = '${MyConstant().domain}/mobile/saveFileStore.php';
    try {
      Map<String, dynamic> map = Map();
      map['file'] =
          await MultipartFile.fromFile(file.path, filename: nameImage);

      FormData formData = FormData.fromMap(map);
      await Dio().post(url, data: formData).then((value) {
        print('Response = $value');
        urlImage = '${MyConstant().domain}/mobile/Store/$nameImage';
        print('urlImage = $urlImage');
        checkEmail();
      });
    } catch (e) {}
  }

  Future<Null> chooseImage(ImageSource imageSource) async {
    try {
      var object = await ImagePicker.platform
          .pickImage(source: imageSource, maxWidth: 800.0, maxHeight: 800.0);
      setState(() {
        file = File(object.path);
        Navigator.pop(context);
      });
    } catch (e) {}
  }

  Set<Marker> myMarker() {
    return <Marker>[
      Marker(
          onTap: () {
            print('tapped');
          },
          draggable: true,
          markerId: MarkerId('store'),
          position: LatLng(latitude, longitude),
          icon: pinLocationIcon,
          onDragEnd: (location) {
            print(location.latitude);
            print(location.longitude);
            setState(() {
              latitude = location.latitude;
              longitude = location.longitude;
            });
          },
          infoWindow: InfoWindow(
              title: 'ร้านซ่อมของคุณ',
              snippet: 'latitude= $latitude , longitude= $longitude')),
    ].toSet();
  }

  Container showMap() {
    LatLng latLng = LatLng(latitude, longitude);
    CameraPosition cameraPosition = CameraPosition(
      target: latLng,
      zoom: 16.0,
      bearing: 192.8334901395799,
    );
    return Container(
      height: 300.0,
      child: GoogleMap(
          initialCameraPosition: cameraPosition,
          mapType: MapType.normal,
          onMapCreated: (controller) {},
          markers: myMarker(),
          gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>[
            new Factory<OneSequenceGestureRecognizer>(
              () => new EagerGestureRecognizer(),
            ),
          ].toSet()),
    );
  }

  Widget nameForm() => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            margin: EdgeInsets.only(top: 16.0),
            width: 320.0,
            height: 50.0,
            child: TextFormField(
              onChanged: (value) => name = value,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.account_circle_sharp),
                labelText: 'ชื่อร้านซ่อม',
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue)),
              ),
            ),
          ),
        ],
      );

  Widget emailForm() => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            margin: EdgeInsets.only(top: 16.0),
            width: 320.0,
            height: 50.0,
            child: TextFormField(
              onChanged: (value) => email = value.trim(),
              initialValue: profile['email'],
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.email),
                labelText: 'E-mail',
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue)),
              ),
            ),
          ),
        ],
      );

  Widget telForm() => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            margin: EdgeInsets.only(top: 16.0),
            width: 320.0,
            height: 50.0,
            child: TextField(
              inputFormatters: [
                LengthLimitingTextInputFormatter(10),
              ],
              keyboardType: TextInputType.phone,
              onChanged: (value) => tel = value.trim(),
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.phone),
                labelText: 'เบอร์โทร',
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue)),
              ),
            ),
          ),
        ],
      );
  Widget registerButton() => Container(
        width: 250,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadiusDirectional.circular(10))),
          onPressed: () {
            print(
                'name = $name , user = $user , password = $password , e-mail = $email , tel = $tel ,latitude = $latitude , longitude = $longitude');
            if (name == null ||
                    name.isEmpty ||
                    email == null ||
                    email.isEmpty ||
                    tel == null ||
                    tel.isEmpty
                // latitude == null ||
                // latitude.isEmpty ||
                // longitude == null ||
                // longitude.isEmpty
                ) {
              normalDialog(context, 'กรุณากรอกข้อมูลให้ครบถ้วน');
            } else if (file == null) {
              normalDialog(context, 'กรุณาเลือกรูปภาพ');
            } else {
              showDialog(
                  barrierDismissible: true,
                  context: context,
                  builder: (context) => alertRegisDialog());
            }
          },
          child: Text(
            'สมัครสมาชิก',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );

  Column showAppname() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        MyStyle().showTitle('กรุณากรอกข้อมูล'),
        MyStyle().showTitle('ให้ครบถ้วน'),
      ],
    );
  }
}
