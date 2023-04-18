
import 'package:flutter/material.dart';
import 'package:flutter_demo/env/Env.dart';
import 'package:flutter_demo/pages/friend/AddFriendPage.dart';
import 'package:flutter_demo/tools/HttpTool.dart';

import '../../common/Global.dart';
import '../../common/WebSocketManager.dart';


class FriendItem extends StatelessWidget {

  final Map<String, dynamic> userData;

  const FriendItem({Key? key, required this.userData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        child: Text(userData['name'][0]),
      ),
      title: Text(userData['name']),
      subtitle: Text(userData['account']),
      trailing: ElevatedButton(
        onPressed: () async {
          var response = await HttpTool.get("${Env.HOST}/addFriend/${userData['id']}", params: {});

          //如果返回true，说明添加成功
          if (response.data || response.data == 'true') {


            //通过websocket发送添加好友的消息
            sendRequestNotification(
              Global.user['avatarUrl'],
              Global.user['nickname'],
              Global.user['account'],
              userData['account']
            );
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('已发送申请'),
              ),
            );


          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('添加失败，请联系管理员'),
              ),
            );
          }

        },
        child: const Text('添加好友'),
      ),
    );
  }

  void sendRequestNotification(myAvatarUrl, myNickName, myAccount, receiverAccount) {
    WebSocketManager.sendMessage({
      'type': 'add',
      'sender': {
        'avatarUrl': myAvatarUrl,
        'nickname': myNickName,
        'account': myAccount
      },
      'receiver': {
        'account': receiverAccount,
      },
      'message': {
      },
      'timestamp': DateTime.now().millisecondsSinceEpoch
    });
  }
}


class AddFriendStat extends State<AddFriendPage> {
  late TextEditingController _searchController;
  List<Map<String, dynamic>> _searchResults = [];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  Future<void> _search() async {
    String keyword = _searchController.text;

    var response = await HttpTool.get("${Env.HOST}/searchUser/$keyword", params: {});

    //将搜索结果保存到 _searchResults 中
    List<Map<String, dynamic>> searchResults = [];
    for (var item in response.data) {
      searchResults.add(item);
    }

    setState(() {
      _searchResults = searchResults;
    });
  }

  Widget _buildSearchBar() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              hintText: '请输入用户名或账号',
            ),
          ),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: _search,
          child: const Text('搜索'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('添加好友'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: _buildSearchBar(),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _searchResults.length,
              itemBuilder: (context, index) {
                Map<String, dynamic> itemData = _searchResults[index];
                return FriendItem(
                  userData: itemData,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}


