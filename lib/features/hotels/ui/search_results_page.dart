import 'package:flutter/material.dart';
import '../../../core/models/hotel_model.dart';
import '../widgets/hotel_card.dart';

class SearchResultPage extends StatelessWidget {
  final List<Hotel> hotels;

  const SearchResultPage({super.key, required this.hotels});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFF8EC),
      appBar: AppBar(
        title: const Text("Stays",
          style: TextStyle(
              fontSize: 14
          ),),
        centerTitle: true,
        backgroundColor: Color(0xFF622A39),
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: hotels.isEmpty
          ? const Center(child: Text("No hotels found"))
          : ListView.builder(
        itemCount: hotels.length,
        itemBuilder: (context, index) =>
            HotelCard(hotel: hotels[index]),
      ),
    );
  }
}
