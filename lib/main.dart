import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:voice_recorder_app/pages/categories_page.dart';
import 'package:voice_recorder_app/pages/home_page.dart';
import 'package:voice_recorder_app/pages/search_page.dart';
import 'package:voice_recorder_app/pages/settings_page.dart';

void main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Voice Recorder',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.light,
      home: const HomePage(),
      routes: {
        '/search': (context) => const SearchPage(),
        '/settings': (context) => const SettingsPage(),
        '/categories': (context) => const CategoriesPage(),
      },
      theme: ThemeData(
        buttonTheme: const ButtonThemeData(
          colorScheme: ColorScheme.light(
            primary: Color(0xFF495BFF),
            secondary: Color(0xFFEFEFEF),
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(backgroundColor: Color(0xFF495BFF)),
        popupMenuTheme: PopupMenuThemeData(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          textStyle: GoogleFonts.getFont(
            'Inter',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF23262F),
          ),
        ),
        scaffoldBackgroundColor: const Color(0xFFF2F2F2),
        listTileTheme: ListTileThemeData(
          dense: true,
          tileColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: const BorderSide(width: 1.0, color: Color(0xFFF4F6F9)),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            primary: const Color(0xFF495BFF),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide.none,
            ),
          ),
        ),
        appBarTheme: AppBarTheme(
          iconTheme: const IconThemeData(color: Color(0xFF323232)),
          backgroundColor: Colors.white,
          elevation: 0.0,
          actionsIconTheme: const IconThemeData(color: Color(0xFF323232)),
          centerTitle: true,
          titleTextStyle: GoogleFonts.getFont(
            'Inter',
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF23262F),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(style: BorderStyle.solid, width: 1.0, color: Color(0xFFEFEFEF)),
          ),
          labelStyle: GoogleFonts.getFont(
            'Inter',
            fontWeight: FontWeight.w500,
            fontSize: 16,
            color: const Color(0xFF969AA0),
          ),
          hintStyle: GoogleFonts.getFont(
            'Inter',
            fontWeight: FontWeight.w500,
            fontSize: 16,
            color: const Color(0xFF969AA0),
          ),
        ),
        tabBarTheme: TabBarTheme(
          labelStyle: GoogleFonts.getFont(
            'Inter',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF23262F),
          ),
          unselectedLabelStyle: GoogleFonts.getFont(
            'Inter',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF23262F),
          ),
          labelColor: const Color(0xFF495BFF),
          indicator: const UnderlineTabIndicator(
            borderSide: BorderSide(width: 4.0, color: Color(0xFF495BFF)),
          ),
          unselectedLabelColor: const Color(0xFF23262F),
        ),
        textTheme: TextTheme(
          headline1: GoogleFonts.getFont(
            'Inter',
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF23262F),
          ),
          headline2: GoogleFonts.getFont(
            'Inter',
            fontSize: 17,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF23262F),
          ),
          subtitle1: GoogleFonts.getFont(
            'Inter',
            fontSize: 24,
            fontWeight: FontWeight.w300,
            color: const Color(0xFF777777),
          ),
          subtitle2: GoogleFonts.getFont(
            'Inter',
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF777777),
          ),
          bodyText1: GoogleFonts.getFont(
            'Inter',
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF969AA0),
          ),
          bodyText2: GoogleFonts.getFont(
            'Inter',
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF495BFF),
          ),
        ),
      ),
    );
  }
}
