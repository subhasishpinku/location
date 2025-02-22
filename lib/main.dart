import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bloc/auth_bloc.dart';
import 'services/api_service.dart';
import 'screens/login_screen.dart';
import 'dart:async';

import 'package:assignmentsubhasish/bloc/auth_event.dart';
import 'package:assignmentsubhasish/db/database_helper.dart';
import 'package:assignmentsubhasish/services/api_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
  syncOfflineData();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthBloc(apiService: ApiService()),
      child: MaterialApp(
        title: 'Flutter Auth',
        home: LoginScreen(),
      ),
    );
  }
}

void syncOfflineData1() async {
  Timer.periodic(Duration(seconds: 30), (timer) async {
    if (await _hasInternet()) {
      List<Map<String, dynamic>> unsyncedUsers =
          await DatabaseHelper.instance.getUnsyncedUsers();

      for (var user in unsyncedUsers) {
        try {
          await ApiService().registerUser(RegisterUser(
            name: user['name'],
            email: user['email'],
            password: user['password'],
            phone: user['phone'],
            address: user['address'],
            latlong: user['latlong'],
            confirmPassword: user['confirm_password'],
            image: user['image'],
          ));
          await DatabaseHelper.instance.updateUserSynced(user['id']);
        } catch (e) {
          print("Sync failed: $e");
        }
      }
    }
  });
}
void syncOfflineData() async {
  Timer.periodic(Duration(seconds: 30), (timer) async {
    if (await _hasInternet()) {
      List<Map<String, dynamic>> unsyncedUsers =
          await DatabaseHelper.instance.getUnsyncedUsers();

      for (var user in unsyncedUsers) {
        try {
          await ApiService().registerUser(RegisterUser(
            name: user['name'],
            email: user['email'],
            password: user['password'],
            phone: user['phone'],
            address: user['address'],
            latlong: user['latlong'],
            confirmPassword: user['confirm_password'],
            image: user['image'],
          ));
          await DatabaseHelper.instance.updateUserSynced(user['id']);
        } catch (e) {
          print("Sync failed: $e");
        }
      }
    }
  });
}

Future<bool> _hasInternet() async {
  try {
    final result = await Dio().get('https://google.com');
    return result.statusCode == 200;
  } catch (_) {
    return false;
  }
}






// 1. Create a Registration Page with the following information
// a. First Name
// b. Last Name
// c. Contact No
// d. Email ID
// e. Password
// f. Confirm Password
// g. Current Location
// h. User Address (based in the current location)
// i. User Image
// 2. Create a Login Page with the following
// a. Email ID
// b. Password
// 3. After Login create a Screen where all the data is visible in the form format
// 4. In the screen a location icon will be there, tapping on that icon a route will be
// drawn to current location to that pre filled location during registration
// 5. If the Internet is not available, after registration data will be stored in a local
// database and when the internet will be available the data will be synced.
// a. You can use sqFlite or hive or any db as per your knowledge.
// 6. If data gets synced from a local db as soon as the app goes to the login screen
// and has to perform proper authentication.
// 7. Store the Token in your db for persistent app usage.
// 8. And perform Logout. https://striking-officially-imp.ngrok-free.app/api/auth/register 
// name
// email
// password
// phone
// address
// latlong
// confirm_password for register 
// image 
//   https://striking-officially-imp.ngrok-free.app/api/auth/login 
// email
// password for login

// https://striking-officially-imp.ngrok-free.app/api/auth/profile  
// Token
// <token>
// https://striking-officially-imp.ngrok-free.app/api/auth/logout


// I/flutter ( 4546): RgError Exception: Failed to register: The endpoint striking-officially-imp.ngrok-free.app is offline.