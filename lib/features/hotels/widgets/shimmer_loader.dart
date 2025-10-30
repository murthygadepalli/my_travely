import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class HotelListShimmer extends StatelessWidget {
  const HotelListShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 6,
      padding: const EdgeInsets.all(12),
      itemBuilder: (_, __) {
        return Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(height: 16, width: 150, color: Colors.grey),
                      const SizedBox(height: 8),
                      Container(height: 14, width: 100, color: Colors.grey),
                      const SizedBox(height: 8),
                      Container(height: 12, width: 180, color: Colors.grey),
                    ],
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
