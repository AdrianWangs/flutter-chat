import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/io.dart';
import 'package:provider/provider.dart';
import 'ChatPage.dart';
import 'dart:convert';

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
  var context;

  late IOWebSocketChannel channel;

  void initWebSocket() async {
    print("initWebSocket");
    //获取数据库中的的用户信息
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userInfo = prefs.getString('userInfo');
    if (userInfo == null) {
      return;
    }

    Map<String, dynamic> user = jsonDecode(userInfo);

    channel = IOWebSocketChannel.connect(
        'ws://localhost:8080/websocket/${user['id']}');

    print(user['id']);

    //监听服务端的消息
    channel.stream.listen(
      recieveNewMessage,
    );
  }

  ChatList({Key? key}) {
    //
    // //  获取本地账号信息并发送给服务端，服务端会将该账号加入到在线列表中
    // Chat test = Chat(
    //   id: '0',
    //   nickname: '测试',
    //   avatarUrl:
    //       'https://wyz-1304875448.cos.ap-nanjing.myqcloud.com/imgsFromGiteed008f005ea6c4f63a325442cee728719_qq_30347475.jpg.png',
    //   lastMessage: '你好',
    //   lastMessageTime: "8-1 12:00",
    // );

    initWebSocket();
  }

  //收到新消息后的处理事件
  void recieveNewMessage(message) {
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
    if (type == 'message') {


      //json的格式：
      // {
      //   "type": "message",
      //   "data": {
      //    "id": "1",
      //    "nickname": "测试",
      //    "avatarUrl": "https://wyz-1304875448.cos.ap-nanjing.myqcloud.com/imgsFromGiteed008f005ea6c4f63a325442cee728719_qq_30347475.jpg.png",
      //    "lastMessage": "你好",
      //    "lastMessageTime": "8-1 12:00",
      //    "account": "123456"
      //   }

      //将消息转换为json格式
      Map<String, dynamic> friendList = jsonDecode(data);

      addMessageList(friendList);
    }
  }

  void addMessageList(Map<String, dynamic> friendList) {
    Chat friend = Chat(
      id: friendList['id'],
      nickname: friendList['nickname'],
      avatarUrl: friendList['avatarUrl'],
      lastMessage: friendList['lastMessage'],
      lastMessageTime: friendList['lastMessageTime'],
      account: friendList['account'],
    );

    //将好友添加到好友列表中
    Provider.of<ChatListModel>(context, listen: false).addChat(friend);
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
                            return ChatPage(account: friend.account);
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
