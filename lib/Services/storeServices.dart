import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:nnotee/model/store_model.dart';
import 'package:nnotee/utility/my_constant.dart';

class StoreServices {
  static const _GET_ALL_ACTION = 'GET_ALL';
  static const _GET_ALL_MARKER = 'GET_ALLMARKER';

  static Future<List<StoreModel>> getStore() async {
    try {
      var map = Map<String, dynamic>();
      map['action'] = _GET_ALL_ACTION;
      final url = Uri.parse('${MyConstant().domain}/1062/StoreDB.php');
      final response = await http.post(url, body: map);
      print('getStore Response: ${response.body}');
      if (200 == response.statusCode) {
        List<StoreModel> list = parseResponse(response.body);
        return list;
      } else {
        return getStore();
      }
    } catch (e) {
      return getStore();
    }
  }

  static Future<List<StoreModel>> getStoreMarker() async {
    try {
      var map = Map<String, dynamic>();
      map['action'] = _GET_ALL_MARKER;
      final url = Uri.parse('${MyConstant().domain}/1062/StoreDB.php');
      final response = await http.post(url, body: map);
      print('getStore Response: ${response.body}');
      if (200 == response.statusCode) {
        List<StoreModel> list = parseResponse(response.body);
        return list;
      } else {
        return getStore();
      }
    } catch (e) {
      return getStore();
    }
  }

  static List<StoreModel> parseResponse(String responseBody) {
    final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();
    return parsed.map<StoreModel>((json) => StoreModel.fromJson(json)).toList();
  }
}
