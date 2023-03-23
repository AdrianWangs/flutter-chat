import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:flutter_demo/env/Env.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/io.dart';
import 'package:provider/provider.dart';
import 'ChatPage.dart';
import 'dart:convert';
import 'package:flutter_demo/tools/database.dart';

class Chat {
  String id;
  String nickname;
  String avatarUrl;
  String lastMessage;
  String lastMessageTime;
  String account;

  Chat({
    required this.id,
    required this.nickname,
    required this.avatarUrl,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.account,
  });

  //重写toString方法，方便打印
  @override
  String toString() {
    //将数据转换为json格式
    return jsonEncode({
      'id': id,
      'nickname': nickname,
      'avatarUrl': avatarUrl,
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime,
      'account': account,
    });
  }
}

class ChatListModel with ChangeNotifier {
  //好友列表,使用Map来存储好友信息,方便通过id来查找好友和去重
  final Map<String, Chat> _chats = {};

  List<Chat> get chats => _chats.values.toList();

  void addChat(Chat chat) {
    _chats[chat.id] = chat;
    notifyListeners();
  }
}

// 实现好友列表的展示
class ChatList extends StatelessWidget {
  dynamic context;

  late IOWebSocketChannel channel;

  final _database = ChatDatabase();

  /**
   * 初始化websocket
   */
  void initWebSocket() async {


    //获取数据库中的的用户信息
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userInfo = prefs.getString('userInfo');
    if (userInfo == null) {
      return;
    }

    Map<String, dynamic> user = jsonDecode(userInfo);

    channel = IOWebSocketChannel.connect('${Env.SOCKET_HOST}/websocket/${user['id']}');

    //监听服务端的消息
    channel.stream.listen(
      recieveNewMessage,
    );
  }


  ChatList() {
    initWebSocket();


    //查询数据库中的聊天记录
    _database.select(_database.chatData).get().then((value) {
      //输出聊天记录
      print(value);
      value.forEach((element) {
        //将聊天记录添加到好友列表中


        Provider.of<ChatListModel>(context, listen: false).addChat(Chat(
          id: element.id.toString(),
          nickname: element.nickname,
          avatarUrl: element.avatarUrl,
          lastMessage: element.lastMessage,
          lastMessageTime: element.lastMessageTime,
          account: element.account,
        ));
      });
    });

  }

  //收到新消息后的处理事件
  void recieveNewMessage(message) {


    print("-------------------");

    print('收到服务端的消息：$message');

    //将字符串转换为json格式

    //将消息转换为json格式
    Map<String, dynamic> json;
    try {
      json = jsonDecode(message);
    } catch (e) {
      print("非json格式");
      return;
    }

    //获取消息类型
    String type = json['type'];

    //获取消息内容
    dynamic data = json['data'];


    //如果是好友列表消息
    if (data["type"] == 'message') {


      //json的格式：
      // {
      //
      //   "data": {
      //    "type": "message",
      //    "id": "1",
      //    "nickname": "测试",
      //    "avatarUrl": "https://wyz-1304875448.cos.ap-nanjing.myqcloud.com/imgsFromGiteed008f005ea6c4f63a325442cee728719_qq_30347475.jpg.png",
      //    "lastMessage": "你好",
      //    "lastMessageTime": "8-1 12:00",
      //    "account": "123456"
      //   }


      //将信息添加到最近聊天数据库中
      //先判断当前聊天是否已经存在
      _database.select(_database.recentChat)..where((tbl) => tbl.id.equals(data['id']))..get().then((value) {
        //如果存在
        if (value.isNotEmpty) {
          //更新聊天记录
          _database.update(_database.recentChat).replace(
              RecentChatCompanion(
                  id: Value(data['id']),
                  nickname: Value(data['nickname']),
                  avatarUrl: Value(data['avatarUrl']),
                  lastMessage: Value(data['lastMessage']),
                  lastMessageTime: Value(data['lastMessageTime']),
                  account: Value(data['account'])
              )
          );
        } else {
          //如果不存在
          //将信息添加到数据库中
          _database.into(_database.recentChat).insert(
              RecentChatCompanion.insert(
                  id: data['id'],
                  nickname: data['nickname'],
                  avatarUrl: data['avatarUrl'],
                  lastMessage: data['lastMessage'],
                  lastMessageTime: data['lastMessageTime'],
                  account: data['account']
              )
          );
        }
      });

      //TODO 消息标红

      //将信息添加到数据库中
      _database.into(_database.chatData).insert(
          ChatDataCompanion.insert(
              nickname: data['nickname'],
              avatarUrl: data['avatarUrl'],
              lastMessage: data['lastMessage'],
              lastMessageTime: data['lastMessageTime'],
              account: data['account']
          )
      );


      print("-------------------");

      //将消息添加到好友列表中
      addMessageList(data);
    }
  }

  void addMessageList(Map<String, dynamic> chatList) {
    Chat chat = Chat(
      id: chatList['id'],
      nickname: chatList['nickname'],
      avatarUrl: chatList['avatarUrl'],
      lastMessage: chatList['lastMessage'],
      lastMessageTime: chatList['lastMessageTime'],
      account: chatList['account'],
    );

    print("addMessageList:"+chat.toString());

    //将好友添加到好友列表中
    Provider.of<ChatListModel>(context, listen: false).addChat(chat);
  }

  //添加一个id
  var id = '0';

  @override
  Widget build(BuildContext context) {
    this.context = context;

    return ChangeNotifierProvider(
      create: (context) => ChatListModel(),
      child: Consumer<ChatListModel>(
        builder: (context, friendListModel, child) {
          this.context = context;
          return Scaffold(
              body: ListView.builder(
                itemCount: friendListModel.chats.length,
                itemBuilder: (context, index) {
                  final friend = friendListModel.chats[index];

                  return InkWell(
                    onTap: () {
                      //跳转到聊天页面
                      Navigator.push(this.context,
                          MaterialPageRoute(builder: (context) {
                            return ChatPage(account: friend.account,nickname: friend.nickname,avatarUrl: friend.avatarUrl);
                          }
                      ));
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
                      trailing: Text(friend.lastMessageTime,
                      style: const TextStyle(color: Colors.grey, fontSize: 14.0)),
                ),
              );
            },
          ));
        },
      ),
    );
  }
}
