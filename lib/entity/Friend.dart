import 'dart:convert';

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