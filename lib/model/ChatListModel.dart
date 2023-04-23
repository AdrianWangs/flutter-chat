import 'package:flutter/cupertino.dart';

import '../entity/Chat.dart';

class ChatListModel with ChangeNotifier {
  //好友列表,使用Map来存储好友信息,方便通过id来查找好友和去重
  final Map<String, Chat> _chats = {};

  List<Chat> get chats => _chats.values.toList();

  void addChat(Chat chat) {

    print("============AddChat=============");
    print(chat);
    print("================================");
    chat.unreadMessageCount = _chats[chat.account]?.unreadMessageCount ?? 0;
    _chats[chat.account] = chat;

    notifyListeners();
  }

  void increaseUnreadMessageCount(String account) {

    _chats[account]!.unreadMessageCount++;

    print("============increaseUnreadMessageCount=============");
    print(_chats[account]?.unreadMessageCount.toString());
    notifyListeners();
  }

  void clearChatList() {
    _chats.clear();
    notifyListeners();
  }

}