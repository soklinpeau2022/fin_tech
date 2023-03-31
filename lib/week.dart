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

  @override
  void initState() {
    super.initState();
    _spendingDataFuture = DataService.loadSalesData();
  }

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
                  Padding(
                    padding: const EdgeInsets.all(5),
                    child: Container(
                      height: MediaQuery.of(context).size.height,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blueGrey),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(5),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    FutureBuilder<num>(
                                      future: totalSpending(),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return Center(child: Text(""));
                                        } else if (snapshot.hasError) {
                                          return Text(
                                              'Error: ${snapshot.error}');
                                        } else {
                                          return Text(
                                            '\$${snapshot.data?.toStringAsFixed(2) ?? ''}',
                                            style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.red),
                                          );
                                        }
                                      },
                                    ),
                                    Text("Total spend this Week"),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            FutureBuilder<List<SpendingDetails>>(
                              future: _spendingDataFuture,
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return Center(
                                    child: CircularProgressIndicator(),
                                  );
                                } else if (snapshot.hasError) {
                                  return Center(
                                    child: Text('Error loading sales data.'),
                                  );
                                } else if (snapshot.data == null ||
                                    snapshot.data!.isEmpty) {
                                  return Center(
                                    child: Text('No data available.'),
                                  );
                                } else {
                                  return Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.stretch,
                                    children: [
                                      SizedBox(
                                        height: 200.0,
                                        width: double.infinity,
                                        child: SfCartesianChart(
                                          primaryXAxis: CategoryAxis(),
                                          series: <
                                              ColumnSeries<SpendingDetails,
                                                  String>>[
                                            ColumnSeries<SpendingDetails,
                                                String>(
                                              dataSource: snapshot.data!,
                                              xValueMapper:
                                                  (SpendingDetails details,
                                                  _) =>
                                              details.calendar,
                                              yValueMapper:
                                                  (SpendingDetails details,
                                                  _) =>
                                              details.price,
                                              borderRadius:
                                              BorderRadius.circular(4),
                                              color: Colors.red,
                                            ),
                                          ],
                                        ),
                                      ),
                                      Text(
                                        "Spending",
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Container(
                                            width: double.infinity,
                                            height: MediaQuery.of(context)
                                                .size
                                                .height *
                                                0.643,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                              BorderRadius.circular(8),
                                            ),
                                            child: ListView.builder(
                                                shrinkWrap: true,
                                                itemCount: snapshot
                                                    .data?.length ??
                                                    0, // Use the length of the loaded sales data or 0 if it's null
                                                itemBuilder:
                                                    (BuildContext context,
                                                    int index) {
                                                  final saleDetails = snapshot
                                                      .data?[
                                                  index]; // Get the sales data at the current index or null if it doesn't exist
                                                  return Padding(
                                                    padding:
                                                    EdgeInsets.all(8.0),
                                                    child: saleDetails != null
                                                        ? Cards(
                                                      calendar:
                                                      saleDetails
                                                          .calendar
                                                          .toString(),
                                                      price:
                                                      '\$${saleDetails.price?.toStringAsFixed(2).toString()}',
                                                      spendto: saleDetails
                                                          .spendto
                                                          .toString(),
                                                      date:
                                                      '${saleDetails.date?.day}-${saleDetails.date?.month}-${saleDetails.date?.year}',
                                                    )
                                                        : Container(), // Return an empty container if the SaleDetails object is null
                                                  );
                                                })),
                                      ),
                                    ],
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
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
