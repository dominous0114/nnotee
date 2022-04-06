import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:nnotee/model/product.dart';
import 'package:nnotee/utility/my_constant.dart';

class ProductServices {
  static const _GET_ALL_ACTION = 'GET_ALL';

  static Future<List<ProductModel>> readDataProduct(String storeId) async {
    try {
      var map = Map<String, dynamic>();
      map['action'] = _GET_ALL_ACTION;
      map['store_id'] = storeId;
      final url = Uri.parse('${MyConstant().domain}/1062/productDB.php');
      final response = await http.post(url, body: map);
      print('getProduct Response: ${response.body}');
      if (200 == response.statusCode) {
        List<ProductModel> list = parseResponse(response.body);
        return list;
      } else {
        return readDataProduct(storeId);
      }
    } catch (e) {
      return readDataProduct(storeId);
    }
  }

  static List<ProductModel> parseResponse(String responseBody) {
    final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();
    return parsed
        .map<ProductModel>((json) => ProductModel.fromJson(json))
        .toList();
  }
}
