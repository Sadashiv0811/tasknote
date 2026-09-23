import 'package:flutter/material.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:logger/logger.dart';

final List<Color> uniqueColors = [
  const Color(0xFFD97706), // 1. Amber Gold
  const Color(0xFFEA580C), // 2. Tangerine Orange
  const Color(0xFFDE2649), // 3. Crimson Red
  const Color(0xFFDB2777), // 4. Vivid Rose
  const Color(0xFF9333EA), // 5. Psychedelic Purple
  const Color(0xFF2563EB), // 6. Royal Indigo
  const Color(0xFF0D9488), // 7. Deep Forest Teal
  const Color(0xFF059669), // 8. Emerald Green
  const Color(0xFF65A30D), // 9. Olive Lime
  const Color(0xFFB45309), // 10. Burnt Sienna
];

final logger = Logger();

final List<String> viewOptions = ["Small Grid", "Large Grid", "List", "Title"];
final List<IconData> viewOptionsIcons = [
  Icons.grid_on,
  Icons.grid_view,
  Icons.list,
  Icons.menu,
];
final List<String> sortOptions = ["Created", "Last updated", "Alphabetically"];

final RegExp titlePattern = RegExp(
  r'[a-zA-Z0-9_\-\s.,]',
); // letters, numbers, space, _-.,

enum FetchStatus { error, fetched, empty }

// Get screen Height and Width
double getHeight(BuildContext context, double h) {
  return MediaQuery.sizeOf(context).height * h;
}

double getWidth(BuildContext context, double w) {
  return MediaQuery.sizeOf(context).width * w;
}

Future<bool> checkInternet() async {
  // Use 'hasInternetAccess' for a one-time check
  bool result = await InternetConnection().hasInternetAccess;
  return result;
}
