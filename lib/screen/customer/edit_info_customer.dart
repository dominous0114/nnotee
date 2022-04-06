import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nnotee/model/customer_model.dart';
import 'package:nnotee/utility/my_constant.dart';
import 'package:nnotee/utility/my_style.dart';
import 'package:nnotee/utility/normal_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditInfoCustomer extends StatefulWidget {
  @override
  _EditInfoCustomerState createState() => _EditInfoCustomerState();
}

class _EditInfoCustomerState extends State<EditInfoCustomer> {
  CustomerModel customerModel;
  String name, user, password, email, tel, urlImage;
  File file;

  @override
  void initState() {
    readCurrentInfo();
    super.initState();
  }

  Future<Null> readCurrentInfo() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String idcus = preferences.getString('idcus');
    print('idCustomer = $idcus');

    String url =
        '${MyConstant().domain}/mobile/getCustomerWhereId.php?isAdd=true&id=$idcus';

    Response response = await Dio().get(url);
    var result = json.decode(response.data);
    print('response = $response');
    print('result = $result');

    for (var map in result) {
      setState(() {
        customerModel = CustomerModel.fromJson(map);
        name = customerModel.name;
        email = customerModel.email;
        tel = customerModel.tel;
        urlImage = customerModel.pic;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'แก้ไขข้อมูลส่วนตัว',
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
      body: customerModel == null ? MyStyle().showProgess() : showContent(),
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
              SizedBox(
                height: 20,
              ),
              editButton(),
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

  Future<Null> editWithoutPic() async {
    String id = customerModel.id;
    String url =
        '${MyConstant().domain}/mobile/editCustomerWithoutPic.php?isAdd=true&id=$id&Name=$name&email=$email&tel=$tel';

    Response response = await Dio().get(url);
    print(
        'response = **************************************$response***********************************************');
    if (response.toString() == 'true') {
      Navigator.pop(context);
    } else {
      normalDialog(context, 'กรุณาลองอีกครั้ง');
    }
  }

  Future<Null> editThread() async {
    Random random = Random();
    int i = random.nextInt(100000000);
    String nameFile = 'editCustomer$i.jpg';
    Map<String, dynamic> map = Map();
    map['file'] = await MultipartFile.fromFile(file.path, filename: nameFile);
    FormData formData = FormData.fromMap(map);
    String urlUpload = '${MyConstant().domain}/mobile/saveFileCustomer.php';
    await Dio().post(urlUpload, data: formData).then((value) async {
      urlImage = '${MyConstant().domain}/mobile/Customer/$nameFile';
      String id = customerModel.id;

      //print('id = $id');
      String url =
          '${MyConstant().domain}/mobile/editCustomerWhereId.php?isAdd=true&id=$id&Name=$name&email=$email&tel=$tel&urlImage=$urlImage';

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

  Widget nameForm() => Container(
        margin: EdgeInsets.only(top: 30.0, bottom: 10),
        width: 250.0,
        child: TextFormField(
          inputFormatters: [
            LengthLimitingTextInputFormatter(20),
          ],
          onChanged: (value) => name = value,
          initialValue: customerModel.name,
          decoration:
              InputDecoration(border: OutlineInputBorder(), labelText: 'ชื่อ'),
        ),
      );

  Widget emailForm() => Container(
        margin: EdgeInsets.only(top: 16.0, bottom: 10),
        width: 250.0,
        child: TextFormField(
          onChanged: (value) => email = value,
          initialValue: customerModel.email,
          decoration: InputDecoration(
              border: OutlineInputBorder(), labelText: 'E-mail '),
        ),
      );

  Widget telForm() => Container(
        margin: EdgeInsets.only(top: 16.0, bottom: 10),
        width: 250.0,
        child: TextFormField(
          inputFormatters: [
            LengthLimitingTextInputFormatter(10),
          ],
          onChanged: (value) => tel = value,
          initialValue: customerModel.tel,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
              border: OutlineInputBorder(), labelText: 'เบอร์โทรศัพท์'),
        ),
      );
}
