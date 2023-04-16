import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_demo/env/Env.dart';
import 'package:flutter_demo/pages/home/HomePage.dart';
import 'package:flutter_demo/pages/home/LoginPage.dart';
import 'package:flutter_demo/setup.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  setupDataBases();

  realRunApp();
}

void realRunApp() async {
  bool isLogin = await LoginMsg.getLoginMsg();

  runApp(MaterialApp(
    title: 'Flutter Demo',
    theme: ThemeData(
      primarySwatch: Colors.blue,
    ),
    initialRoute: isLogin ? '/home' : '/login',
    routes: {
      '/home': (context) => MyHomePage(title: "消息列表"),
      '/login': (context) => LoginPage(),
    },
  ));
}

class LoginMsg {
  static Future<bool> getLoginMsg() async {
    var host = Env.HOST;


    SharedPreferences prefs = await SharedPreferences.getInstance();
    //获取cookie
    String? cookie = prefs.getString('cookie');
    if (cookie == null) {
      return false;
    }

    //使用cookie发送请求
    Dio dio = Dio();
    dio.options.headers['Cookie'] = cookie;

    try {
      Response response = await dio.get(host + '/userInfo');

      if (response.statusCode == 200 && response.data['id'] != 0) {


        print("-----------------getUserInfo-----------------");
        print(response.data);
        print("---------------------------------------");

        //顺便将用户信息保存起来
        prefs.setString('userInfo', jsonEncode(response.data));
        return true;
      }
    } catch (e) {

      print("-----------------error-----------------");
      print(e.toString());
      print("---------------------------------------");
      return false;
    }

    return false;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '小王聊天室',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: '消息列表'),
      routes: {'/login': (context) => const LoginPage()},
    );
  }
}
