import 'package:cc_counter/helper/keys.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:pocketbase/pocketbase.dart';

Future<bool> tryLogin(String pbAddr, String email, String password) async {
  final pb = PocketBase(pbAddr);
  try {
    final _ = await pb
        .collection(pbCollectionUsers)
        .authWithPassword(email, password);
    var secureStorage = GetIt.instance.get<FlutterSecureStorage>();
    GetIt.instance.registerSingleton(pb);
    await secureStorage.write(key: ssKeyPBAddr, value: pbAddr);
    await secureStorage.write(key: ssKeyPBEmail, value: email);
    await secureStorage.write(key: ssKeyPBPassword, value: password);
    return true;
  } catch (e) {
    debugPrint("Login failed");
    return false;
  }
}
