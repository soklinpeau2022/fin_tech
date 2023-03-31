import 'package:flutter/material.dart';
class Cards extends StatelessWidget {
  final String calendar ;
  final String price;
  final String spendto;
  final String date;


   const Cards({Key? key, required this.calendar, required this.price, required this.spendto, required this.date,  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 70,
      decoration: BoxDecoration(
        color: Colors.black12,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: 18),
        child: Row(
          mainAxisAlignment:
          MainAxisAlignment.spaceBetween,
          children: [
            ClipOval(
              child: Container(
                color: Colors.blueGrey[100],
                width: 40,
                height: 40,
                child: const Icon(
                  Icons.monetization_on,
                  color: Colors.red,
                ),
              ),
            ),
            Column(
              mainAxisAlignment:
              MainAxisAlignment.center,
              children: [
                Text(calendar),
                SizedBox(
                  height: 8,
                ),
                Text(price, style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                )),
              ],
            ),
            Column(
              mainAxisAlignment:
              MainAxisAlignment.center,
              children: [
                Text(spendto),
                SizedBox(
                  height: 8,
                ),
                Text(
                  date,
                  style: TextStyle(fontSize: 12),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
