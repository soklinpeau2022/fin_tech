class SpendingDetails {
  final String calendar;
  final double price;
  final String spendto;
  final DateTime date;

  SpendingDetails({
    required this.calendar,
    required this.price,
    required this.spendto,
    required this.date,
  });

  factory SpendingDetails.fromJson(Map<String, dynamic> json) {
    return SpendingDetails(
      calendar: json['calendar'],
      price: json['price'].toDouble(),
      spendto: json['spendto'],
      date: DateTime.parse(json['date']),
    );
  }
}