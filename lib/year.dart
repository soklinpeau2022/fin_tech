import 'package:fin_tech/service/data.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import 'card.dart';
import 'model/data_model.dart';

class Year extends StatefulWidget {
  const Year({Key? key}) : super(key: key);

  @override
  _YearState createState() => _YearState();
}

class _YearState extends State<Year> {
  late Future<List<SpendingDetails>> _spendingDataFuture;
  List<int> yearList = [];

  @override
  void initState() {
    super.initState();
    _spendingDataFuture = aggregateWeeklyDataToMonthly();
    generateYearList();
  }

  Future<List<SpendingDetails>> aggregateWeeklyDataToMonthly() async {
    List<SpendingDetails> weeklyData = await DataService.loadSalesData();
    List<SpendingDetails> monthlyData = [];

    // Calculate monthly totals
    Map<String, num> monthlyTotals = {};
    for (SpendingDetails details in weeklyData) {
      String monthYearKey = '${details.date?.month}-${details.date?.year}';
      if (details.price != null && details.price! > 0) {
        if (monthlyTotals.containsKey(monthYearKey)) {
          monthlyTotals[monthYearKey] = monthlyTotals[monthYearKey]! + details.price!;
        } else {
          monthlyTotals[monthYearKey] = details.price!;
        }
      }
    }

    // Create monthly data objects
    monthlyTotals.forEach((key, value) {
      List<String> monthYear = key.split('-');
      int month = int.tryParse(monthYear[0]) ?? 0;
      int year = int.tryParse(monthYear[1]) ?? 0;
      monthlyData.add(SpendingDetails(
        date: DateTime(year, month),
        price: value.toDouble(), // Convert num to double
        calendar: '',
        spendto: '',
      ));
    });

    return monthlyData;
  }

  Future<num> calculateYearlyTotal() async {
    final List<SpendingDetails> spendData = await _spendingDataFuture;
    num totalSpending = 0;
    for (SpendingDetails details in spendData) {
      if (details.price != null && details.price! > 0) {
        totalSpending += details.price!;
      }
    }
    return totalSpending;
  }

  Future<num> calculateYearlyTotalByMonth(int year) async {
    final List<SpendingDetails> spendData = await _spendingDataFuture;
    num totalSpending = 0;
    for (SpendingDetails details in spendData) {
      if (details.price != null && details.price! > 0 && details.date?.year == year) {
        totalSpending += details.price!;
      }
    }
    return totalSpending;
  }

  void generateYearList() {
    int currentYear = DateTime.now().year;
    for (int i = 0; i < 8; i++) {
      yearList.add(currentYear - i);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blueGrey),
            ),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Report",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.all(5),
                  child: FutureBuilder<List<SpendingDetails>>(
                    future: _spendingDataFuture,
                    builder: (context, AsyncSnapshot<List<SpendingDetails>> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      } else if (snapshot.hasError) {
                        return Center(
                          child: Text('Error loading sales data.'),
                        );
                      } else if (snapshot.data == null || snapshot.data!.isEmpty) {
                        return Center(
                          child: Text('No data available.'),
                        );
                      } else {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            SizedBox(
                              height: 300, // Adjust the height as per your needs
                              child: SfCartesianChart(
                                primaryXAxis: CategoryAxis(),
                                series: <ChartSeries>[
                                  LineSeries<SpendingDetails, String>(
                                    dataSource: snapshot.data!,
                                    xValueMapper: (SpendingDetails details, _) =>
                                    '${details.date?.month}-${details.date?.year}',
                                    yValueMapper: (SpendingDetails details, _) => details.price,
                                    color: Colors.red,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              "Spending",
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 10),
                            ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: yearList.length,
                              itemBuilder: (BuildContext context, int index) {
                                int year = yearList[index];
                                return Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: FutureBuilder<num>(
                                    future: calculateYearlyTotalByMonth(year),
                                    builder: (context, AsyncSnapshot<num> snapshot) {
                                      if (snapshot.connectionState == ConnectionState.waiting) {
                                        return Center(
                                          child: CircularProgressIndicator(),
                                        );
                                      } else {
                                        num yearlyTotal = snapshot.data ?? 0;
                                        return Cards(
                                          calendar: '$year',
                                          price: '\$${yearlyTotal.toStringAsFixed(2)}',
                                          spendto: '',
                                          date: '$year',
                                        );
                                      }
                                    },
                                  ),
                                );
                              },
                            ),
                          ],
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
