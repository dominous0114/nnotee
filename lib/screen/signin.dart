import 'dart:convert';
//import 'dart:ffi';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nnotee/model/customer_model.dart';
import 'package:nnotee/model/store_model.dart';
import 'package:nnotee/screen/customer/main_customer.dart';
import 'package:nnotee/screen/customer/register_cus_fb.dart';
import 'package:nnotee/screen/customer/resetpw_customer.dart';
import 'package:nnotee/screen/register.dart';

import 'package:nnotee/screen/store/main_store.dart';
import 'package:nnotee/screen/store/register_st.dart';
import 'package:nnotee/screen/store/register_st_fb.dart';
import 'package:nnotee/screen/store/resetpw_store.dart';
import 'package:nnotee/utility/my_constant.dart';
import 'package:nnotee/utility/my_style.dart';
import 'package:nnotee/utility/normal_dialog.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:http/http.dart' as http;

class SignIn extends StatefulWidget {
  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  String dropdownValue = 'ลูกค้า';
  String value = 'customer';
  String user, password, chooseType, news;
  bool login, register, csRadio, stRadio;
  bool isLoggedIn = false;
  var profile;
  var profiletosend;
  bool _obscureText = true;
  void onLoginStatusChanged(bool isLoggedIn) {
    setState(() {
      this.isLoggedIn = isLoggedIn;
    });
  }

  @override
  void initState() {
    login = true;
    register = false;
    csRadio = false;
    stRadio = false;
    aboutNotification();
    super.initState();
  }

  colorButton1() {
    if (register == true) {
      return Colors.blue;
    }
    return Colors.grey;
  }

  colorButton2() {
    if (login == true) {
      return Colors.blue;
    }
    return Colors.grey;
  }

  colorButton3() {
    if (csRadio == true) {
      return Colors.blue;
    }
    return Colors.grey;
  }

  colorButton4() {
    if (stRadio == true) {
      return Colors.blue;
    }
    return Colors.grey;
  }

  reset() {
    setState(() {
      login = true;
      register = false;
    });
    Navigator.pop(context);
  }

  condition() {
    if (news == 'ลูกค้า') {
      value = 'customer';
    } else if (news == 'ร้านซ่อมรถ') {
      value = 'store';
    }
  }

  Future<Null> readDataCusFB() async {
    final result =
        await FacebookAuth.i.login(permissions: ["public_profile", "email"]);

    if (result.status == LoginStatus.success) {
      var graphResponse = await http.get(Uri.parse(
          'https://graph.facebook.com/v2.12/me?fields=name,first_name,last_name,email,picture.width(800).height(800)&access_token=${result.accessToken.token}'));
      profile = json.decode(graphResponse.body);
      print(profile.toString());
      print(profile['picture']['data']['url']);
      print(profile['id']);
      setState(() {
        // name = profile['name'];
        // email = profile['email'];
        // print(name);
        // print(profile);
      });
      checkAuthenCusFB();
    }
  }

  Future<Null> readDataStoreFB() async {
    final result =
        await FacebookAuth.i.login(permissions: ["public_profile", "email"]);

    if (result.status == LoginStatus.success) {
      var graphResponse = await http.get(Uri.parse(
          'https://graph.facebook.com/v2.12/me?fields=name,first_name,last_name,email,picture.width(800).height(800)&access_token=${result.accessToken.token}'));
      profile = json.decode(graphResponse.body);
      print(profile.toString());
      print(profile['picture']['data']['url']);
      print(profile['id']);
      setState(() {
        // name = profile['name'];
        // email = profile['email'];
        // print(name);
        // print(profile);
      });
      checkAuthenStoreFB();
    }
  }

