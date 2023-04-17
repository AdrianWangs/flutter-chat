import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_demo/common/WebSocketManager.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../common/Global.dart';
import '../../env/Env.dart';
import '../chat/ChatList.dart';
import '../friend/FriendList.dart';
import '../friend/AddFriendPage.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  String _title = "";
  int _selectedIndex = 0;
  Widget body = ChatList();
  bool _showAddButton = false;

  @override
  void initState() {
    super.initState();

    _title = widget.title;

    initData();

  }

  void initData() async {
    Global.prefs ??= await SharedPreferences.getInstance();

    String? userInfo = Global.prefs?.getString('userInfo');
    if (userInfo == null) {
      return;
    }

    Global.user = jsonDecode(userInfo);

    connectWebSocket();

  }

  void connectWebSocket() async {
    WebSocketManager.connect('${Env.SOCKET_HOST}/websocket/${Global.user['id']}');
  }

  void jumpTo(int index){
    setState(() {
      _selectedIndex = index;
      switch(index){
        case 0:
          body = ChatList();
          _title = "消息列表";
          _showAddButton = false;
          break;
        case 1:
          body = FriendList();
          _title = "好友列表";
          _showAddButton = true;
          break;
        case 2:
          _showAddButton = false;
          //TODO 其他页面
          break;
        case 3:
          _showAddButton = false;
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_title),
        actions: <Widget>[

          if (_showAddButton)
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              onPressed: () {
                // print("页面跳转");
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddFriendPage()),
                );
              },
            ),

        ],
      ),
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
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            label: '聊天列表',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: '好友列表',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color.fromARGB(255, 38, 118, 192),
        onTap: jumpTo,
      ),
    );
  }
}
