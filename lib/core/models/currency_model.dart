class Currency {
  final String country;
  final String code;
  final String symbol;

  Currency({
    required this.country,
    required this.code,
    required this.symbol,
  });

  factory Currency.fromJson(Map<String, dynamic> json) {
    return Currency(
      country: json['country'] ?? '',
      code: json['code'] ?? '',
      symbol: json['symbol'] ?? '',
    );
  }

  // ✅ Add this static method to fix your error
  static List<Currency> fromList(List<dynamic> list) {
    return list.map((item) => Currency.fromJson(item)).toList();
  }
}
