
import 'package:flutter/material.dart';
import 'package:flutter_demo/env/Env.dart';
import 'package:flutter_demo/pages/friend/AddFriendPage.dart';
import 'package:flutter_demo/tools/HttpTool.dart';


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
        onPressed: () {
          // TODO 处理添加好友的逻辑
        },
        child: const Text('添加好友'),
      ),
    );
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


