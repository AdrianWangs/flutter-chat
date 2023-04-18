
import 'package:flutter/material.dart';
import 'package:flutter_demo/env/Env.dart';
import 'package:flutter_demo/pages/friend/FriendRequestList.dart';
import 'package:flutter_demo/tools/HttpTool.dart';


import '../../entity/FriendRequest.dart';

class FriendRequestListState extends State<FriendRequestList> {
  List<FriendRequest> _friendRequestList = [];

  @override
  void initState() {
    super.initState();
    _getFriendRequestList();
  }


  void approveFriendRequest(FriendRequest friendRequest) async {
    var response = await HttpTool.get("${Env.HOST}/addFriend/${friendRequest.userId}", params: {});
    if (response.data || response.data == 'true') {
      setState(() {
        _friendRequestList.remove(friendRequest);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('添加成功'),
        ),
      );
    }
  }

  void rejectFriendRequest(FriendRequest friendRequest) async {
    var response = await HttpTool.get("${Env.HOST}/refuseFriend/${friendRequest.userId}", params: {});
    if (response.data || response.data == 'true') {
      setState(() {
        _friendRequestList.remove(friendRequest);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('已拒绝'),
        ),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('好友申请列表'),
      ),
      body: ListView.builder(
        itemCount: _friendRequestList.length,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            leading: CircleAvatar(
              backgroundImage:
              NetworkImage(_friendRequestList[index].avatarUrl),
            ),
            title: Text(_friendRequestList[index].name),
            subtitle: Text(_friendRequestList[index].account),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                MaterialButton(
                  onPressed: () => approveFriendRequest(_friendRequestList[index]),
                  color: Colors.green,
                  textColor: Colors.white,
                  child: const Text('接受'),
                ),
                const SizedBox(width: 10,),
                MaterialButton(
                  onPressed: () => rejectFriendRequest(_friendRequestList[index]),
                  color: Colors.red,
                  textColor: Colors.white,
                  child: const Text('拒绝'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _getFriendRequestList() async {
    var response = await HttpTool.get("${Env.HOST}/friendRequest", params: {});

    List<FriendRequest> friendRequestList = [];
    for (var item in response.data) {
      friendRequestList.add(FriendRequest.fromJson(item));
    }
    setState(() {
      _friendRequestList = friendRequestList;
    });

  }
}
