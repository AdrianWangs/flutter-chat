
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_demo/env/Env.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../chat/ChatPage.dart';

/// 好友的实体类
class Friend{
  String account;
  String nickname;
  String avatarUrl;
  bool isOnline;

  Friend({

    required this.account,
    required this.nickname,
    required this.avatarUrl,
    required this.isOnline,
  });

  @override
  String toString() {
    // TODO: implement toString
    return jsonEncode({
      'account': account,
      'nickname': nickname,
      'avatarUrl': avatarUrl,
      'isOnline': isOnline,
    });
  }

}

class FriendListModel with ChangeNotifier {
  //好友列表,使用Map来存储好友信息,方便通过id来查找好友和去重
  final Map<String, Friend> _friends = {};

  List<Friend> get friends => _friends.values.toList();

  void addFriend(Friend friend) {
    _friends[friend.account] = friend;
    notifyListeners();
  }

  void addAll(List<Friend> friends) {


    _friends.clear();

    friends.forEach((friend) {
      print(friend);
      _friends[friend.account] = friend;
    });


    notifyListeners();
  }

}


class FriendList extends StatelessWidget{



  var context;

  FriendList({super.key});

  //通过网络获取好友列表
  void setFriendList() async{



    List<Friend> friends = [];

    //从SharedPreferences中获取cookie
    SharedPreferences prefs = await SharedPreferences.getInstance();


    try{
      //从prefs中获取friendList
      String friendJson = prefs.getString("friendList")!;

      if(friendJson != null && friendJson != ""){


        //将friendList转换为List
        List friendListJson = jsonDecode(friendJson);

        //将friendListJson转换为List<Friend>
        friendListJson.forEach((friend) {
          friends.add(Friend(
            account: friend["account"],
            nickname: friend["nickname"],
            avatarUrl: friend["avatarUrl"],
            isOnline: friend["isOnline"],
          ));
        });
      }
    }catch(e){
      print(e);
    }

    String? cookie = prefs.getString('cookie');
    if(cookie == null){
      throw Exception('cookie为空');
    }


    //使用cookie发送请求,使用dio库发送请求
    var dio = Dio();
    dio.options.headers['cookie'] = cookie;
    var response = await dio.get(Env.HOST + '/friendList');



    //返回数据格式：
    // [{
    // "id": 1,
    // "userId": 1,
    // "friendId": 2,
    // "friendName": "王宇哲2",
    // "friendAccount":"0301700164",
    // "friendAvatarUrl": "x",
    // "friendSex": 0,
    // "addTime": "2022-12-31 21:40:21"}]
    //将返回的数据转换为List<Map<String, dynamic>>
    List<Map<String, dynamic>> friendList = (response.data as List).cast();
    //将List<Map<String, dynamic>>转换为List<Friend>


    prefs.setString('friendList', jsonEncode(friendList));

    friends = friendList.map((e) => Friend(
      account: e['friendAccount'],
      nickname: e['friendName'],
      avatarUrl: e['friendAvatarUrl'],
      isOnline: true,
    )).toList();



    //将好友列表添加到FriendListModel中
    Provider.of<FriendListModel>(context, listen: false).addAll(friends);

  }



  @override
  Widget build(BuildContext context) {

    setFriendList();

    return ChangeNotifierProvider(
      create: (context) => FriendListModel(),
      child: Consumer<FriendListModel>(
        builder: (context, friendListModel, child) {
          this.context = context;
          return Scaffold(
            body: ListView.builder(
              itemCount: friendListModel.friends.length,
              itemBuilder: (context, index) {

                var friend = friendListModel.friends[index];


                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(friendListModel.friends[index].avatarUrl),
                  ),
                  title: Text(friendListModel.friends[index].nickname),
                  subtitle: Text(friendListModel.friends[index].account),
                  trailing: friendListModel.friends[index].isOnline ? Icon(Icons.circle, color: Colors.green,) : Icon(Icons.circle, color: Colors.grey,),
                  onTap: () {
                    Navigator.push(
                      this.context,
                      MaterialPageRoute(builder: (context) {
                        return ChatPage(account: friend.account,nickname: friend.nickname,avatarUrl: friend.avatarUrl,);
                      }),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );

  }


}