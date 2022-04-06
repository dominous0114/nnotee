import 'package:flutter/material.dart';
import 'package:nnotee/screen/signin.dart';

class HomeLogin extends StatefulWidget {

  @override
  _HomeLoginState createState() => _HomeLoginState();
}

class _HomeLoginState extends State<HomeLogin> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: <Widget>[
              SizedBox(height: 20,),
              Image.asset('images/hello.png',scale: 1,),
              ElevatedButton(onPressed: ()
              {
                routeToAppInfo();
              }, 
              child: Text('สมัครสมาชิก หรือ เข้าสู่ระบบ'))
            ],
          ),
          
        ),
      ),
    );
  }
   void routeToAppInfo() {
    MaterialPageRoute materialPageRoute = MaterialPageRoute(
      builder: (context) => SignIn(),
    );
    Navigator.push(context, materialPageRoute);
  }
}