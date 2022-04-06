import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:nnotee/model/tracking.dart';
import 'package:nnotee/utility/my_constant.dart';

class TrackServices {
  static const _GET_ALL_ACTION = 'GET_ALL';

  static Future<List<TrackModel>> readDataTrack(String orderId) async {
    try {
      var map = Map<String, dynamic>();
      map['action'] = _GET_ALL_ACTION;
      map['orders_id'] = orderId;
      final url = Uri.parse('${MyConstant().domain}/1062/trackDB.php');
      final response = await http.post(url, body: map);
      print('getTrack Response: ${response.body}');
      if (200 == response.statusCode) {
        List<TrackModel> list = parseResponse(response.body);
        return list;
      } else {
        return readDataTrack(orderId);
      }
    } catch (e) {
      return readDataTrack(orderId);
    }
  }

  static List<TrackModel> parseResponse(String responseBody) {
    final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();
    return parsed.map<TrackModel>((json) => TrackModel.fromJson(json)).toList();
  }
}
