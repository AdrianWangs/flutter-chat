import 'dart:convert';
import 'dart:io';

import 'package:desktop_drop/desktop_drop.dart';
import 'package:drift/drift.dart' as drift;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_demo/common/Global.dart';
import 'package:flutter_demo/common/WebSocketManager.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_demo/tools/database.dart';

import '../pages/chat/ChatPage.dart';

class ChatPageState extends State<ChatPage> {
  final _database = ChatDatabase();

  // 定义私有变量
  late String _account;
  late String _nickname;
  late String _avatarUrl;

  late String _myAccount;
  late String _myNickname;
  late String _myAvatarUrl;
  late String _myId;

  String message = '';
  final List<Map<String, dynamic>> messages = [];

  //编辑文本框控制器
  final TextEditingController _controller = TextEditingController();

  //滚动控制器
  final ScrollController _scrollController = ScrollController();

  var tag = false;

  @override
  void initState() {
    super.initState();

    // 在构造函数中初始化私有变量
    _account = widget.account;
    _nickname = widget.nickname;
    _avatarUrl = widget.avatarUrl;

    init();
  }


  /// ///////////////////////
  ///  初始化             ///
  /// 1.获取用户信息       ///
  /// 2.连接WebSocket    ///
  /// 3.监听WebSocket消息 ///
  /// /////////////////////
  void init() async {

    //初始化私有变量
    _myAccount = Global.user["account"];
    _myNickname = Global.user["name"];
    _myAvatarUrl = Global.user["avatarUrl"];
    //将int类型的id转换为String类型
    _myId = Global.user["id"].toString();

    //从本地数据库中获取聊天记录
    getDataFromDatabase();
    //初始化WebSocket
    initWebSocket();
  }




  ///从本地数据库中获取聊天记录
  void getDataFromDatabase(){
    //查询数据库中的聊天记录
    _database.select(_database.chatData)
    //发送方或者接收方是当前用户的聊天记录
      ..where((tbl) =>
      (tbl.senderAccount.equals(_myAccount) &
      tbl.receiverAccount.equals(_account)
      )|(
          tbl.senderAccount.equals(_account) &
          tbl.receiverAccount.equals(_myAccount)
      )
      )
      ..get().then((value) {
        for (var element in value) {

          if (kDebugMode) {
            print("=============从数据库中获取到的聊天记录==========");
            print(element);
          }




          //将聊天记录添加到消息列表中
          setState(() {
            messages.add({
              'type': 'message',
              'sender': {
                'avatarUrl': element.avatarUrl,
                'nickname': element.nickname,
                'account': element.senderAccount
              },
              'receiver': {
                'account': element.receiverAccount,
              },
              'message': jsonDecode(element.message),
              'timestamp': element.messageTime
            });
          });
        }
      });
  }

  ///初始化WebSocket
  ///即设置连接地址，开始监听消息
  void initWebSocket() {

    WebSocketManager.addListener(handleMessage);

  }

  //消息处理
  void handleMessage(message) {

    //开始处理消息
    if (kDebugMode) {
      print("=============开始处理websocket获取到的消息==========");
    }

    //将消息转换为Map
    Map<String, dynamic> messageMap = jsonDecode(message);

    setState(() {
      //将消息添加到消息列表中
      messages.add(messageMap);
    });

    showNewMessage();

    //结束处理消息
    if (kDebugMode) {
      print("=============结束处理websocket获取到的消息==========");
    }

  }

