import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:nnotee/model/require_est_model.dart';
import 'package:nnotee/utility/my_constant.dart';

class RequireServices {
  static const _GET_ALL_ACTION = 'GET_ALL';
  static const _GET_ACTION = 'GET_EST';
  // 16.407,103.297

  static Future<List<RequireEstModel>> readDataRequire(
      String requireId, latitude, longitude) async {
    try {
      var map = Map<String, dynamic>();
      map['action'] = _GET_ALL_ACTION;
      map['requireId'] = requireId;
      map['latitude'] = latitude;
      map['longitude'] = longitude;

      final url = Uri.parse('${MyConstant().domain}/1062/requireDB.php');
      final response = await http.post(url, body: map);
      print('getRequire Response: ${response.body}');
      if (200 == response.statusCode) {
        List<RequireEstModel> list = parseResponse(response.body);
        return list;
      } else {
        return readDataRequire(requireId, latitude, longitude);
      }
    } catch (e) {
      return readDataRequire(requireId, latitude, longitude);
    }
  }

  static Future<List<RequireEstModel>> readDataEst(
      String requireId, latitude, longitude) async {
    try {
      var map = Map<String, dynamic>();
      map['action'] = _GET_ACTION;
      map['requireId'] = requireId;
      map['latitude'] = latitude;
      map['longitude'] = longitude;

      final url = Uri.parse('${MyConstant().domain}/1062/requireDB.php');
      final response = await http.post(url, body: map);
      print('getEst Response: ${response.body}');
      if (200 == response.statusCode) {
        List<RequireEstModel> list = parseResponse(response.body);
        return list;
      } else {
        return readDataEst(requireId, latitude, longitude);
      }
    } catch (e) {
      return readDataEst(requireId, latitude, longitude);
    }
  }

  static List<RequireEstModel> parseResponse(String responseBody) {
    final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();
    return parsed
        .map<RequireEstModel>((json) => RequireEstModel.fromJson(json))
        .toList();
  }
}
