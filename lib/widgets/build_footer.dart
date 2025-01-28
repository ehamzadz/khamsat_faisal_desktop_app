import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';

Widget buildFooter(BuildContext context) {
  return Container(
    padding: EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceContainer,
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            child: Text("All Right Reserver ©eHamzaDZ"),
            onTap: () async {
              final whatsappUrl = "https://wa.me/+213672138811";

              // Check if the platform is a desktop (Windows, macOS, Linux)
              if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
                try {
                  // Open the URL in the browser using Process.start for desktop platforms
                  await Process.start('cmd', ['/c', 'start', whatsappUrl]);
                } catch (e) {
                  print("Could not launch URL on desktop: $e");
                }
              } else {
                // Use url_launcher on mobile devices
                final uri = Uri.parse(whatsappUrl);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri);
                } else {
                  throw 'Could not launch $whatsappUrl';
                }
              }
            },
          ),
        ),
      ],
    ),
  ).animate().shimmer(delay: 400.ms);
}
