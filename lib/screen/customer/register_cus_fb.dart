import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:nnotee/model/customer_model.dart';
import 'package:nnotee/screen/signin.dart';
import 'package:nnotee/utility/my_constant.dart';
import 'package:nnotee/utility/my_style.dart';
import 'package:nnotee/utility/normal_dialog.dart';
import 'package:nnotee/utility/signout_process.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'main_customer.dart';

class RegisTerCusFB extends StatefulWidget {
  final profile;
  const RegisTerCusFB({Key key, this.profile}) : super(key: key);

  @override
  _RegisTerCusFBState createState() => _RegisTerCusFBState();
}

class _RegisTerCusFBState extends State<RegisTerCusFB> {
  CustomerModel customerModel;

  Map _userData;
  String name, email, tel, pic, data, urlImage;
  String proname, proemail, protel, propic, prouser, propass;
  File file;
  var profile;

  @override
  void initState() {
    profile = widget.profile;
    name = profile['name'];
    email = profile['email'];
    super.initState();
  }

  Future<Null> checkAuthen() async {
    FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
    String token = await firebaseMessaging.getToken();
    String urlCustomer =
        '${MyConstant().domain}/mobile/getCustomerWhereUser.php?isAdd=true&user=${profile["id"]}';
    try {
      String urlCustomerToken =
          '${MyConstant().domain}/mobile/editTokenCus.php?isAdd=true&token=$token&username=${profile["id"]}';
      print(urlCustomerToken);
      await Dio().get(urlCustomerToken);
      Response response = await Dio().get(urlCustomer);
      print('res =$response');
      var result = json.decode(response.data);
      print('result = $result');
      if (result == null) {
        build(context);
      } else {
        for (var map in result) {
          CustomerModel customerModel = CustomerModel.fromJson(map);
          if (profile['id'] == customerModel.password) {
            //normalDialog(context, )
            routeToService(MainCustomer(), customerModel);
            Fluttertoast.showToast(
                msg: "สมัครสมาชิกและเข้าสู่ระบบ",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                timeInSecForIosWeb: 1);
          } else {
            normalDialog(context, 'Username หรือ Password ไม่ถูกต้อง');
          }
        }
      }
    } catch (e) {}
  }

  Future<Null> routeToService(
      Widget myWidget, CustomerModel customerModel) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setString('idcus', customerModel.id);
    preferences.setString('usernamecus', customerModel.username);
    preferences.setString('type', 'customer');
    MaterialPageRoute route = MaterialPageRoute(
      builder: (context) => myWidget,
    );
    Navigator.pushAndRemoveUntil(context, route, (route) => false);
  }

  Future<Null> checkEmail() async {
    String url =
        '${MyConstant().domain}/mobile/getCustomerWhereEmail.php?isAdd=true&email=$email';
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
        '${MyConstant().domain}/mobile/getCustomerWhereTel.php?isAdd=true&tel=$tel';
    try {
      Response response = await Dio().get(url);
      print('res = $response');
      if (response.toString() == 'null') {
        if (file == null) {
          registerThread();
        } else {
          registerThreadNormal();
        }
      } else {
        normalDialog(context,
            'เบอร์โทรศัพท์ $tel ถูกใช้งานแล้วกรุณาเปลี่ยน เบอร์โทรศัพท์ ใหม่');
      }
    } catch (e) {}
  }

  Future<Null> registerThread() async {
    print(profile["name"]);
    print(profile["id"]);
    print(email);
    print(tel);
    print(profile["picture"]["data"]["url"]);
    String url =
        "${MyConstant().domain}/mobile/addCustomer.php?isAdd=true&Name=$name&User=${profile['id']}&Password=${profile['id']}&email=$email&tel=$tel&urlImage=${Uri.encodeComponent(profile['picture']['data']['url'])}";
    print(url);
    try {
      Response response = await Dio().get(url);
      print('res = $response');
      if (response.toString() == 'true') {
        checkAuthen();
      } else {
        normalDialog(context, 'ไม่สามารถสมัครได้');
      }
    } catch (e) {
      print(e);
    }
  }

  Future<Null> registerThreadNormal() async {
    String url =
        '${MyConstant().domain}/mobile/addCustomer.php?isAdd=true&Name=$name&User=${profile["id"]}&Password=${profile["id"]}&email=$email&tel=$tel&urlImage=$urlImage';
    print(url);
    try {
      Response response = await Dio().get(url);
      print('res = $response');
      if (response.toString() == 'true') {
        checkAuthen();
      } else {
        normalDialog(context, 'ไม่สามารถสมัครได้');
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: profile == null
          ? LinearProgressIndicator()
          : SingleChildScrollView(
              child: Center(
                child: Column(children: <Widget>[
                  SizedBox(
                    height: 40,
                  ),
                  imageUploader(),
                  nameForm(),
                  emailForm(),
                  telForm(),
                  registerButton()
                ]),
              ),
            ),
      appBar: AppBar(
        title: Text(
          'สมัครสมาชิกของลูกค้า',
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

  Widget nameForm() => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            margin: EdgeInsets.only(top: 16.0),
            width: 320.0,
            child: TextFormField(
              onChanged: (value) => name = value,
              initialValue: profile['name'],
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.account_circle_sharp),
                labelText: 'ชื่อ',
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
            child: TextFormField(
              onChanged: (value) => email = value,
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
                '${profile["picture"]["data"]["url"]}',
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

  Future<Null> uploadImage() async {
    Random random = Random();
    int i = random.nextInt(100000000);
    String nameImage = 'customer$i.jpg';

    String url = '${MyConstant().domain}/mobile/saveFileCustomer.php';
    try {
      Map<String, dynamic> map = Map();
      map['file'] =
          await MultipartFile.fromFile(file.path, filename: nameImage);

      FormData formData = FormData.fromMap(map);
      await Dio().post(url, data: formData).then((value) {
        print('Response = $value');
        urlImage = '${MyConstant().domain}/mobile/Customer/$nameImage';
        print('urlImage = $urlImage');
        checkEmail();
      });
    } catch (e) {}
  }

  Widget registerButton() => Container(
        width: 250,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadiusDirectional.circular(10))),
          onPressed: () {
            // print(
            //     'name = $name , user = $user , password = $password , e-mail = $email , tel = $tel');
            if (name == null ||
                name.isEmpty ||
                email == null ||
                email.isEmpty ||
                tel == null ||
                tel.isEmpty) {
              normalDialog(context, 'กรุณากรอกข้อมูลให้ครบถ้วน');
            } else if (file == null) {
              checkEmail();
            } else {
              uploadImage();
            }
          },
          child: Text(
            'สมัครสมาชิก',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
}
