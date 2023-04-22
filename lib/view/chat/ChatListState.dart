
// 实现好友列表的展示
import 'dart:convert';
import 'dart:ffi';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_demo/common/WebSocketManager.dart';
import 'package:provider/provider.dart';

import '../../entity/Chat.dart';
import '../../model/ChatListModel.dart';
import '../../pages/chat/ChatList.dart';
import '../../pages/chat/ChatPage.dart';
import '../../tools/database.dart';

class ChatListState extends State<ChatList> {
  late BuildContext copyContext;

  final _database = ChatDatabase();

  @override
  void initState() {
    super.initState();
    initWebSocket();
    updateChatList();
  }


  void updateChatList() {

    //查询数据库中的聊天记录
    _database.select(_database.recentChat).get().then((value) {

      //清空好友列表
      Provider.of<ChatListModel>(copyContext, listen: false).clearChatList();

      for (var element in value) {
        //将聊天记录添加到好友列表中
        Provider.of<ChatListModel>(copyContext, listen: false).addChat(Chat(
          nickname: element.nickname,
          avatarUrl: element.avatarUrl,
          lastMessage: element.lastMessage,
          lastMessageTime: element.lastMessageTime.toString(),
          account: element.account,
        ));
      }
    });
  }


  void updatePage() {

    //查看WebSocketManager中的receiveNewMessage方法是否还在监听
    WebSocketManager.addListener(receiveNewMessage);




    updateChatList();
  }


  /// 初始化websocket
  void initWebSocket() async {
    //获取数据库中的的用户信息

    //设置监听事件
    WebSocketManager.addListener(receiveNewMessage);

  }

  //收到新消息后的处理事件
  void receiveNewMessage(message) {
    //将字符串转换为json格式

    //将消息转换为json格式
    Map<String, dynamic> decodedMessage;
    try {
      decodedMessage = jsonDecode(message);
    } catch (e) {
      if (kDebugMode) {
        print("非json格式");
      }
      return;
    }


    if (decodedMessage["type"] != 'message'){
      return;
    }

    //如果是好友列表消息
    //将信息添加到最近聊天数据库中
    //先判断当前聊天是否已经存在
    _database.select(_database.recentChat)
      ..where(
              (tbl) => tbl.account.equals(decodedMessage['sender']["account"]))
      ..get().then((value) {


        //要显示的信息
        var displayMessage = "";

        switch(decodedMessage["message"]["type"]){
          case "text":
            displayMessage = decodedMessage["message"]["messageInfo"]["text"];
            break;
          case "image":
            displayMessage = "[图片]";
            break;
          case "voice":
            displayMessage = "[语音]";
            break;
          case "video":
            displayMessage = "[视频]";
            break;
          case "file":
            displayMessage = "[文件]";
            break;
          default:
            displayMessage = "[未知消息]";
            break;
        }

        //如果存在
        if (value.isNotEmpty) {
          //更新聊天记录
          //由于我是接收方，所以我要更新的是发送方的信息
          _database.update(_database.recentChat).replace(RecentChatCompanion(
              id: Value(value[0].id),
              nickname: Value(decodedMessage["sender"]['nickname']),
              avatarUrl: Value(decodedMessage["sender"]['avatarUrl']),
              lastMessage: Value(displayMessage),
              lastMessageTime: Value(decodedMessage["timestamp"]),
              senderAccount: Value(decodedMessage["sender"]['account']),
              receiverAccount: Value(decodedMessage["receiver"]['account']),
              account: Value(value[0].account)));
        } else {
          //如果不存在
          //将信息添加到数据库中
          _database.into(_database.recentChat).insert(
              RecentChatCompanion.insert(
                  nickname: decodedMessage["sender"]['nickname'],
                  avatarUrl: decodedMessage["sender"]['avatarUrl'],
                  lastMessage: displayMessage,
                  lastMessageTime: decodedMessage["timestamp"],
                  senderAccount: decodedMessage["sender"]['account'],
                  receiverAccount: decodedMessage["receiver"]['account'],
                  account: decodedMessage["receiver"]['account']));
        }
      });

    //TODO 消息标红

    //将信息添加到数据库中
    _database.into(_database.chatData).insert(ChatDataCompanion.insert(
      nickname: decodedMessage["sender"]['nickname'],
      avatarUrl: decodedMessage["sender"]['avatarUrl'],
      message: jsonEncode(decodedMessage['message']),
      messageTime: decodedMessage["timestamp"],
      senderAccount: decodedMessage["sender"]['account'],
      receiverAccount: decodedMessage["receiver"]['account'],
    ));

    setState(() {
      //将消息添加到好友列表中
      addMessageList(decodedMessage);
    });

  }

