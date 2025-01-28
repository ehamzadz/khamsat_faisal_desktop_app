import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../screens/home_page.dart';

Widget buildSearchBar(BuildContext context, DashboardProvider provider) {
  return Row(
    children: [
      Expanded(
        child: TextField(
          controller: provider.searchController,
          decoration: InputDecoration(
            hintText: "ابحث عن مادة...",
            prefixIcon: Icon(Icons.search),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            filled: true,
            fillColor: Theme.of(context).colorScheme.surfaceContainer,
          ),
          onChanged: (value) => provider.filterTable(),
        ),
      ),
    ],
  ).animate().shimmer(delay: 400.ms);
}