  Future<Null> checkAuthenCusFB() async {
    FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
    String token = await firebaseMessaging.getToken();
    String urlCustomer =
        '${MyConstant().domain}/mobile/getCustomerWhereUser.php?isAdd=true&user=${profile["id"]}';
    print(urlCustomer);
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
        MaterialPageRoute route = MaterialPageRoute(
          builder: (context) => RegisTerCusFB(
            profile: profile,
          ),
        );
        Navigator.push(context, route);
      } else {
        for (var map in result) {
          CustomerModel customerModel = CustomerModel.fromJson(map);
          if (profile['id'] == customerModel.password) {
            //normalDialog(context, )
            routeToService(MainCustomer(), customerModel);
          } else {
            normalDialog(context, 'Username หรือ Password ไม่ถูกต้อง');
          }
        }
      }
    } catch (e) {}
  }

  Future<Null> checkAuthenStoreFB() async {
    FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
    String token = await firebaseMessaging.getToken();
    print('token======$token');
    String urlStore =
        '${MyConstant().domain}/mobile/getStoreWhereUser.php?isAdd=true&user=${profile["id"]}';
    try {
      String urlStoreToken =
          '${MyConstant().domain}/mobile/editTokenSt.php?isAdd=true&token=$token&username=${profile["id"]}';
      await Dio().get(urlStoreToken);
      print(urlStoreToken);
      Response response = await Dio().get(urlStore);
      print('res =$response');

      var result = json.decode(response.data);
      print('result = $result');
      if (result == null) {
        MaterialPageRoute route = MaterialPageRoute(
          builder: (context) => RegisterStoreFB(
            profile: profile,
          ),
        );
        Navigator.push(context, route);
      }
      for (var map in result) {
        StoreModel storeModel = StoreModel.fromJson(map);

        if (storeModel.status == '1') {
          print(storeModel.password + ',' + storeModel.status);
          routeToServiceSt(MainStore(), storeModel);
        } else if (storeModel.status == '0') {
          normalDialog(context, 'ร้านซ่อมอยู่ในระหว่างการตรวจสอบ');
        } else {
          normalDialog(context, 'ร้านซ่อมอยู่ของคุณถูกแบน');
        }
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
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  TextButton(
                      onPressed: () {
                        setState(() {
                          login = true;
                          register = false;
                        });
                      },
                      child: Text(
                        'เข้าสู่ระบบ',
                        style: TextStyle(color: colorButton2()),
                      )),
                  TextButton(
                      onPressed: () {
                        setState(() {
                          login = false;
                          register = true;
                        });
                        showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                                  title: Text('เลือกรูปแบบการสมัคร'),
                                  content: StatefulBuilder(
                                    builder: (BuildContext context,
                                        StateSetter setState) {
                                      return Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          TextButton(
                                              onPressed: () {
                                                reset();
                                                MaterialPageRoute
                                                    materialPageRoute =
                                                    MaterialPageRoute(
                                                  builder: (context) =>
                                                      Register(),
                                                );
                                                Navigator.push(
                                                    context, materialPageRoute);
                                              },
                                              child: Text('ลูกค้า')),
                                          TextButton(
                                              onPressed: () {
                                                reset();
                                                MaterialPageRoute
                                                    materialPageRoute =
                                                    MaterialPageRoute(
                                                  builder: (context) =>
                                                      RegisterSt(),
                                                );
                                                Navigator.push(
                                                    context, materialPageRoute);
                                              },
                                              child: Text('ร้านซ่อมรถ')),
                                        ],
                                      );
                                    },
                                  ),
                                ));
                      },
                      child: Text(
                        'สมัครสมาชิก',
                        style: TextStyle(color: colorButton1()),
                      )),
                ],
              ),

              Icon(
                Icons.account_circle_rounded,
                size: 150,
                color: Colors.grey,
              ),
              MyStyle().mySizebox(),
              userForm(),
              MyStyle().mySizebox(),
              passwordForm(),
              SizedBox(
                height: 5,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                      onPressed: () {
                        showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                                  title: Text('เลือกประเภทของผู้ใช้'),
                                  content: StatefulBuilder(
                                    builder: (BuildContext context,
                                        StateSetter setState) {
                                      return Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          TextButton(
                                              onPressed: () {
                                                reset();
                                                MaterialPageRoute
                                                    materialPageRoute =
                                                    MaterialPageRoute(
                                                  builder: (context) =>
                                                      ResetPasswordCustomer(),
                                                );
                                                Navigator.push(
                                                    context, materialPageRoute);
                                              },
                                              child: Text('ลูกค้า')),
                                          TextButton(
                                              onPressed: () {
                                                reset();
                                                MaterialPageRoute
                                                    materialPageRoute =
                                                    MaterialPageRoute(
                                                  builder: (context) =>
                                                      ResetPasswordStore(),
                                                );
                                                Navigator.push(
                                                    context, materialPageRoute);
                                              },
                                              child: Text('ร้านซ่อมรถ')),
                                        ],
                                      );
                                    },
                                  ),
                                ));
                      },
                      child: Text(
                        'คุณลืมรหัสผ่านใช่ไหม?',
                        style: TextStyle(color: Colors.blue),
                      )),
                ],
              ),
              MyStyle().showTitleH2('เลือกชนิดของผู้เข้าสู่ระบบ'),
              //customerRadio(),
              //storeRadio(),
              dropdownUsertype(),
              loginButton(),
              Text('─────────── หรือ ─────────── '),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                      iconSize: 50,
                      color: Colors.blue,
                      onPressed: () {
                        showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                                  title: Text('เลือกประเภทของผู้ใช้'),
                                  content: StatefulBuilder(
                                    builder: (BuildContext context,
                                        StateSetter setState) {
                                      return Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          TextButton(
                                              onPressed: () {
                                                reset();
                                                readDataCusFB();
                                              },
                                              child: Text('ลูกค้า')),
                                          TextButton(
                                              onPressed: () {
                                                reset();
                                                readDataStoreFB();
                                              },
                                              child: Text('ร้านซ่อมรถ')),
                                        ],
                                      );
                                    },
                                  ),
                                ));
                      },
                      icon: Icon(Icons.facebook_sharp))
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Row dropdownUsertype() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        DropdownButton<String>(
          value: dropdownValue,
          onChanged: (String newValue) {
            setState(() {
              dropdownValue = newValue;
              news = newValue;
              print('***********************************************$value');
            });
          },
          items: <String>['ลูกค้า', 'ร้านซ่อมรถ']
              .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget loginButton() => Container(
        width: 250,
        child: ElevatedButton(
          onPressed: () {
            if (user == null ||
                user.isEmpty ||
                password == null ||
                password.isEmpty) {
              normalDialog(context, 'กรุณากรอกข้อมูลให้ครบ');
            } else if (value == null) {
              normalDialog(context, 'กรุณาเลือกประเภทในการเข้าสู่ระบบ');
            } else {
              condition();
              checkAuthen();
            }
          },
          child: Text(
            'เข้าสู่ระบบ',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
  Widget facebookButton() => Container(
        width: 250,
        child: ElevatedButton(
          style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(MyStyle().darkColor)),
          onPressed: () {},
          child: Text(
            'Login FaceBook',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );

  Future<Null> checkAuthen() async {
    String urlCustomer =
        '${MyConstant().domain}/mobile/getCustomerWhereUser.php?isAdd=true&user=$user';
    String urlStore =
        '${MyConstant().domain}/mobile/getStoreWhereUser.php?isAdd=true&user=$user';
    FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
    String token = await firebaseMessaging.getToken();

    print(token);
    print(value);
    print(urlCustomer);
    if (value == 'customer') {
      try {
        print(value);
        String urlCustomerToken =
            '${MyConstant().domain}/mobile/editTokenCus.php?isAdd=true&token=$token&username=$user';
        print(urlCustomerToken);
        await Dio().get(urlCustomerToken);
        Response response = await Dio().get(urlCustomer);
        print('res =$response');
        if (response == null) {
          MyStyle().showProgess();
        }
        var result = json.decode(response.data);
        print('result = $result');
        if (result == null) {
          normalDialog(context, 'Username หรือ Password ไม่ถูกต้อง');
        }
        for (var map in result) {
          CustomerModel customerModel = CustomerModel.fromJson(map);
          if (password == customerModel.password) {
            //normalDialog(context, )
            routeToService(MainCustomer(), customerModel);
          } else {
            normalDialog(context, 'Username หรือ Password ไม่ถูกต้อง');
          }
        }
      } catch (e) {}
    } else {
      try {
        String urlStoreToken =
            '${MyConstant().domain}/mobile/editTokenSt.php?isAdd=true&token=$token&username=$user';
        await Dio().get(urlStoreToken);

        Response response = await Dio().get(urlStore);
        print('res =$response');

        var result = json.decode(response.data);
        print('result = $result');
        if (result == null) {
          normalDialog(context, 'Username หรือ Password ไม่ถูกต้อง');
        }
        for (var map in result) {
          StoreModel storeModel = StoreModel.fromJson(map);

          if (password == storeModel.password && storeModel.status == '1') {
            print(storeModel.password + ',' + storeModel.status);
            routeToServiceSt(MainStore(), storeModel);
          } else if (password != storeModel.password) {
            normalDialog(context, 'Username หรือ Password ไม่ถูกต้อง');
          } else if (password == storeModel.password &&
              storeModel.status == '0') {
            normalDialog(context, 'ร้านซ่อมอยู่ในระหว่างการตรวจสอบ');
          } else {
            normalDialog(context, 'ร้านซ่อมของคุณถูกแบน');
          }
        }
      } catch (e) {}
    }
  }

  Future<Null> aboutNotification() async {
    if (Platform.isAndroid) {
      FirebaseMessaging.instance.getInitialMessage();
      FirebaseMessaging.onMessage.listen((message) {
        print('onmessage');
      });
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        print('onresume');
      });
    }
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

  Future<Null> routeToServiceSt(Widget myWidget, StoreModel storeModel) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setString('idst', storeModel.id);
    preferences.setString('usernamest', storeModel.username);
    preferences.setString('type', 'store');
    MaterialPageRoute route = MaterialPageRoute(
      builder: (context) => myWidget,
    );
    Navigator.pushAndRemoveUntil(context, route, (route) => false);
  }

  Widget userForm() => Container(
        width: 250.0,
        height: 40.0,
        child: TextField(
          inputFormatters: [
            LengthLimitingTextInputFormatter(20),
          ],
          onChanged: (value) => user = value.trim(),
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.account_box),
            hintText: 'ชื่อผู้ใช้',
            focusedBorder:
                OutlineInputBorder(borderSide: BorderSide(color: Colors.blue)),
          ),
        ),
      );

  Widget passwordForm() => Container(
        width: 250.0,
        height: 40.0,
        child: TextField(
          inputFormatters: [
            LengthLimitingTextInputFormatter(20),
          ],
          onChanged: (value) => password = value.trim(),
          obscureText: _obscureText,
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.lock),
            hintText: 'รหัสผ่าน',
            focusedBorder:
                OutlineInputBorder(borderSide: BorderSide(color: Colors.blue)),
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
        ),
      );

  Widget storeRadio() => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 250.0,
            child: Row(
              children: <Widget>[
                Radio(
                  value: 'Store',
                  groupValue: chooseType,
                  onChanged: (value) {
                    setState(() {
                      csRadio = false;
                      stRadio = true;
                      chooseType = value;
                    });
                  },
                ),
                Text(
                  'ร้านซ่อมรถ',
                  style: TextStyle(color: colorButton4()),
                )
              ],
            ),
          ),
        ],
      );

  Widget customerRadio() => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 250.0,
            child: Row(
              children: <Widget>[
                Radio(
                  value: 'Customer',
                  groupValue: chooseType,
                  onChanged: (value) {
                    setState(() {
                      csRadio = true;
                      stRadio = false;
                      chooseType = value;
                    });
                  },
                ),
                Text(
                  'ลูกค้า',
                  style: TextStyle(color: colorButton3()),
                )
              ],
            ),
          ),
        ],
      );
}
