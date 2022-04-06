import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:nnotee/model/reviews.dart';
import 'package:nnotee/model/store_model.dart';
import 'package:nnotee/utility/my_constant.dart';

class AllReview extends StatefulWidget {
  final StoreModel storeModel;
  AllReview({Key key, this.storeModel}) : super(key: key);

  @override
  _AllReviewState createState() => _AllReviewState();
}

class _AllReviewState extends State<AllReview> {
  var result, detail, record;
  StoreModel storeModel;
  ReviewsModel reviewsModel;
  List<ReviewsModel> reviewModels;
  List<Widget> reviewCards;

  @override
  void initState() {
    storeModel = widget.storeModel;
    readDetail();
    readReviews();
    super.initState();
  }

  Future<Null> readDetail() async {
    setState(() {
      reviewModels = [];
      reviewCards = [];
    });
    String url =
        '${MyConstant().domain}/mobile/getReview.php?isAdd=true&storeId=${storeModel.id}';
    await Dio().get(url).then((value) {
      detail = json.decode(value.data);
      int index = 0;
      for (var map in detail) {
        ReviewsModel model = ReviewsModel.fromJson(map);
        reviewModels.add(model);
        reviewCards.add(createCard(model, index));
        print(reviewCards);
        print('$model,$index');
        index++;
      }
    });
  }

  Future<Null> readReviews() async {
    String url =
        '${MyConstant().domain}/mobile/reviewScoreWhereStore.php?isAdd=true&name=${storeModel.name}';
    await Dio().get(url).then((value) {
      print('value = $value');
      result = json.decode(value.data);
      for (var map in result) {
        setState(() {
          reviewsModel = ReviewsModel.fromJson(map);
        });
        print('name =${reviewsModel.name}');
      }
    });
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
            'รีวิวทั้งหมด',
            style: TextStyle(color: Colors.black38),
          ),
        ),
        body: SingleChildScrollView(
            child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 15,
                ),
                result != null
                    ? Column(
                        children: [
                          Text('${reviewsModel.rate}',
                              style: TextStyle(fontSize: 60)),
                          Text(
                            'จาก ${reviewsModel.num} เรตติ้ง',
                            style: TextStyle(color: Colors.black54),
                          )
                        ],
                      )
                    : Column(
                        children: [
                          Text('0.0', style: TextStyle(fontSize: 60)),
                          Text(
                            'จาก 0 เรตติ้ง',
                            style: TextStyle(color: Colors.black54),
                          )
                        ],
                      ),
                SizedBox(
                  width: 20,
                ),
                Column(
                  children: [
                    RatingBarIndicator(
                      rating: 5,
                      itemSize: 15,
                      direction: Axis.horizontal,
                      itemCount: 5,
                      itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                      itemBuilder: (context, _) => Icon(
                        Icons.star,
                        color: Colors.amber,
                      ),
                    ),
                    RatingBarIndicator(
                      rating: 4,
                      itemSize: 15,
                      direction: Axis.horizontal,
                      itemCount: 5,
                      itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                      itemBuilder: (context, _) => Icon(
                        Icons.star,
                        color: Colors.amber,
                      ),
                    ),
                    RatingBarIndicator(
                      rating: 3,
                      itemSize: 15,
                      direction: Axis.horizontal,
                      itemCount: 5,
                      itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                      itemBuilder: (context, _) => Icon(
                        Icons.star,
                        color: Colors.amber,
                      ),
                    ),
                    RatingBarIndicator(
                      rating: 2,
                      itemSize: 15,
                      direction: Axis.horizontal,
                      itemCount: 5,
                      itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                      itemBuilder: (context, _) => Icon(
                        Icons.star,
                        color: Colors.amber,
                      ),
                    ),
                    RatingBarIndicator(
                      rating: 1,
                      itemSize: 15,
                      direction: Axis.horizontal,
                      itemCount: 5,
                      itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                      itemBuilder: (context, _) => Icon(
                        Icons.star,
                        color: Colors.amber,
                      ),
                    ),
                  ],
                )
              ],
            ),
              SizedBox(
                      height: 10,
                    ),
                    detail != null
                        ? Column(
                            children: reviewCards,
                          )
                        : Column(
                          children: <Widget>[
                            Image.asset(
                              'images/hello.png',
                              scale: 1.5,
                            ),
                            Text(
                              'ยังไม่มีรายการ',
                              style: TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black38),
                            )
                          ],
                        )
          ],
        )));
  }

  Widget createCard(ReviewsModel reviewModel, int index) {
    return Container(
      width: 500.0,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Row(
            children: [
              SizedBox(
                width: 10,
              ),
              Column(
                children: [
                  CircleAvatar(
                    radius: 30.0,
                    backgroundImage: NetworkImage('${reviewModel.pic}'),
                    backgroundColor: Colors.transparent,
                  ),
                  Text(
                    reviewModel.name,
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ],
              ),
              SizedBox(
                width: 80,
              ),
              Column(
                children: [
                  Text('คะแนน'),
                  RatingBarIndicator(
                    rating: double.parse(reviewModel.score),
                    itemSize: 15,
                    direction: Axis.horizontal,
                    itemCount: 5,
                    itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                    itemBuilder: (context, _) => Icon(
                      Icons.star,
                      color: Colors.amber,
                    ),
                  ),
                  Text(reviewModel.detail),
                ],
              )
            ],
          ),
        ],
      ),
    );
  }
}
