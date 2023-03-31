import 'package:fin_tech/service/data.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import 'card.dart';
import 'model/data_model.dart';

class Month extends StatefulWidget {
  const Month({Key? key}) : super(key: key);

  @override
  _MonthState createState() => _MonthState();
}

class _MonthState extends State<Month> {
  late Future<List<SpendingDetails>> _spendingDataFuture;
  int? selectedMonth; // Selected month filter
  int? selectedYear; // Selected year filter

  @override
  void initState() {
    super.initState();
    _spendingDataFuture = aggregateWeeklyDataToMonthly();
  }

  // Function to aggregate weekly data to monthly data
  Future<List<SpendingDetails>> aggregateWeeklyDataToMonthly() async {
    // Load weekly data
    List<SpendingDetails> weeklyData = await DataService.loadSalesData();
    List<SpendingDetails> monthlyData = [];

    // Calculate monthly totals
    Map<String, num> monthlyTotals = {};
    for (SpendingDetails details in weeklyData) {
      if ((selectedMonth == null || details.date?.month == selectedMonth) &&
          (selectedYear == null || details.date?.year == selectedYear)) {
        String monthYearKey = '${details.date?.month}-${details.date?.year}';
        if (details.price != null && details.price! > 0) {
          if (monthlyTotals.containsKey(monthYearKey)) {
            monthlyTotals[monthYearKey] = monthlyTotals[monthYearKey]! + details.price!;
          } else {
            monthlyTotals[monthYearKey] = details.price!;
          }
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

  // Function to calculate total spending
  Future<num> totalSpending() async {
    final List<SpendingDetails> spendData = await _spendingDataFuture;
    num totalSpending = 0;
    for (SpendingDetails details in spendData) {
      if (details.price != null && details.price! > 0) {
        totalSpending += details.price!;
      }
    }
    return totalSpending;
  }

  // Function to get month name
  String getMonthName(int month) {
    switch (month) {
      case 1:
        return 'January';
      case 2:
        return 'February';
      case 3:
        return 'March';
      case 4:
        return 'April';
      case 5:
        return 'May';
      case 6:
        return 'June';
      case 7:
        return 'July';
      case 8:
        return 'August';
      case 9:
        return 'September';
      case 10:
        return 'October';
      case 11:
        return 'November';
      case 12:
        return 'December';
      default:
        return '';
    }
  }

  // Function to build the LineSeries for the chart
  List<LineSeries<SpendingDetails, String>> _buildLineSeries(List<SpendingDetails> data) {
    return <LineSeries<SpendingDetails, String>>[
      LineSeries<SpendingDetails, String>(
        dataSource: data,
        xValueMapper: (SpendingDetails details, _) =>
        getMonthName(details.date?.month ?? 0) + ' ${details.date?.year}',
        yValueMapper: (SpendingDetails details, _) => details.price,
        color: Colors.red,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blueGrey),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  "Report",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Text('Month:'),
                    SizedBox(width: 4),
                    DropdownButton<int?>(
                      value: selectedMonth,
                      onChanged: (value) {
                        setState(() {
                          selectedMonth = value;
                          _spendingDataFuture = aggregateWeeklyDataToMonthly();
                        });
                      },
                      items: [
                        DropdownMenuItem<int?>(
                          value: null,
                          child: Text('All'),
                        ),
                        ...List.generate(12, (index) {
                          return DropdownMenuItem<int?>(
                            value: index + 1,
                            child: Text(getMonthName(index + 1)),
                          );
                        }),
                      ],
                    ),
                    SizedBox(width: 10),
                    Text('Year:'),
                    SizedBox(width: 10),
                    DropdownButton<int?>(
                      value: selectedYear,
                      onChanged: (value) {
                        setState(() {
                          selectedYear = value;
                          _spendingDataFuture = aggregateWeeklyDataToMonthly();
                        });
                      },
                      items: [
                        DropdownMenuItem<int?>(
                          value: null,
                          child: Text('All'),
                        ),
                        ...List.generate(5, (index) {
                          return DropdownMenuItem<int?>(
                            value: DateTime.now().year - index,
                            child: Text((DateTime.now().year - index).toString()),
                          );
                        }),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(5),
                  child: FutureBuilder<List<SpendingDetails>>(
                    future: _spendingDataFuture,
                    builder: (context, snapshot) {
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
                              height: 200.0,
                              child: SfCartesianChart(
                                primaryXAxis: CategoryAxis(),
                                series: _buildLineSeries(snapshot.data!),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: Text(
                                "Spending",
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                            ),
                            Expanded(
                              child: ListView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: snapshot.data?.length ?? 0,
                                itemBuilder: (BuildContext context, int index) {
                                  final saleDetails = snapshot.data?[index];
                                  int? month = saleDetails?.date?.month;
                                  int? year = saleDetails?.date?.year;
                                  String monthYear = '${getMonthName(month ?? 0)} $year';
                                  return Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Cards(
                                      calendar: monthYear,
                                      price: '\$${saleDetails?.price?.toStringAsFixed(2)}',
                                      spendto: '',
                                      date: '${saleDetails?.date?.month}-${saleDetails?.date?.year}',
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        );
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