  ///在浏览其他信息时，收到新消息时，显示新消息提示
  void showNewMessage(){

    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          margin: const EdgeInsets.only(bottom: 50),
          behavior: SnackBarBehavior.floating,
          content: const Text('收到新消息'),
          action: SnackBarAction(
            label: '查看',
            onPressed: () {
              reachBottom();
            },
          ),
        )
    );

  }



  void sendMessage() {
    if (message.isNotEmpty) {
      //清空输入框
      FocusScope.of(context).requestFocus(FocusNode());

      //数据格式
      // {
      //     "type": "message",
      //     "sender": {
      //        "avatarUrl":"https://xxxxx",
      //        "nickname": "xxxxx",
      //        "account": "020301700164"
      //      },
      //     "receiver": {
      //        "account": "351244716"
      //     },
      //     "message": {
      //        "type": "text",
      //        "messageInfo": {
      //           "text": "xxxxx"
      //        }
      //      },
      //     "timestamp": 1588888888888
      // }

      sendData({
        'type': 'message',
        'sender': {
          'avatarUrl': _myAvatarUrl,
          'nickname': _myNickname,
          'account': _myAccount
        },
        'receiver': {
          'account': _account,
        },
        'message': {
          'type': 'text',
          'messageInfo': {
            'text': message,
          }
        },
        'timestamp': DateTime.now().millisecondsSinceEpoch
      });
    }
  }

  void sendData(Map<String, dynamic> data) {

    //通过WebSocket发送消息
    //检查channel是否已经连接
    // ignore: unnecessary_null_comparison
    if (WebSocketManager.webSocketChannel?.sink != null) {
      //将消息转换为json字符串，消息中存在的时间戳需要转换为字符串
      // Map<String, dynamic> messageMap = {};

      //------------------------------
      //查询数据库中是否存在该聊天
      //将数据插入到数据库中
      //将信息添加到最近聊天数据库中
      //先判断当前聊天是否已经存在
      //将消息存到本地数据库中
      //发送消息一定是发送给别人的，故sender为自己，receiver为对方
      //------------------------------
      _database.select(_database.recentChat)
        ..where((tbl) => tbl.account.equals(data["receiver"]["account"]))
        ..get().then((value) {

          //要显示的信息
          var displayMessage = "";
          switch(data["message"]["type"]){
            case "text":
              displayMessage = data["message"]["messageInfo"]["text"];
              break;
          }

          //如果存在
          if (value.isNotEmpty) {


            //更新聊天记录
            _database.update(_database.recentChat).replace(RecentChatCompanion(
                id: drift.Value(value[0].id),
                nickname: drift.Value(data["sender"]["nickname"]),
                avatarUrl: drift.Value(data["sender"]["avatarUrl"]),
                lastMessage: drift.Value(displayMessage),
                lastMessageTime: drift.Value(data["timestamp"]),
                senderAccount: drift.Value(value[0].senderAccount),
                receiverAccount: drift.Value(value[0].receiverAccount),
                account: drift.Value(value[0].account))
            );
          } else {
            //如果不存在
            //将信息添加到数据库中
            _database.into(_database.recentChat).insert(RecentChatCompanion.insert(
                nickname: data["sender"]["nickname"],
                avatarUrl: data["sender"]["avatarUrl"],
                lastMessage: displayMessage,
                lastMessageTime: data["timestamp"],
                senderAccount: data["sender"]["account"],
                receiverAccount: data["receiver"]["account"],
                account: data["receiver"]["account"]));
          }
        });
      _database.into(_database.chatData).insert(ChatDataCompanion.insert(
          nickname: data["sender"]["nickname"],
          avatarUrl: data["sender"]["avatarUrl"],
          message: jsonEncode(data["message"]),
          messageTime: data["timestamp"],
          senderAccount: data["sender"]["account"],
          receiverAccount: data["receiver"]["account"]));

      //将消息发送到服务器

      WebSocketManager.sendMessage(jsonEncode(data));
    } else {
      if (kDebugMode) {
        print("websocket未连接");
      }
    }

    setState(() {

      messages.add(data);

      message = '';
      //按照时间戳排序
      messages.sort((a, b) {
        return a['timestamp'].compareTo(b['timestamp']);
      });

      _controller.clear();
    });

    //滚动到最后一条消息
    reachBottom();

  }

  ///滚动到最后一条消息
  void reachBottom() {
    //等一秒后再滚动到最后一条消息
    Future.delayed(const Duration(milliseconds: 100), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 50,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOut,
      );
    });
  }


  @override
  Widget build(BuildContext context) {


    return Scaffold(
      appBar: AppBar(
        title: Text(_nickname),
      ),
      body: Column(
        children: <Widget>[
          //添加一个空白区域

          DropTarget(
            onDragDone: _dragDone,
            onDragUpdated: (details) => {
              if (!tag)
                {
                  tag = true,
                  //将整个界面使用一个遮罩层覆盖
                  showDialog(
                      context: context,
                      builder: (context) {
                        return Container(
                          color: Colors.grey.withOpacity(0.5),
                          child: const Center(
                            child: Text(
                              '松开鼠标发送',
                              style:
                              TextStyle(color: Colors.white, fontSize: 20),
                            ),
                          ),
                        );
                      })
                }
            },
            onDragExited: (details) =>
            {tag = false, Navigator.of(context).pop()},
            child: Expanded(
              child: ListView.builder(
                controller: _scrollController,
                itemCount: messages.length,
                itemBuilder: (context, index) {

                  final message = messages[index];

                  final type = message["message"]['type'];
                  final isMe = message["sender"]['account'] == _myAccount;

                  final avatarUrl = message["sender"]['avatarUrl'];
                  final nickname = message["sender"]['nickname'];
                  final timestamp = message['timestamp'];

                  var text = "";

                  if(type == "text"){
                    text = message["message"]['messageInfo']['text'];
                  }else{
                    text = "文件";
                  }

                  return ListTile(

                    //如果是自己发送的消息，就显示在右边，否则显示在左边
                    leading: isMe
                        ? null
                        : CircleAvatar(
                      backgroundImage: NetworkImage(avatarUrl),
                    ),
                    trailing: isMe
                        ? CircleAvatar(
                      backgroundImage: NetworkImage(avatarUrl),
                    )
                        : null,


                    title: LayoutBuilder(
                      builder: (context, constraints) {

                        //这边开始是消息气泡
                        final textPainter = TextPainter(
                          text: TextSpan(
                            text: text,
                            style: DefaultTextStyle.of(context).style,
                          ),
                          maxLines: 1,
                          textDirection: TextDirection.ltr,
                        );
                        textPainter.layout();
                        var maxWidth = textPainter.width + 40;

                        Widget title;
                        if (type == 'image') { //如果发来的是图片
                          String imageUrl = message['imageUrl'];
                          if (imageUrl.split(":").first != "http" ||
                              imageUrl.split(":").first != "https") {
                            title = Image.file(
                              File(imageUrl),
                              fit: BoxFit.cover,
                            );
                          } else {
                            title = Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                            );
                          }

                          maxWidth = constraints.maxWidth * 0.8;
                        } else if (type == 'file') {
                          var fileSize = message['fileSize'];
                          var fileName = message['fileName'];
                          var fileUrl = message['fileUrl'];

                          var size = double.parse(fileSize);
                          if (size > 1024 * 1024 * 1024) {
                            fileSize =
                            '${(size / (1024 * 1024 * 1024)).toStringAsFixed(2)}GB';
                          } else if (size > 1024 * 1024) {
                            fileSize =
                            '${(size / (1024 * 1024)).toStringAsFixed(2)}MB';
                          } else if (size > 1024) {
                            fileSize = '${(size / 1024).toStringAsFixed(2)}KB';
                          } else {
                            fileSize = '${size.toStringAsFixed(2)}B';
                          }

                          title = Container(
                            child: Row(
                              children: <Widget>[
                                Icon(
                                  //根据页面宽度计算图标大小
                                  size: constraints.maxWidth * 0.2,
                                  Icons.insert_drive_file,
                                  color: Colors.blue,
                                ),
                                const SizedBox(
                                  width: 4,
                                ),
                                Flexible(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          fileName,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          fileSize,
                                          style:
                                          Theme.of(context).textTheme.bodySmall,
                                        ),
                                      ],
                                    ))
                              ],
                            ),
                          );
                          maxWidth = constraints.maxWidth * 0.8;
                          // title = Image.network(
                          //   text,
                          //   fit: BoxFit.cover,
                          // );
                        } else {

                          title = Text(
                            text,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: isMe ? TextAlign.right : TextAlign.left,
                          );
                        }

                        return Align(
                            alignment: isMe
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Container(
                              decoration: BoxDecoration(
                                // color:
                                //     // isMe ? Colors.lightBlueAccent : Colors.white,
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              width: maxWidth,
                              child: Card(
                                child: ListTile(title: title),
                              ),
                            ));
                      },
                    ),
                  );
                },
              ),
            ),
          ),
          Row(
            children: <Widget>[
              Expanded(
                child: TextField(
                  controller: _controller,
                  onChanged: (value) {
                    setState(() {
                      message = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: '输入信息',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                  ),
                ),
              ),
              //发送图片按钮
              IconButton(
                icon: Icon(Icons.image),
                color: Colors.blue,
                onPressed: chooseImage,
              ),
              //发送文件按钮
              IconButton(
                icon: Icon(Icons.attach_file),
                color: Colors.blue,
                onPressed: chooseFile,
              ),
              IconButton(
                icon: Icon(Icons.send),
                color: Colors.blue,
                onPressed: sendMessage,
              ),
            ],
          ),
        ],
      ),
    );
  }

  void chooseImage() async {
    final ImagePicker _picker = ImagePicker();
    File _userImageFile;

    var onceimages = await _picker.pickImage(source: ImageSource.camera);

    List<File> images = [];
    images.add(File(onceimages!.path));
    for (var image in images) {
      sendImage(image.path);
    }
  }

  void chooseFile() async {}

  void sendImage(String imageUrl) {
    sendData({
      'type': 'image',
      'sender': 'me',
      'text': '',
      'imageUrl': imageUrl,
      'timestamp': DateTime.now(),
      'nickname': 'Me',
      'avatarUrl': 'https://www.baidu.com/img/bd_logo1.png?where=super'
    });
  }

  //拖拽发送文件
  void _dragDone(DropDoneDetails detail) {
    List<XFile> files = detail.files;

    for (var xfile in files) {
      File file = File(xfile.path);

      print("文件路径：${file.path}");
      //判断文件类型是否为图片
      switch (file.path.split('.').last) {
        case 'jpg':
        case 'png':
        case 'jpeg':
          sendImage(file.path);
          break;
      // case 'mp4':
      //   sendVideo();
      //   break;

        default:
          {
            //判断是不是文件夹
            if (FileSystemEntity.isDirectorySync(file.path)) {
              //层次遍历并发送文件
              Directory dir = Directory(file.path);
              List<FileSystemEntity> list = dir.listSync(recursive: true);
              for (var f in list) {
                if (FileSystemEntity.isFileSync(f.path)) {
                  String fileUrl = uploadFile(File(f.path));
                  sendFile(fileUrl, f.statSync().size.toString(),
                      f.path.split('/').last);
                }
              }
              return;
            } else {
              String fileUrl = uploadFile(file);
              sendFile(fileUrl, file.lengthSync().toString(),
                  file.path.split('/').last);
            }
          }
      }
    }
  }


  void sendFile(String fileUrl, String fileSize, String fileName) {
    sendData({
      'type': 'file',
      'sender': 'me',
      'text': '',
      'fileUrl': fileUrl,
      'fileSize': fileSize,
      'fileName': fileName,
      'timestamp': DateTime.now(),
      'nickname': 'Me',
      'avatarUrl': 'https://www.baidu.com/img/bd_logo1.png?where=super'
    });
  }

  ///上传文件
  ///返回文件的url
  String uploadFile(File file) {
    return '';
  }

}
