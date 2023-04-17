
import 'package:flutter/material.dart';

import '../../view/chat/ChatPageState.dart';

class ChatPage extends StatefulWidget {
  final String account;
  final String nickname;
  final String avatarUrl;

  @override
  const ChatPage({
    Key? key,
    required this.account,
    required this.nickname,
    required this.avatarUrl,
  }) : super(key: key);

  @override
  ChatPageState createState() => ChatPageState();
}