  void addMessageList(Map<String, dynamic> chatList) {

    if (kDebugMode) {
      print(chatList);
    }


    //要显示的信息
    var displayMessage = "";
    switch(chatList["message"]["type"]){
      case "text":
        displayMessage = chatList["message"]["messageInfo"]["text"];
        break;
      case "image":
        displayMessage = "[图片]";
        break;
      case "voice":
        displayMessage = "[语音]";
        break;
      case "video":
        displayMessage = "[视频]";
        break;
      case "file":
        displayMessage = "[文件]";
        break;
      default:
        displayMessage = "[未知消息]";
        break;

    }

    //将字符串转化为数字

    Chat chat = Chat(
        nickname: chatList['sender']['nickname'],
        avatarUrl: chatList['sender']['avatarUrl'],
        lastMessage: displayMessage,
        lastMessageTime: chatList['timestamp'].toString(),
        account: chatList['sender']['account']
    );

    //将好友添加到好友列表中
    Provider.of<ChatListModel>(copyContext, listen: false).addChat(chat);
  }

  //添加一个id
  var id = '0';

  @override
  Widget build(BuildContext context) {
    copyContext = context;

    return ChangeNotifierProvider(
      create: (context) => ChatListModel(),
      child: Consumer<ChatListModel>(
        builder: (context, friendListModel, child) {
          copyContext = context;
          return Scaffold(
              body: ListView.builder(
                itemCount: friendListModel.chats.length,
                itemBuilder: (context, index) {
                  Chat friend = friendListModel.chats.elementAt(index);

                  return InkWell(
                    onTap: () {
                      if (kDebugMode) {
                        print("============ThisFriend=============");
                        print(friend);
                        print("===================================");
                      }

                      //跳转到聊天页面
                      var result =  Navigator.push(this.context,
                          MaterialPageRoute(builder: (context) {
                            return ChatPage(
                                account: friend.account,
                                nickname: friend.nickname,
                                avatarUrl: friend.avatarUrl
                            );
                          }));

                      //页面返回后，更新好友列表
                      result.then((value) {
                        updatePage();
                      });

                    },
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(
                          friend.avatarUrl,
                        ),
                      ),
                      //点击好友头像，跳转到聊天页面
                      title: Text(friend.nickname),
                      subtitle: Text(friend.lastMessage),
                      trailing: Text(getTime(int.parse(friend.lastMessageTime)),
                          style:const TextStyle(color: Colors.grey, fontSize: 14.0)),
                    ),
                  );
                },
              )
          );
        },
      ),
    );
  }


  //根据根据时间和当前时间的差值，返回一个字符串
  String getTime(int timestamp) {
    DateTime now = DateTime.now();
    DateTime time = DateTime.fromMillisecondsSinceEpoch(timestamp);

    Duration diff = now.difference(time);

    print(diff.inMinutes);
    print(diff.inHours);
    print(diff.inDays);


    if (diff.inMinutes < 1) {
      return "刚刚";
    } else if (diff.inMinutes < 60) {
      return "${diff.inMinutes} 分钟前";
    } else if (now.year == time.year &&
        now.month == time.month &&
        now.day == time.day) {
      return "${time.hour}:${time.minute.toString().padLeft(2, '0')}";
    }else if (diff.inDays == 1 || (now.year == time.year &&
        now.month == time.month &&
        now.day - time.day == 1)) {
      return "昨天 ${time.hour}:${time.minute.toString().padLeft(2, '0')}";
    } else if (diff.inDays == 2) {
      return "前天 ${time.hour}:${time.minute.toString().padLeft(2, '0')}";
    } else {
      return "${time.year} 年 ${time.month} 月 ${time.day} 日";
    }
  }




}
