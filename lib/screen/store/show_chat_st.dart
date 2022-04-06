import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:nnotee/model/chat_model.dart';
import 'package:nnotee/model/tracking.dart';
import 'package:nnotee/utility/banstore.dart';
import 'package:nnotee/utility/my_constant.dart';
import 'package:nnotee/utility/normal_dialog.dart';

class ShowChatStore extends StatefulWidget {
  ChatModel chatModel;
  ShowChatStore({Key key, this.chatModel}) : super(key: key);

  @override
  _ShowChatStoreState createState() => _ShowChatStoreState();
}

class _ShowChatStoreState extends State<ShowChatStore> {
  var result;
  ChatModel chatModel;
  //ChatModel chatModel;
  List<ChatModel> chatList;
  int index;
  TrackModel checkModel;
  String idCus, usernameCus, content, pro;
  TextEditingController _ctrlMess = TextEditingController();
  @override
  void initState() {
    BanStore().readdataBan(context);
    chatModel = widget.chatModel;
    checkUser();
    super.initState();
  }

  Size screenSize() {
    return MediaQuery.of(context).size;
  }

  Future<Null> addChatThread() async {
    String url =
        '${MyConstant().domain}/mobile/addChat.php?isAdd=true&idCus=${chatModel.customerId}&idStore=${chatModel.storeId}';
    try {
      Response response = await Dio().get(url);
      print('res = $response');
      if (response.toString() == 'true') {
        print('เพิ่มสำเร็จ');
        checkUser();
      } else {
        print('เพิ่มไม่สำเร็จ');
      }
    } catch (e) {
      print(e);
    }
  }

  Future<Null> addChatDetailThread() async {
    String url =
        '${MyConstant().domain}/mobile/addChatDetail.php?isAdd=true&user_from=${chatModel.storeUsername}&user_to=${chatModel.customerUsername}&content=$content&chatId=$pro';
    try {
      Response response = await Dio().get(url);
      print('res = $response');
      if (response.toString() == 'true') {
        sendNotificaionToCustomer(content);
        print('คนส่ง : ${chatModel.storeName}');
        print('คนรับ : ${chatModel.cusName}');
        print(content);
        print('เพิ่มสำเร็จ');
      } else {
        print('เพิ่มไม่สำเร็จ');
      }
      print(url);
    } catch (e) {
      print(e);
    }
  }

  // Future<Null> readDataCustomer() async {
  //   SharedPreferences preferences = await SharedPreferences.getInstance();
  //   String id = preferences.getString('idcus');

  //   String url =
  //       '${MyConstant().domain}/mobile/getCustomerWhereId.php?isAdd=true&id=$id';
  //   await Dio().get(url).then((value) {
  //     print('value = $value');
  //     var result = json.decode(value.data);
  //     for (var map in result) {
  //       setState(() {
  //         customerModel = CustomerModel.fromJson(map);
  //       });
  //       print('name =${customerModel.name}');
  //     }
  //   });
  // }

  Future<List<dynamic>> readDataChat(int value) async {
    String url =
        '${MyConstant().domain}/mobile/getChatDetail_st.php?isAdd=true&userCus=${chatModel.customerUsername}&userStore=${chatModel.storeUsername}';
    await Dio().get(url).then((value) {
      result = json.decode(value.data);
      print('^^^^^^^^^^^^^^^^^^^^^$result');
    });
    return result;
  }

  Future<Null> sendNotificaionToCustomer(String content) async {
    String urlSendToken =
        '${MyConstant().domain}/mobile/apiNotification.php?isAdd=true&token=${chatModel.customerToken}&title=${chatModel.storeName}&body=$content';
    await Dio().get(urlSendToken).then((value) => null);
    print('++++++++++++++++++++++++++++++++++++++++$urlSendToken');
  }

  Future<Null> checkUser() async {
    String url =
        '${MyConstant().domain}/mobile/CheckChatWhereId.php?isAdd=true&idCus=${chatModel.customerId}&idStore=${chatModel.storeId}';
    print('###########################################$url');

    try {
      Response response = await Dio().get(url);
      print('res = $response');
      if (response.toString() == 'null') {
        addChatThread();
      } else {
        modelChat();
      }
    } catch (e) {}
  }

  Future<Null> modelChat() async {
    String url =
        '${MyConstant().domain}/mobile/CheckChatWhereId.php?isAdd=true&idCus=${chatModel.customerId}&idStore=${chatModel.storeId}';
    print('###########################################$url');

    try {
      await Dio().get(url).then((value) {
        print('value = $value');
        var result = json.decode(value.data);
        for (var map in result) {
          setState(() {
            checkModel = TrackModel.fromJson(map);
            pro = checkModel.id;
          });
          print('ChatId =${checkModel.id}');
        }
      });
    } catch (e) {}
  }

