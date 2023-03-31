import 'package:fin_tech/service/data.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'card.dart';
import 'model/data_model.dart';

class Week extends StatefulWidget {
  const Week({Key? key}) : super(key: key);

  @override
  _WeekState createState() => _WeekState();
}


class _WeekState extends State<Week> {
  late Future<List<SpendingDetails>> _spendingDataFuture;
  int? selectedDay;
  int? selectedMonth;
  int? selectedYear;

  @override
  void initState() {
    super.initState();
    _spendingDataFuture = DataService.loadSalesData();
  }

  // Function to calculate total spending
  Future<num> totalSpending() async {
    final List<SpendingDetails> spendData = await _spendingDataFuture;
    num totalSpending = 0;
    for (SpendingDetails details in spendData) {
      if (details.price! > 0) {
        totalSpending += details.price!;
      }
    }
    return totalSpending;
  }

  List<SpendingDetails> filterDataByDay(
      List<SpendingDetails> data, int? day) {
    if (day == null) {
      return data;
    }
    return data.where((details) => details.date?.day == day).toList();
  }

  List<SpendingDetails> filterDataByMonth(
      List<SpendingDetails> data, int? month) {
    if (month == null) {
      return data;
    }
    return data.where((details) => details.date?.month == month).toList();
  }

  List<SpendingDetails> filterDataByYear(
      List<SpendingDetails> data, int? year) {
    if (year == null) {
      return data;
    }
    return data.where((details) => details.date?.year == year).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blueGrey),
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Report",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Column(
                    children: [
                      FutureBuilder<List<SpendingDetails>>(
                        future: _spendingDataFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          } else if (snapshot.hasError) {
                            return const Center(
                              child: Text('Error loading sales data.'),
                            );
                          } else if (snapshot.data == null ||
                              snapshot.data!.isEmpty) {
                            return const Center(
                              child: Text('No data available.'),
                            );
                          } else {
                            List<SpendingDetails> filteredData = snapshot.data!;
                            filteredData = filterDataByDay(filteredData, selectedDay);
                            filteredData = filterDataByMonth(filteredData, selectedMonth);
                            filteredData = filterDataByYear(filteredData, selectedYear);

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text('Day:'),
                                    SizedBox(width: 4),
                                    DropdownButton<int?>(
                                      value: selectedDay,
                                      onChanged: (value) {
                                        setState(() {
                                          selectedDay = value;
                                        });
                                      },
                                      items: [
                                        DropdownMenuItem<int?>(
                                          value: null,
                                          child: Text('All'),
                                        ),
                                        for (int i = 1; i <= 31; i++)
                                          DropdownMenuItem<int?>(
                                            value: i,
                                            child: Text(i.toString()),
                                          ),
                                      ],
                                    ),
                                    SizedBox(width: 16),
                                    Text('Month:'),
                                    SizedBox(width: 4),
                                    DropdownButton<int?>(
                                      value: selectedMonth,
                                      onChanged: (value) {
                                        setState(() {
                                          selectedMonth = value;
                                        });
                                      },
                                      items: [
                                        DropdownMenuItem<int?>(
                                          value: null,
                                          child: Text('All'),
                                        ),
                                        for (int i = 1; i <= 12; i++)
                                          DropdownMenuItem<int?>(
                                            value: i,
                                            child: Text(i.toString()),
                                          ),
                                      ],
                                    ),
                                    SizedBox(width: 16),
                                    Text('Year:'),
                                    SizedBox(width: 4),
                                    DropdownButton<int?>(
                                      value: selectedYear,
                                      onChanged: (value) {
                                        setState(() {
                                          selectedYear = value;
                                        });
                                      },
                                      items: [
                                        DropdownMenuItem<int?>(
                                          value: null,
                                          child: Text('All'),
                                        ),
                                        DropdownMenuItem<int?>(
                                          value: 2021,
                                          child: Text('2021'),
                                        ),
                                        DropdownMenuItem<int?>(
                                          value: 2022,
                                          child: Text('2022'),
                                        ),
                                        DropdownMenuItem<int?>(
                                          value: 2023,
                                          child: Text('2023'),
                                        ),
                                        // Add more years if needed
                                      ],
                                    ),
                                  ],
                                ),
                                SizedBox(height: 16),
                                SizedBox(
                                  height: 200.0,
                                  width: double.infinity,
                                  child: SfCartesianChart(
                                    primaryXAxis: CategoryAxis(),
                                    series: <ColumnSeries<SpendingDetails, String>>[
                                      ColumnSeries<SpendingDetails, String>(
                                        dataSource: filteredData,
                                        xValueMapper: (SpendingDetails details, _) => details.calendar,
                                        yValueMapper: (SpendingDetails details, _) => details.price,
                                        borderRadius: BorderRadius.circular(4),
                                        color: Colors.red,
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    "Spending",
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemCount: filteredData.length,
                                  itemBuilder: (BuildContext context, int index) {
                                    final saleDetails = filteredData[index];
                                    return Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: saleDetails != null
                                          ? Cards(
                                        calendar: saleDetails.calendar.toString(),
                                        price: '\$${saleDetails.price?.toStringAsFixed(2).toString()}',
                                        spendto: saleDetails.spendto.toString(),
                                        date: '${saleDetails.date?.day}-${saleDetails.date?.month}-${saleDetails.date?.year}',
                                      )
                                          : Container(),
                                    );
                                  },
                                ),
                              ],
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

