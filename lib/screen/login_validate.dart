import 'package:cc_counter/helper/keys.dart';
import 'package:cc_counter/helper/pb.dart';
import 'package:cc_counter/screen/login.dart';
import 'package:cc_counter/screen/ongoing_sessions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';

class CCLoginValidate extends StatefulWidget {
  const CCLoginValidate({super.key});

  @override
  State<CCLoginValidate> createState() => _CCLoginValidateState();
}

class _CCLoginValidateState extends State<CCLoginValidate> {
  bool processing = true;

  void toLogin() {
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => CCLogin()),
        (x) => true,
      );
    }
  }

  Future<void> readKeysAndLogin() async {
    final getit = GetIt.instance;
    final secureStorage = getit.get<FlutterSecureStorage>();
    final pbAddr = await secureStorage.read(key: ssKeyPBAddr);
    final pbEmail = await secureStorage.read(key: ssKeyPBEmail);
    final pbPassword = await secureStorage.read(key: ssKeyPBPassword);
    if (pbAddr == null ||
        pbAddr.isEmpty ||
        pbEmail == null ||
        pbEmail.isEmpty ||
        pbPassword == null ||
        pbPassword.isEmpty) {
      toLogin();
      return;
    }

    final loginSuccess = await tryLogin(pbAddr, pbEmail, pbPassword);
    if (loginSuccess) {
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => CCOnGoingSessions()),
          (r) => false,
        );
      }
    } else {
      toLogin();
    }
  }

  @override
  Widget build(BuildContext context) {
    readKeysAndLogin();
    return Scaffold(
      appBar: AppBar(title: Text("Cardio Controller Counter")),
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
