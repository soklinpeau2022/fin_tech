class SpendingDetails {
  final String? calendar;
  final num? price;
  final String? spendto;
  final DateTime? date;

  SpendingDetails(this.calendar, this.price, this.spendto, this.date);

  factory SpendingDetails.fromJson(Map<String, dynamic> json) {
    return SpendingDetails(
      json['calendar'],
      json['price'],
      json['spendto'],
      DateTime.parse(json['date']),
    );
  }
}