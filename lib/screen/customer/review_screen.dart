import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:nnotee/model/store_order.dart';

class ReviewScreen extends StatefulWidget {
  final OrderModel orderModel;
  ReviewScreen({Key key, this.orderModel}) : super(key: key);
  @override
  _ReviewScreenState createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  OrderModel orderModel;
  String detail, score;

  @override
  void initState() {
    orderModel = widget.orderModel;
    super.initState();
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
          title: Text(
            'รีวิว',
            style: TextStyle(color: Colors.black38),
          ),
        ),
        body: SafeArea(
            child: Center(
          child: Column(
            children: [
              Text(
                'กรุณาให้คะแนน',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
              ),
              RatingBar.builder(
                initialRating: 3,
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: true,
                itemCount: 5,
                itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                itemBuilder: (context, _) => Icon(
                  Icons.star,
                  color: Colors.amber,
                ),
                onRatingUpdate: (rating) {
                  setState(() {
                    score = rating.toString();
                  });
                  print(rating);
                  print('score: $score');
                },
              ),
              SizedBox(
                width: 220,
                child: TextFormField(
                  maxLines: 2,
                  onChanged: (value) => detail = value.trim(),
                  decoration: InputDecoration(
                    labelText: 'รายละเอียดเพิ่มเติม:',
                    hintText: "ใส่รายระเอียดเพิ่มเติม",
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              SizedBox(
                width: 220,
                child: ElevatedButton(onPressed: () {}, child: Text('รีวิว')),
              )
            ],
          ),
        )));
  }
}
