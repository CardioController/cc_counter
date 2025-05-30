import 'package:cc_counter/screen/login_validate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';

Future<void> main() async {
  AndroidOptions getAndroidOptions() =>
      const AndroidOptions(encryptedSharedPreferences: true);
  final storage = FlutterSecureStorage(aOptions: getAndroidOptions());

  final getIt = GetIt.instance;
  getIt.registerSingleton(storage);

  runApp(const CCCounterApp());
}

class CCCounterApp extends StatelessWidget {
  const CCCounterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cardio Controller Counter',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: CCLoginValidate(),
    );
  }
}
