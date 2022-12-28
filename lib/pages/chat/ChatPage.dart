import 'dart:io';

import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  String message = '';
  final List<Map<String, dynamic>> messages = [];

  //编辑文本框控制器
  final TextEditingController _controller = TextEditingController();

  //滚动控制器
  final ScrollController _scrollController = ScrollController();

  var tag = false;

  void sendMessage() {
    if (message.isNotEmpty) {
      //清空输入框
      FocusScope.of(context).requestFocus(FocusNode());

      sendData({
        'type': 'text',
        'sender': 'me',
        'text': message,
        'timestamp': DateTime.now(),
        'nickname': 'Me',
        'avatarUrl': 'https://www.baidu.com/img/bd_logo1.png?where=super'
      });
    }
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

  String uploadFile(File file) {
    return '';
  }

  void sendData(Map<String, dynamic> data) {
    setState(() {
      messages.add(data);
      message = '';
      messages.sort((a, b) => a['timestamp'].compareTo(b['timestamp']));
      _controller.clear();
    });

    //等一秒后再滚动到最后一条消息
    Future.delayed(const Duration(milliseconds: 100), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 50,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOut,
      );
    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
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
                  final type = message['type'];
                  final isMe = message['sender'] == 'me';
                  final avatarUrl = message['avatarUrl'];
                  final nickname = message['nickname'];
                  final timestamp = message['timestamp'];
                  final text = message['text'];

                  return ListTile(
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
                        //这边开始是消息气泡
                        if (type == 'image') {
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
                                          Theme.of(context).textTheme.caption,
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
}