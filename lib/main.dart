import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:movie_app/colors.dart';
import 'package:movie_app/screens/home_screen.dart';
import 'package:movie_app/screens/login_screen.dart';
import 'package:movie_app/screens/register_screen.dart';
import 'firebase_options.dart';
import 'package:movie_app/screens/splash_screen.dart';

final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);


Future<void> main() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget{
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, ThemeMode currentMode, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          // title: 'LOVE',

          theme: ThemeData().copyWith(
            appBarTheme: const AppBarTheme(backgroundColor: Colors.red),
            useMaterial3: true,
          ),
          darkTheme: ThemeData.dark().copyWith(
            scaffoldBackgroundColor: Colours.scaffoldBgColor,
            appBarTheme: const AppBarTheme(backgroundColor: Colors.black),
            useMaterial3: true,
          ),
          themeMode: currentMode,
          initialRoute: '/',
          routes:{
            '/':(context)=>SplashScreen(),
            '/login':(context) => const LoginScreen(),
            '/register':(context) => const RegisterScreen(),
            '/home': (context) => const HomeScreen(),
          },
        );
      },
    );
  }
}