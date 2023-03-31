import 'dart:convert';
import '../model/data_model.dart';
import 'package:http/http.dart' as http;

class DataServiceYear {
  static Future<List<SpendingDetails>> loadSalesData({int delaySeconds = 1}) async {
    try {
      final response = await http.get(Uri.parse("https://fintechproject-95d40-default-rtdb.firebaseio.com/year/-NRjEzDYra1IqhTTM2AU.json"));
      final jsonResponse = json.decode(response.body);
      final spendingData = List<SpendingDetails>.from(jsonResponse.map((x) => SpendingDetails.fromJson(x)));
      await Future.delayed(Duration(seconds: delaySeconds)); // add delay
      return spendingData;
    } catch (e) {
      print('Error loading sales data: $e');
      rethrow;
    }
  }
}

