import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';
import 'package:nnotee/model/store_model.dart';
import 'package:nnotee/utility/my_constant.dart';
import 'package:nnotee/utility/normal_dialog.dart';
//import 'package:http/http.dart' as http;

class ResetPasswordStore extends StatefulWidget {
  const ResetPasswordStore({Key key}) : super(key: key);

  @override
  _ResetPasswordStoreState createState() => _ResetPasswordStoreState();
}

StoreModel storeModel;
String email;

class _ResetPasswordStoreState extends State<ResetPasswordStore> {
  @override
  void initState() {
    super.initState();
  }

  sendMail() async {
    String username = 'icedate555@gmail.com';
    String password = 'nnnn0823049859';

    final smtpServer = gmail(username, password);
    // Use the SmtpServer class to configure an SMTP server:
    // final smtpServer = SmtpServer('smtp.domain.com');
    // See the named arguments of SmtpServer for further configuration
    // options.

    //Create our message.
    final message = Message()
      ..from = Address(username, 'MotoCare')
      ..recipients.add('${storeModel.email}')
      //..ccRecipients.addAll(['destCc1@example.com', 'destCc2@example.com'])
      //..bccRecipients.add(Address('bccAddress@example.com'))
      ..subject = 'แก้ไขรหัสผ่านจาก Motocare'
      ..text = 'This is the plain text.\nThis is line 2 of the text part.'
      ..html =
          '<h1>แก้ไขรหัสผ่าน</h1>\n<h2>สวัสดีคุณ ${storeModel.name}</h2>\n<p><a href="${MyConstant().domain}/mobile/editPasswordCus.php?isAdd=true&email=${storeModel.email}">คลิกที่นี่เพื่อเปลี่ยน Password</a></p>';

    try {
      final sendReport = await send(message, smtpServer);
      print(sendReport.toString());
      if (message.toString() == 'Message successfully sent.') {
        normalDialog(context, 'กรุณาตรวจสอบ E-mail');
      }
    } on MailerException catch (e) {
      print(e);
      print('Message not sent.');
      for (var p in e.problems) {
        print('Problem: ${p.code}: ${p.msg}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            color: Colors.black38,
            onPressed: () {
              setState(() {
                email = null;
              });
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.arrow_back_ios_new_outlined,
            )),
        title: Text("แก้ไขรหัสผ่าน"),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 80.0,
          ),
          Text('กรุณากรอก E-mail ให้ถูกต้อง'),
          emailForm(),
          SizedBox(
            height: 15.0,
          ),
          checkButton()
        ],
      ),
    );
  }

  Widget checkButton() => Container(
        width: 250,
        child: ElevatedButton(
          onPressed: () {
            print('*******************$email');
            if (email == null || email.isEmpty) {
              normalDialog(context, 'กรุณากรอก E-mail');
            } else {
              readDataStore();
            }
          },
          child: Text(
            'ส่งข้อมูลไปยัง E-mail',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );

  Widget emailForm() => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 300.0,
            child: TextField(
              onChanged: (value) => email = value.trim(),
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.email_rounded),
                hintText: 'E-mail',
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue)),
              ),
            ),
          ),
        ],
      );

  Future<Null> readDataStore() async {
    print(email);
    String url =
        '${MyConstant().domain}/mobile/getStoreWhereEmail.php?isAdd=true&email=$email';
    try {
      await Dio().get(url).then((value) {
        print('value = $value');
        var result = json.decode(value.data);
        print(value.data);
        print(result);
        if (value.data == 'null') {
          normalDialog(context, 'ไม่พบ E-mail นี้กรุณาลองอีกครั้ง');
        } else
          for (var map in result) {
            setState(() {
              //email = customerModel.email;
              storeModel = StoreModel.fromJson(map);
              sendMail();
              email = null;
              Navigator.pop(context);
              Fluttertoast.showToast(
                  msg: "E-mail is sent",
                  toastLength: Toast.LENGTH_LONG,
                  gravity: ToastGravity.BOTTOM,
                  timeInSecForIosWeb: 3);
            });
            print('name =${storeModel.email}');
          }
      });
    } catch (e) {}
  }
}
