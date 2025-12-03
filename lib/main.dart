import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import '/firebase_options.dart';
import '/auth/sign_in.dart';
import '/views/home_pages/admin_home.dart';
import '/views/home_pages/user_home.dart';
import '/views/home_pages/client_home.dart'; // Import the new client home page
import '/services/theme_notifier.dart';
import '/services/zoom_notifier.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeNotifier.themeMode,
      builder: (context, themeMode, child) {
        return ValueListenableBuilder<double>(
          valueListenable: ZoomNotifier.zoomLevel,
          builder: (context, zoomLevel, child) {
            return MaterialApp(
              title: 'LMS',
              routes: {
                '/client_home': (context) => const ClientDashboardPage(),
              },
              builder: (context, child) {
                return MediaQuery(
                  data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(zoomLevel)),
                  child: child!,
                );
              },
              theme: ThemeData(
                useMaterial3: false,
                textTheme: GoogleFonts.montserratTextTheme(Theme.of(context).textTheme),
                brightness: Brightness.light,
                primaryColor: Colors.grey,
                scaffoldBackgroundColor: Colors.white,
                appBarTheme: const AppBarTheme(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  elevation: 0,
                ),
                colorScheme: const ColorScheme.light(
                  primary: Colors.grey,
                  secondary: Colors.black,
                  surface: Colors.white,
                  onPrimary: Colors.black,
                  onSecondary: Colors.white,
                  onSurface: Colors.black,
                  error: Colors.red,
                ),
                inputDecorationTheme: const InputDecorationTheme(
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey, width: 2),
                  ),
                  labelStyle: TextStyle(color: Colors.grey),
                ),
                textButtonTheme: TextButtonThemeData(
                  style: TextButton.styleFrom(foregroundColor: Colors.black),
                ),
                outlinedButtonTheme: OutlinedButtonThemeData(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.black,
                    side: const BorderSide(color: Colors.black),
                     shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24.0),
                    ),
                    
                    ),
                ),
                elevatedButtonTheme: ElevatedButtonThemeData(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24.0),
                    ),
                  ),
                ),
              ),
              darkTheme: ThemeData(
                useMaterial3: false,
                textTheme: GoogleFonts.montserratTextTheme(
                  Theme.of(context).textTheme.apply(
                        bodyColor: Colors.white,
                        displayColor: Colors.white,
                      ),
                ),
                brightness: Brightness.dark,
                primaryColor: Colors.grey[900],
                scaffoldBackgroundColor: Colors.grey[900],
                appBarTheme: AppBarTheme(
                  backgroundColor: Colors.grey[900],
                  foregroundColor: Colors.white,
                  elevation: 0,
                ),
                colorScheme: ColorScheme.dark(
                  primary: Colors.grey[900]!,
                  secondary: Colors.grey,
                  surface: const Color.fromRGBO(33, 33, 33, 1),
                  onPrimary: Colors.white,
                  onSecondary: Colors.black,
                  onSurface: Colors.white,
                  error: Colors.redAccent,
                ),
                inputDecorationTheme: const InputDecorationTheme(
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white, width: 2),
                  ),
                  labelStyle: TextStyle(color: Colors.white),
                ),
                textSelectionTheme: const TextSelectionThemeData(
                  cursorColor: Colors.white,
                  selectionColor: Colors.grey,
                  selectionHandleColor: Colors.white,
                ),
                textButtonTheme: TextButtonThemeData(
                  style: TextButton.styleFrom(foregroundColor: Colors.white),
                ),
                outlinedButtonTheme: OutlinedButtonThemeData(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white, 
                    side: const BorderSide(color: Colors.white),
                     shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24.0),
                    ),
                    ),
                
                ),
                elevatedButtonTheme: ElevatedButtonThemeData(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.grey[900]!,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24.0),
                    ),
                  ),
                ),
              ),
              themeMode: themeMode,
              home: const AuthWrapper(),
            );
          },
        );
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData) {
          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection('users')
                .doc(snapshot.data!.uid)
                .get(const GetOptions(source: Source.server)), // Force server fetch
            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              if (userSnapshot.hasError || !userSnapshot.data!.exists) {
                FirebaseAuth.instance.signOut();
                return const AuthScreen();
              }

              final userData =
                  userSnapshot.data!.data() as Map<String, dynamic>;
              final role = userData['role'];

              if (role == 'Administrator') {
                return const AdminDashboardPage();
              } else if (role == 'Client') { // Add this condition for the Client role
                return const ClientDashboardPage();
              } else {
                return const UserHomeScreen();
              }
            },
          );
        }

        return const AuthScreen();
      },
    );
  }
}
