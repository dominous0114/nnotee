import 'dart:convert';
//import 'dart:ffi';
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
import 'package:nnotee/utility/banstore.dart';
import 'package:nnotee/utility/my_constant.dart';
import 'package:nnotee/utility/my_style.dart';
import 'package:nnotee/utility/normal_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditInfoStore extends StatefulWidget {
  @override
  _EditInfoStoreState createState() => _EditInfoStoreState();
}

class _EditInfoStoreState extends State<EditInfoStore> {
  StoreModel storeModel;
  String name, user, password, email, tel, urlImage, detail;
  double latitude, longitude;
  Location location = Location();
  File file;
  BitmapDescriptor pinLocationIcon;
  @override
  void initState() {
    super.initState();
    readCurrentInfo();
    BanStore().readdataBan(context);
    BitmapDescriptor.fromAssetImage(
      ImageConfiguration(devicePixelRatio: 1.5),
      'images/mymarkermini.png',
    ).then((onValue) {
      pinLocationIcon = onValue;
    });
  }

  Future<Null> readCurrentInfo() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String idst = preferences.getString('idst');
    print('idStore = $idst');

    String url =
        '${MyConstant().domain}/mobile/getStoreWhereId.php?isAdd=true&id=$idst';

    Response response = await Dio().get(url);
    var result = json.decode(response.data);
    print('response = $response');
    print('result = $result');

