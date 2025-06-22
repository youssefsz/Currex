import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerLoading extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;
  final EdgeInsetsGeometry margin;

  const ShimmerLoading({
    super.key,
    this.width = double.infinity,
    this.height = 16.0,
    this.borderRadius = 8.0,
    this.margin = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Shimmer.fromColors(
      baseColor: isDarkMode ? Colors.grey[850]! : Colors.grey[300]!,
      highlightColor: isDarkMode ? Colors.grey[700]! : Colors.grey[100]!,
      child: Container(
        width: width,
        height: height,
        margin: margin,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

class ShimmerList extends StatelessWidget {
  final int itemCount;
  final double itemHeight;
  final double spacing;
  final EdgeInsetsGeometry padding;

  const ShimmerList({
    super.key,
    this.itemCount = 5,
    this.itemHeight = 80.0,
    this.spacing = 16.0,
    this.padding = const EdgeInsets.all(16.0),
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: padding,
      itemCount: itemCount,
      itemBuilder:
          (context, index) => Padding(
            padding: EdgeInsets.only(
              bottom: index == itemCount - 1 ? 0 : spacing,
            ),
            child: ShimmerLoading(height: itemHeight, borderRadius: 16.0),
          ),
    );
  }
}

class ShimmerCard extends StatelessWidget {
  final double height;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;

  const ShimmerCard({
    super.key,
    this.height = 200.0,
    this.padding = const EdgeInsets.all(16.0),
    this.margin = const EdgeInsets.all(16.0),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ShimmerLoading(height: height * 0.7, borderRadius: 16.0),
            const SizedBox(height: 16.0),
            ShimmerLoading(width: 150.0, height: 24.0, borderRadius: 8.0),
            const SizedBox(height: 8.0),
            ShimmerLoading(width: 250.0, height: 16.0, borderRadius: 8.0),
          ],
        ),
      ),
    );
  }
}

class ShimmerChart extends StatelessWidget {
  final double height;
  final EdgeInsetsGeometry padding;

  const ShimmerChart({
    super.key,
    this.height = 250.0,
    this.padding = const EdgeInsets.all(16.0),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Chart area
          ShimmerLoading(height: height, borderRadius: 16.0),
          const SizedBox(height: 16.0),
          // Time period selectors
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(
              6,
              (index) =>
                  ShimmerLoading(width: 40.0, height: 24.0, borderRadius: 8.0),
            ),
          ),
        ],
      ),
    );
  }
}
