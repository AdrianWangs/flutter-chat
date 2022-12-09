// 好友列表页
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/painting.dart';

// 实现好友列表的展示
class FriendList extends StatelessWidget {
  const FriendList({Key? key}) : super(key: key);

  //动态加载好友列表
  List<Widget> _buildFriendList() {
    return <Widget>[
      //好友列表，显示头像，昵称，最后一条消息,以及时间
      const ListTile(
        leading: const CircleAvatar(
          backgroundImage:  NetworkImage(
              'https://wyz-1304875448.cos.ap-nanjing.myqcloud.com/imgsFromGiteed008f005ea6c4f63a325442cee728719_qq_30347475.jpg.png'),
        ),
        
        title: const Text('张三'),
        subtitle: const Text('你好'),
        trailing: const Text('昨天',
            style: const TextStyle(color: Colors.grey, fontSize: 14.0)),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: ListView(
      children: _buildFriendList(),
    ));
  }
}
