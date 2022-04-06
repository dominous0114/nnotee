import 'package:flutter/material.dart';
import 'package:nnotee/screen/signin.dart';

class HomeLove extends StatefulWidget {

  @override
  _HomeLoveState createState() => _HomeLoveState();
}

class _HomeLoveState extends State<HomeLove> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ที่บักทึกไว้',style: TextStyle(color: Colors.black38),),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: <Widget>[
              Image.asset('images/hello.png',scale: 2,),
              Text('สมัครสมาชิก หรือ เข้าสู่ระบบ เพื่อสร้างคอลเล็กชั่นของ',style: TextStyle(fontWeight: FontWeight.w600),),
              Text('คุณได้เลย',style: TextStyle(fontWeight: FontWeight.w600)),
              SizedBox(height: 10,),
              ElevatedButton(onPressed: (){routeToAppInfo();}, child: Text('สมัครสมาชิก หรือ เข้าสู่ระบบ'),style: ButtonStyle( backgroundColor: MaterialStateProperty.all(Colors.red),),)
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