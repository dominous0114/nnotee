import 'dart:io';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nnotee/utility/my_constant.dart';
import 'package:nnotee/utility/my_style.dart';
import 'package:nnotee/utility/normal_dialog.dart';

class Register extends StatefulWidget {
  @override
  _RegisterState createState() => _RegisterState();
}

TextEditingController _ctrlMess = TextEditingController();

class _RegisterState extends State<Register> {
  String name, user, password, email, tel, urlImage;
  File file;
  bool _obscureText = true;

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
          title: Text(
            'ลูกค้า',
            style: TextStyle(color: Colors.black38),
          ),
        ),
        body: SingleChildScrollView(
            child: Center(
          child: Column(
            children: <Widget>[
              SizedBox(
                height: 40,
              ),
              imageUploader(),
              MyStyle().mySizebox(),
              showAppname(),
              MyStyle().mySizebox(),
              nameForm(),
              MyStyle().mySizebox(),
              usernameForm(),
              MyStyle().mySizebox(),
              passwordForm(),
              MyStyle().mySizebox(),
              emailForm(),
              MyStyle().mySizebox(),
              telForm(),
              MyStyle().mySizebox(),
              registerButton(),
            ],
          ),
        )));
  }

  Widget registerButton() => Container(
        width: 250,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadiusDirectional.circular(10))),
          onPressed: () {
            print(
                'name = $name , user = $user , password = $password , e-mail = $email , tel = $tel');
            if (name == null ||
                name.isEmpty ||
                user == null ||
                user.isEmpty ||
                password == null ||
                password.isEmpty ||
                email == null ||
                email.isEmpty ||
                tel == null ||
                tel.isEmpty) {
              normalDialog(context, 'กรุณากรอกข้อมูลให้ครบถ้วน');
            } else if (file == null) {
              normalDialog(context, 'กรุณาเลือกรูปภาพ');
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

  Future<Null> checkUser() async {
    String url =
        '${MyConstant().domain}/mobile/getCustomerWhereUser.php?isAdd=true&user=$user';
    try {
      Response response = await Dio().get(url);
      print('res = $response');
      if (response.toString() == 'null') {
        checkEmail();
      } else {
        normalDialog(context, 'User $user ถูกใช้งานแล้วกรุณาเปลี่ยน User ใหม่');
      }
    } catch (e) {}
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
        registerThread();
      } else {
        normalDialog(context,
            'เบอร์โทรศัพท์ $tel ถูกใช้งานแล้วกรุณาเปลี่ยน เบอร์โทรศัพท์ ใหม่');
      }
    } catch (e) {}
  }

  Future<Null> registerThread() async {
    String url =
        '${MyConstant().domain}/mobile/addCustomer.php?isAdd=true&Name=$name&User=$user&Password=$password&email=$email&tel=$tel&urlImage=$urlImage';
    try {
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
    } catch (e) {
      print(e);
    }
  }

  Widget nameForm() => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 250.0,
            child: TextField(
              inputFormatters: [
                LengthLimitingTextInputFormatter(20),
              ],
              onChanged: (value) => name = value.trim(),
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.account_circle_sharp),
                hintText: 'ชื่อลูกค้า',
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue)),
              ),
            ),
          ),
        ],
      );

  Widget usernameForm() => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 250.0,
            child: TextField(
              inputFormatters: [
                LengthLimitingTextInputFormatter(20),
              ],
              onChanged: (value) => user = value.trim(),
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.account_box),
                hintText: 'ชื่อผู้ใช้',
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue)),
              ),
            ),
          ),
        ],
      );

  Widget passwordForm() => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
              width: 250.0,
              child: TextField(
                inputFormatters: [
                  LengthLimitingTextInputFormatter(20),
                ],
                onChanged: (value) => password = value.trim(),
                obscureText: _obscureText,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.lock),
                  hintText: 'รหัสผ่าน',
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue)),
                  suffixIcon: new GestureDetector(
                    onTap: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                    child: new Icon(
                        _obscureText ? Icons.visibility : Icons.visibility_off),
                  ),
                ),
              )),
        ],
      );

  Widget emailForm() => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 250.0,
            child: TextFormField(
              onChanged: (value) => email = value.trim(),
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.email_rounded),
                hintText: 'อีเมล',
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
            width: 250.0,
            child: TextField(
              inputFormatters: [
                LengthLimitingTextInputFormatter(10),
              ],
              keyboardType: TextInputType.phone,
              onChanged: (value) => tel = value.trim(),
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.phone),
                hintText: 'เบอร์โทร',
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue)),
              ),
            ),
          ),
        ],
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
            ? Image.asset(
                'images/imageplus4.png',
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

  // Row groupImage() {
  //   return Row(
  //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //     children: <Widget>[
  //       IconButton(
  //         icon: Icon(
  //           Icons.add_a_photo,
  //           size: 36.0,
  //         ),
  //         onPressed: () => chooseImage(ImageSource.camera),
  //       ),
  //       Container(
  //         width: 125.0,
  //         child: file == null
  //             ? Image.asset('images/addshopimage.png')
  //             : Image.file(file),
  //       ),
  //       IconButton(
  //         icon: Icon(
  //           Icons.add_photo_alternate,
  //           size: 36.0,
  //         ),
  //         onPressed: () => chooseImage(ImageSource.gallery),
  //       )
  //     ],
  //   );
  // }

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
        checkUser();
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
}
