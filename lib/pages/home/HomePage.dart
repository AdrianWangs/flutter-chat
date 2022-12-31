import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../chat/ChatList.dart';
import '../friend/FriendList.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {


  //当前选中的tab
  int _selectedIndex = 0;

  //选中的页面
  Widget body = ChatList();

  ///底部导航栏点击事件
  void jumpTo(int index){
    setState(() {
      _selectedIndex = index;
      switch(index){
        case 0:
          body = ChatList();
          break;
        case 1:
          body = FriendList();
          break;
        case 2:
          break;
        case 3:
          break;
      }

    });
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      //首页使用FriendList
      body: body,
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: const <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Drawer Header',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.message),
              title: Text('Messages'),
            ),
            ListTile(
              leading: Icon(Icons.account_circle),
              title: Text('Profile'),
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Settings'),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items:const  <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            label: '聊天列表',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: '好友列表',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: '我的',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color.fromARGB(255, 38, 118, 192),
        onTap: jumpTo,
      ),
    );
  }
}
