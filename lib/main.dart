import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'chat/view.dart';

void main() {
  //在main函数第一行添加这句话
  WidgetsFlutterBinding.ensureInitialized();
  runApp(GetMaterialApp(
    home: ChatPage(),
  ));
}
