import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/data_model.dart';

class DataService {


  static Future<List<SpendingDetails>> loadSalesData({int delaySeconds = 1}) async {
    try {
      final response = await http.get(Uri.parse("https://fintechproject-95d40-default-rtdb.firebaseio.com/week/-NRjEk5IyNXsD0IAHsbW.json"));
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




