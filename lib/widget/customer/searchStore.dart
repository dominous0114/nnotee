import 'package:flutter/material.dart';
import 'package:nnotee/Services/storeServices.dart';
import 'package:nnotee/model/store_model.dart';
import 'package:nnotee/screen/customer/show_stores.dart';
import 'package:nnotee/utility/delayTimer.dart';

class SearchStore extends StatefulWidget {
  @override
  _SearchStoreState createState() => _SearchStoreState();
}

class _SearchStoreState extends State<SearchStore> {
  final _debouncer = Debouncer(milliseconds: 1000);
  TextEditingController controller = TextEditingController();
  List<StoreModel> storeList;
  List<StoreModel> _filterStore;
  StoreModel storeModel;
  bool loading;

  @override
  void initState() {
    storeList = [];
    _filterStore = [];
    loading = false;
    getStore();
    super.initState();
  }

  getStore() {
    StoreServices.getStore().then((storeModel) {
      setState(() {
        loading = true;
        storeList = storeModel;
        _filterStore = storeModel;
      });
      print("Store : ${storeModel.length}");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: TextField(
              controller: controller,
              onChanged: (string) {
                _debouncer.run(() {
                  setState(() {
                    _filterStore = storeList
                        .where((u) => (u.username
                                .toLowerCase()
                                .contains(string.toLowerCase()) ||
                            u.name
                                .toLowerCase()
                                .contains(string.toLowerCase())))
                        .toList();
                  });
                });
              },
              decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'ค้นหาร้านซ่อม',
                  hintStyle: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Colors.black38)),
            ),
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new_outlined,
                color: Colors.black38,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            actions: [
              IconButton(
                onPressed: () {},
                icon: Icon(
                  Icons.search,
                  color: Colors.black38,
                ),
              )
            ]),
        body: loading == true
            ? ListView(
                children: _filterStore
                    .map(
                      (storeModel) => Column(
                        children: [
                          SizedBox(
                            height: 10,
                          ),
                          GestureDetector(
                            onTap: () {
                              MaterialPageRoute route = MaterialPageRoute(
                                builder: (context) => ShowStores(
                                  storeModel: storeModel,
                                ),
                              );
                              Navigator.push(context, route);
                            },
                            child: ListTile(
                              leading: CircleAvatar(
                                radius: 30.0,
                                backgroundImage: NetworkImage(storeModel.pic),
                                backgroundColor: Colors.transparent,
                              ),
                              title: Text(
                                storeModel.name,
                                style: TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                          Divider(color: Colors.black38),
                        ],
                      ),
                    )
                    .toList(),
              )
            : LinearProgressIndicator());
  }
}
