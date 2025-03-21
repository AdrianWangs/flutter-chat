import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../env/Env.dart';
import '../../tools/HttpTool.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}
//一个简单的登录页面，有用户名和密码输入框，登录按钮
class _LoginPageState extends State<LoginPage> {

  String username = '';
  String password = '';


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('登录'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[

            Container(
              width: 300,
              //垂直外边距
              margin: const EdgeInsets.only(bottom: 20),
              child:TextField(
                onChanged: (value){
                  username = value;
                },
                decoration: const InputDecoration(
                  hintText: '请输入用户名',
                  border: OutlineInputBorder(),
                ),
              ),
            ),

            Container(
              width: 300,
              //垂直外边距
              margin: const EdgeInsets.only(bottom: 20),
              child: TextField(
                onChanged: (text) {
                  password = text;
                },
                //隐藏输入内容
                obscureText: true,
                decoration:const InputDecoration(
                  hintText: '请输入密码',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            SizedBox(
              width: 130,
              height: 40,
              child: ElevatedButton(
                onPressed: login,
                child: const Text('登录'),
              ),
            ),
            //注册按钮
            TextButton(
              onPressed: (){
                Navigator.pushNamed(context, '/register');
              },
              child: const Text('注册'),
            )
          ],
        ),
      ),
    );
  }

  void login() async{

    final loginUrl = '${Env.HOST}/user/$username/$password';


    if (kDebugMode) {
      print("loginUrl: $loginUrl");
    }

    final Response response;

    try{
      response = await Dio().get(loginUrl);
    }catch(e){
      showErrorMessage('帐号或密码错误');
      return;
    }


    if(response.statusCode == 200 && response.data['id'] != 0){

      //获取cookie
      final cookie = response.headers['set-cookie'];

      //保存cookie
      SharedPreferences prefs = await SharedPreferences.getInstance();

      prefs.setString('cookie', cookie!.first);

      //顺便将用户信息保存起来
      prefs.setString('userInfo', jsonEncode(response.data));

      HttpTool.headers['cookie'] = cookie!.first;

      //显示登录成功
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('登录成功'))
      );

      //跳转到首页
      Navigator.pushNamed(context, '/home');

    }else{
      showErrorMessage('登录失败');
    }
  }


  void showErrorMessage(String message){
    //登录失败，弹出提示框
    showDialog(
        context: context,
        builder: (context){
          return AlertDialog(
            title: const Text('提示'),
            content: Text(message),
            actions: <Widget>[
              TextButton(
                onPressed: (){
                  Navigator.of(context).pop();
                },
                child: const Text('确定'),
              )
            ],
          );
        }
    );
  }

}