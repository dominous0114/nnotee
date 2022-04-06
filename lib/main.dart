import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nnotee/screen/customer/trackingCs.dart';
import 'package:nnotee/screen/home.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
                appBarTheme: AppBarTheme(
                    textTheme:
                        GoogleFonts.kanitTextTheme(Theme.of(context).textTheme),
                    elevation: 0,
                    backgroundColor: Colors.white))
            .copyWith(
                textTheme:
                    GoogleFonts.kanitTextTheme(Theme.of(context).textTheme)),
        home: Home(),
        routes: {
          "tracking": (_) => CsTracking(),
        });
  }
}