    for (var map in result) {
      setState(() {
        storeModel = StoreModel.fromJson(map);
        name = storeModel.name;
        email = storeModel.email;
        tel = storeModel.tel;
        urlImage = storeModel.pic;
        detail = storeModel.detail;
        latitude = double.parse(storeModel.latitude);
        longitude = double.parse(storeModel.longitude);
      });
    }
  }

  Future<Null> editWithoutPic() async {
    String id = storeModel.id;
    String url =
        '${MyConstant().domain}/mobile/editStoreWithoutPic.php?isAdd=true&id=$id&Name=$name&email=$email&tel=$tel&latitude=$latitude&longitude=$longitude&detail=$detail';

    Response response = await Dio().get(url);
    print(
        'response = **************************************$response***********************************************');
    if (response.toString() == 'true') {
      Navigator.pop(context);
    } else {
      normalDialog(context, 'กรุณาลองอีกครั้ง');
    }
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

  Future<Null> editThread() async {
    Random random = Random();
    int i = random.nextInt(100000000);
    String nameFile = 'editStore$i.jpg';
    Map<String, dynamic> map = Map();
    map['file'] = await MultipartFile.fromFile(file.path, filename: nameFile);
    FormData formData = FormData.fromMap(map);
    String urlUpload = '${MyConstant().domain}/mobile/saveFileStore.php';
    await Dio().post(urlUpload, data: formData).then((value) async {
      urlImage = '${MyConstant().domain}/mobile/Store/$nameFile';
      String id = storeModel.id;

      //print('id = $id');
      String url =
          '${MyConstant().domain}/mobile/editStoreWhereId.php?isAdd=true&id=$id&Name=$name&email=$email&tel=$tel&urlImage=$urlImage&latitude=$latitude&longitude=$longitude&detail=$detail';

      Response response = await Dio().get(url);
      print(
          'response = **************************************$response***********************************************');
      if (response.toString() == 'true') {
        Navigator.pop(context);
      } else {
        normalDialog(context, 'กรุณาลองอีกครั้ง');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: storeModel == null ? MyStyle().showProgess() : showContent(),
      appBar: AppBar(
        title: Text(
          'แก้ไขข้อมูลร้าน',
          style: TextStyle(color: Colors.black38),
        ),
        leading: IconButton(
            color: Colors.black38,
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.arrow_back_ios_new_outlined,
            )),
      ),
    );
  }

  Widget showContent() => SingleChildScrollView(
        child: Center(
          child: Column(
            children: <Widget>[
              SizedBox(
                height: 40,
              ),
              imageUploader(),
              nameForm(),
              emailForm(),
              telForm(),
              detailForm(),
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
                                'หมุดสามารถย้ายจุดได้โดยการกดค้างที่หมุดและลาก'),
                          )
                        ],
                      )),
                ],
              ),
              latitude == null
                  ? MyStyle().showProgess()
                  : Stack(
                      children: [
                        showMap(),
                      ],
                    ),
              editButton()
            ],
          ),
        ),
      );

  Widget editButton() => Container(
        width: 250,
        child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadiusDirectional.circular(10))),
            onPressed: () => confirmDialog(),
            icon: Icon(Icons.edit),
            label: Text('แก้ไข')),
      );

  Future<Null> confirmDialog() async {
    showDialog(
        context: context,
        builder: (context) => SimpleDialog(
              title:
                  Container(width: 15, child: Text('คุณต้องการแก้ไขข้อมูล? ')),
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('ปฏิเสธ')),
                    SizedBox(
                      width: 25,
                    ),
                    TextButton(
                      onPressed: () {
                        if (name == null ||
                            name.isEmpty ||
                            email == null ||
                            email.isEmpty ||
                            tel == null ||
                            tel.isEmpty) {
                          normalDialog(context, 'กรุณากรอกข้อมูลให้ครบถ้วน');
                        } else {
                          if (file == null) {
                            editWithoutPic();
                            Fluttertoast.showToast(
                                msg: "แก้ไขเรียบร้อยแล้ว",
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.BOTTOM,
                                timeInSecForIosWeb: 1);
                          } else {
                            Fluttertoast.showToast(
                                msg: "แก้ไขเรียบร้อยแล้ว",
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.BOTTOM,
                                timeInSecForIosWeb: 1);
                            editThread();
                          }
                          Navigator.pop(context);
                        }
                      },
                      child: Text('ตกลง'),
                    ),
                  ],
                )
              ],
            ));
  }

  Set<Marker> currentMarker() {
    return <Marker>[
      Marker(
          draggable: true,
          markerId: MarkerId('myMarker'),
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
              title: 'ร้านซ่อมรถของคุณ',
              snippet: 'latitude = $latitude, longitude = $longitude'))
    ].toSet();
  }

  Container showMap() {
    CameraPosition cameraPosition = CameraPosition(
      target: LatLng(latitude, longitude),
      zoom: 16.0,
    );

    return Container(
      margin: EdgeInsets.only(top: 16.0, bottom: 10),
      height: 200.0,
      width: 400,
      child: GoogleMap(
          initialCameraPosition: cameraPosition,
          mapType: MapType.normal,
          onMapCreated: (controller) {},
          markers: currentMarker(),
          gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>[
            new Factory<OneSequenceGestureRecognizer>(
              () => new EagerGestureRecognizer(),
            ),
          ].toSet()),
    );
  }

  imageUploader() {
    return Stack(
      children: [
        imageProfile(),
        imageIcon(),
      ],
    );
  }

  imageProfile() {
    return ClipOval(
      child: InkWell(
        child: file == null
            ? Image.network(
                '$urlImage',
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
          _onEditPressed();
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

  Future<Null> chooseImage(ImageSource source) async {
    try {
      var object = await ImagePicker.platform
          .pickImage(source: source, maxWidth: 800.0, maxHeight: 800.0);

      setState(() {
        file = File(object.path);
        Navigator.pop(context);
      });
    } catch (e) {}
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

  Widget nameForm() => Container(
        margin: EdgeInsets.only(top: 30.0, bottom: 10),
        width: 250.0,
        child: TextFormField(
          onChanged: (value) => name = value,
          initialValue: storeModel.name,
          decoration: InputDecoration(
              border: OutlineInputBorder(), labelText: 'ชื่อของร้านซ่อม'),
        ),
      );

  Widget emailForm() => Container(
        margin: EdgeInsets.only(top: 16.0, bottom: 10),
        width: 250.0,
        child: TextFormField(
          onChanged: (value) => email = value,
          initialValue: storeModel.email,
          decoration: InputDecoration(
              border: OutlineInputBorder(), labelText: 'E-mail ของร้านซ่อม'),
        ),
      );

  Widget telForm() => Container(
        margin: EdgeInsets.only(top: 16.0, bottom: 10),
        width: 250.0,
        child: TextFormField(
          inputFormatters: [
            LengthLimitingTextInputFormatter(10),
          ],
          keyboardType: TextInputType.phone,
          onChanged: (value) => tel = value,
          initialValue: storeModel.tel,
          decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'เบอร์โทรศัพท์ของร้านซ่อม'),
        ),
      );

  Widget detailForm() => Container(
        margin: EdgeInsets.only(top: 16.0, bottom: 10),
        width: 300.0,
        child: TextFormField(
          keyboardType: TextInputType.multiline,
          inputFormatters: [
            LengthLimitingTextInputFormatter(250),
          ],
          maxLines: 10,
          onChanged: (value) => detail = value,
          initialValue: storeModel.detail,
          decoration: InputDecoration(
              border: OutlineInputBorder(), labelText: 'รายละเอียดของร้านซ่อม'),
        ),
      );
}