  Stream<Future<List<dynamic>>> _stream() {
    Duration interval = Duration(seconds: 1);
    Stream<Future<List<dynamic>>> stream =
        Stream<Future<List<dynamic>>>.periodic(interval, readDataChat);
    return stream;
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
          'คุณ ${chatModel.cusName}',
          style: TextStyle(color: Colors.black38),
        ),
      ),
      body: StreamBuilder(
        initialData: null,
        stream: _stream(),
        builder: (context, snap) {
          if (snap.hasData) {
            var temp = snap.data as Future<List<dynamic>>;
            return Column(
              children: <Widget>[
                FutureBuilder(
                  future: temp,
                  builder: (context, snap) {
                    List<dynamic> lst = snap.data;
                    if (lst != null) {
                      return Expanded(
                        child: ListView.builder(
                          padding: EdgeInsets.all(20),
                          itemCount: lst.length,
                          itemBuilder: (context, index) {
                            var username = lst[index]['user_from'];
                            var mess = lst[index]['content'].toString();
                            var time = lst[index]['time'].toString();
                            return username == chatModel.storeUsername
                                ? Column(
                                    children: <Widget>[
                                      Container(
                                        alignment: Alignment.topRight,
                                        child: Container(
                                          constraints: BoxConstraints(
                                            maxWidth: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.80,
                                          ),
                                          padding: EdgeInsets.all(10),
                                          margin: EdgeInsets.symmetric(
                                              vertical: 10),
                                          decoration: BoxDecoration(
                                            color:
                                                Theme.of(context).primaryColor,
                                            borderRadius:
                                                BorderRadius.circular(15),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.grey
                                                    .withOpacity(0.5),
                                                spreadRadius: 2,
                                                blurRadius: 5,
                                              ),
                                            ],
                                          ),
                                          child: Text(
                                            mess,
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: <Widget>[
                                          Text(
                                            time,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.black45,
                                            ),
                                          ),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Container(
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.grey
                                                      .withOpacity(0.5),
                                                  spreadRadius: 2,
                                                  blurRadius: 5,
                                                ),
                                              ],
                                            ),
                                            child: CircleAvatar(
                                              radius: 15,
                                              backgroundImage: NetworkImage(
                                                  '${chatModel.storePic}'),
                                            ),
                                          ),
                                        ],
                                      )
                                    ],
                                  )
                                : Column(
                                    children: <Widget>[
                                      Container(
                                        alignment: Alignment.topLeft,
                                        child: Container(
                                          constraints: BoxConstraints(
                                            maxWidth: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.80,
                                          ),
                                          padding: EdgeInsets.all(10),
                                          margin: EdgeInsets.symmetric(
                                              vertical: 10),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(15),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.grey
                                                    .withOpacity(0.5),
                                                spreadRadius: 2,
                                                blurRadius: 5,
                                              ),
                                            ],
                                          ),
                                          child: Text(
                                            mess,
                                            style: TextStyle(
                                              color: Colors.black54,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Row(
                                        children: <Widget>[
                                          Container(
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.grey
                                                      .withOpacity(0.5),
                                                  spreadRadius: 2,
                                                  blurRadius: 5,
                                                ),
                                              ],
                                            ),
                                            child: CircleAvatar(
                                              radius: 15,
                                              backgroundImage: NetworkImage(
                                                  '${chatModel.customerPic}'),
                                            ),
                                          ),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Text(
                                            time,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.black45,
                                            ),
                                          ),
                                        ],
                                      )
                                    ],
                                  );
                          },
                        ),
                      );
                    } else {
                      return Spacer();
                    }
                  },
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  height: 70,
                  color: Colors.white,
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: TextField(
                          controller: _ctrlMess,
                          decoration: InputDecoration.collapsed(
                            hintText: 'กรอกข้อความตรงนี้',
                          ),
                          textCapitalization: TextCapitalization.sentences,
                        ),
                      ),
                      IconButton(
                          icon: Icon(Icons.send),
                          iconSize: 25,
                          color: Theme.of(context).primaryColor,
                          onPressed: () async {
                            content = _ctrlMess.text.trim();
                            if (content.isNotEmpty) {
                              addChatDetailThread();
                              _ctrlMess.text = "";
                            } else {
                              print("empty");
                            }
                          }),
                    ],
                  ),
                )
              ],
            );
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}
