import 'package:flutter/material.dart';
import 'package:capstone_dacula/screens/activities_screen.dart';

const Color kMaroon = Color(0xFF800000);
const Color kGold = Color(0xFFFFC107);
const Color kWhite = Color(0xFFFFFFFF);

void main() => runApp(const CampusHubApp());

class CampusHubApp extends StatelessWidget {
  const CampusHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Campus Hub Feedback',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: kMaroon,
          primary: kMaroon,
          onPrimary: kWhite,
          secondary: kGold,
          onSecondary: kMaroon,
          surface: kWhite,
        ),
        scaffoldBackgroundColor: kWhite,
        appBarTheme: const AppBarTheme(
          backgroundColor: kMaroon,
          foregroundColor: kWhite,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: kGold,
          foregroundColor: kMaroon,
        ),
      ),
      home: const ActivitiesScreen(),
    );
  }
}