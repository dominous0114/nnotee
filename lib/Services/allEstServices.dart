import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:nnotee/model/allRequireEst.dart';
import 'package:nnotee/utility/my_constant.dart';

class AllEstServices {
  static const _GET_EST_ACTION = 'EST';

  static Future<List<AllRequireEstModel>> getEst(String storeId) async {
    try {
      var map = Map<String, dynamic>();
      map['action'] = _GET_EST_ACTION;
      map['store_id'] = storeId;
      final url = Uri.parse('${MyConstant().domain}/1062/allEstDB.php');
      final response = await http.post(url, body: map);
      print('getAllRequireEst Response: ${response.body}');
      if (200 == response.statusCode) {
        List<AllRequireEstModel> list = parseResponse(response.body);
        return list;
      } else {
        return getEst(storeId);
      }
    } catch (e) {
      return getEst(storeId);
    }
  }

  static List<AllRequireEstModel> parseResponse(String responseBody) {
    final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();
    return parsed
        .map<AllRequireEstModel>((json) => AllRequireEstModel.fromJson(json))
        .toList();
  }
}
