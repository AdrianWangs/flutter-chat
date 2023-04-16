import 'dart:convert';

class Chat {
  String nickname;
  String avatarUrl;
  String lastMessage;
  String lastMessageTime;
  String account;

  Chat({
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
      'nickname': nickname,
      'avatarUrl': avatarUrl,
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime,
      'account': account,
    });
  }
}