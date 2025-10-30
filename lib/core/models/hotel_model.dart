class Hotel {
  final String propertyName;
  final int propertyStar;
  final String propertyImage;
  final String propertyCode;
  final String propertyType;
  final double markedPrice;
  final double staticPrice;
  final double rating;
  final int totalReviews;
  final String city;
  final String state;
  final String country;
  final String address;
  final String propertyUrl;

  Hotel({
    required this.propertyName,
    required this.propertyStar,
    required this.propertyImage,
    required this.propertyCode,
    required this.propertyType,
    required this.markedPrice,
    required this.staticPrice,
    required this.rating,
    required this.totalReviews,
    required this.city,
    required this.state,
    required this.country,
    required this.address,
    required this.propertyUrl,
  });

  factory Hotel.fromJson(Map<String, dynamic> json) {
    final googleReview = json['googleReview']?['data'] ?? {};
    final address = json['propertyAddress'] ?? {};
    final markedPrice = json['markedPrice'] ?? {};
    final staticPrice = json['staticPrice'] ?? {};

    // ✅ Handle propertyImage safely
    String propertyImageUrl = '';
    if (json['propertyImage'] is Map<String, dynamic>) {
      propertyImageUrl = json['propertyImage']['fullUrl'] ?? '';
    } else if (json['propertyImage'] is String) {
      propertyImageUrl = json['propertyImage'];
    }

    return Hotel(
      propertyName: json['propertyName'] ?? '',
      propertyStar: json['propertyStar'] ?? 0,
      propertyImage: propertyImageUrl,
      propertyCode: json['propertyCode'] ?? '',
      propertyType: json['propertyType'] ?? json['propertytype'] ?? '',
      markedPrice: (markedPrice['amount'] ?? 0).toDouble(),
      staticPrice: (staticPrice['amount'] ?? 0).toDouble(),
      rating: (googleReview['overallRating'] ?? 0).toDouble(),
      totalReviews: (googleReview['totalUserRating'] ?? 0),
      city: address['city'] ?? '',
      state: address['state'] ?? '',
      country: address['country'] ?? '',
      address: address['street'] ?? '',
      propertyUrl: json['propertyUrl'] ?? '',
    );
  }

  static List<Hotel> fromList(List<dynamic> list) {
    return list.map((item) => Hotel.fromJson(item)).toList();
  }
}
