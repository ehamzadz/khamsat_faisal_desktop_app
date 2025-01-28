import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../models/stats_card_model.dart';
import '../screens/home_page.dart';

Widget buildStatsCards(DashboardProvider provider) {
  final stats = provider.getStats();
  return Wrap(
    spacing: 10,
    runSpacing: 10,
    children: stats.map((stat) {
      return StatsCard(
        title: stat["title"] as String,
        value: stat["value"] as String,
        icon: stat["icon"] as IconData,
      ).animate().shimmer(delay: 400.ms);
    }).toList(),
  );
}
