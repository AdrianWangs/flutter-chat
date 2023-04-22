import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:dio/dio.dart';
import 'package:drift/drift.dart' as drift;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_demo/common/Global.dart';
import 'package:flutter_demo/common/WebSocketManager.dart';
import 'package:flutter_demo/env/Env.dart';
import 'package:flutter_demo/tools/HttpTool.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_demo/tools/database.dart';
import 'package:crypto/crypto.dart';
import 'package:convert/convert.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';
import 'package:video_player_macos/video_player_macos.dart';


import '../../pages/chat/ChatPage.dart';


class UploadProcess {
  String fileName;
  double progress;
  bool isComplete = false;

  UploadProcess(this.fileName, this.progress, this.isComplete);
}


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

  late String _imagePath;

  late BuildContext copyContext;


  final List<UploadProcess> _uploadProcess = [];

  String message = '';
  final List<Map<String, dynamic>> messages = [];

  final Map<int, VideoPlayerController> _videoControllers = {};
  final Map<int,bool> _videoControllersIsInit = {};

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

    //跳到最后一条消息
    reachBottom();

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

  ///消息处理
  void handleMessage(message) {

    //开始处理消息
    if (kDebugMode) {
      print("=============开始处理websocket获取到的消息==========");
    }

    //将消息转换为Map
    Map<String, dynamic> messageMap = jsonDecode(message);

    if(messageMap['type']!='message'){

      print("=============websocket获取到的消息不是聊天消息==========");

      print(messageMap);

      return;
    }



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

    ScaffoldMessenger.of(copyContext).showSnackBar(
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

  ///点击按钮发送文本消息
  void sendMessage() {
    if (message.isNotEmpty) {
      //清空输入框
      FocusScope.of(copyContext).requestFocus(FocusNode());


      //TODO 发送消息显示的名称和头像应该是接受者的（在我发送的情况下）

      sendData({
        'type': 'message',
        'sender': {
          'avatarUrl': _myAvatarUrl,
          'nickname': _myNickname,
          'account': _myAccount
        },
        'receiver': {
          'account': _account,
          'nickname': _nickname,
          'avatarUrl': _avatarUrl
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

  ///发送消息的最终方法
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
            case "image":
              displayMessage = "[图片]";
              break;
            case "voice":
              displayMessage = "[语音]";
              break;
            case "video":
              displayMessage = "[视频]";
              break;
            case "file":
              displayMessage = "[文件]";
              break;
            default:
              displayMessage = "[未知消息]";
              break;
          }

          //如果存在
          if (value.isNotEmpty) {


            //更新聊天记录
            //由于最近聊天列表一定只显示对方的信息
            //故只需要更新为对方的信息即可
            _database.update(_database.recentChat).replace(RecentChatCompanion(
                id: drift.Value(value[0].id),
                nickname: drift.Value(_nickname),
                avatarUrl: drift.Value(_avatarUrl),
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
                nickname: _nickname,
                avatarUrl: _avatarUrl,
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
          receiverAccount: data["receiver"]["account"])
      );

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

  ///将文件大小转换为可读的字符串
  String parseFileSize(double size){
    if (size > 1024 * 1024 * 1024) {
      return '${(size / (1024 * 1024 * 1024)).toStringAsFixed(2)}GB';
    }
    if (size > 1024 * 1024) {
      return '${(size / (1024 * 1024)).toStringAsFixed(2)}MB';
    }
    if (size > 1024) {
      return '${(size / 1024).toStringAsFixed(2)}KB';
    }
    return '${size.toStringAsFixed(2)}B';
  }

  ///滚动到最后一条消息
  void reachBottom() {
    //等一秒后再滚动到最后一条消息
    Future.delayed(const Duration(milliseconds: 200), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 50,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {

    copyContext = context;

    return Scaffold(
      appBar: AppBar(
        title: Text(_nickname),
      ),
      body: Column(
        children: <Widget>[
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

                  //消息的类型
                  final type = message["message"]['type'];


                  //判断是否是自己发送的消息
                  final isMe = message["sender"]['account'] == _myAccount;


                  //发送者的信息
                  final avatarUrl = message["sender"]['avatarUrl'];
                  final nickname = message["sender"]['nickname'];
                  final timestamp = message['timestamp'];

                  //消息的内容
                  var text = "";
                  switch(type){
                    case "text":
                      text = message["message"]['messageInfo']['text'];
                      break;
                    case "file":
                      text = "文件";
                      break;
                    case "image":
                      text = "图片";
                      break;
                    case "video":
                      text = "视频";
                      break;
                  }



                  return ListTile(

                    //如果是自己发送的消息，就显示在右边，否则显示在左边
                    leading: isMe ? null : CircleAvatar(
                      backgroundImage: NetworkImage(avatarUrl),
                    ),
                    trailing: isMe ? CircleAvatar(
                      backgroundImage: NetworkImage(avatarUrl),
                    ) : null,


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

                        switch(type){
                          case "image":{
                            var fileSize = message["message"]['messageInfo']['fileSize'].toString();
                            var fileName = message["message"]['messageInfo']['fileName'];
                            var imageUrl = "${Env.HOST}/download/hash/${message["message"]['messageInfo']['fileHash']}";

                            title = CachedNetworkImage(
                              imageUrl: imageUrl,
                              placeholder: (context, url) => const CircularProgressIndicator(),
                              errorWidget: (context, url, error) => const Icon(Icons.error),
                            );

                            maxWidth = constraints.maxWidth * 0.8;
                            break;
                          }
                          case "file":{

                            var fileSize = message["message"]['messageInfo']['fileSize'].toString();
                            var fileName = message["message"]['messageInfo']['fileName'];
                            var fileUrl = "${Env.HOST}/download/hash/${message["message"]['messageInfo']['fileHash']}";

                            fileSize = parseFileSize(double.parse(fileSize));


                            title = GestureDetector(
                                onTap:() => downloadFile(fileUrl, fileName),
                                child:Row(
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
                                            const SizedBox(height: 4),
                                            Text(
                                              fileSize,
                                              style: Theme.of(context).textTheme.bodySmall,
                                            ),
                                          ],
                                        ))
                                  ],
                                )
                            );
                            maxWidth = constraints.maxWidth * 0.8;

                            break;
                          }
                          case "video":{
                              var fileSize = message["message"]['messageInfo']['fileSize']
                                  .toString();
                              var fileName = message["message"]['messageInfo']['fileName'];
                              var fileUrl = "${Env
                                  .HOST}/download/hash/${message["message"]['messageInfo']['fileHash']}";

                              fileSize = parseFileSize(double.parse(fileSize));
                              //todo 视频消息

                              if(_videoControllers[index] == null){
                                //如果没有创建过，就创建一个，注意，这里可能没有创建成功，因为视频文件可能很大，需要时间下载
                                _videoControllers[index] = VideoPlayerController.network(fileUrl);
                                _videoControllersIsInit[index] = false;
                              }

                              _playVideo(fileUrl,fileName,index);


                              //视频播放器，宽度是屏幕的0.8，高度是宽度的0.8

                              title = GestureDetector(
                                onTap:(){
                                  setState(() {
                                    if(!_videoControllersIsInit[index]!){
                                      return;
                                    }
                                    if(_videoControllers[index]!.value.isPlaying
                                    ){
                                      // 暂停可以随意
                                      _videoControllers[index]!.pause();
                                    }else{
                                      //播放需要暂停其他视频
                                      _videoControllers.forEach((key, value) {
                                        if(key != index){
                                          value.pause();
                                        }
                                      });
                                      _videoControllers[index]!.play();
                                    }
                                  });
                                },
                                //一个视频，上面带播放按钮
                                child: Stack(
                                  children: <Widget>[
                                    AspectRatio(
                                      aspectRatio: _videoControllers[index]!.value.aspectRatio,
                                      child: VideoPlayer(_videoControllers[index]!),
                                    ),
                                    Positioned(
                                      //防在容器正中间
                                      left: 0,
                                      right: 0,
                                      top: 0,
                                      bottom: 0,

                                      child:
                                      _videoControllers[index]!.value.isPlaying?
                                      Container():
                                      const Icon(Icons.play_arrow,
                                        color: Colors.white,
                                        size: 50,
                                      ),
                                    )
                                  ],
                                ),
                              );


                              maxWidth = constraints.maxWidth * 0.8;

                              break;
                          }
                          default:{
                            title = Text(
                              text,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              textAlign: isMe ? TextAlign.right : TextAlign.left,
                            );
                          }
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
          //进度条列表
          SizedBox(
            height: _uploadProcess.length * 50.0,
            child: ListView.builder(
              scrollDirection: Axis.vertical,
              itemCount: _uploadProcess.length,
              itemBuilder: (context, index) {
                return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    //高雅黑
                    color: Color(0xFF32373A),
                  ),
                  height: 50,
                  child: ListTile(
                    title: Row(
                      children: [
                        Expanded(
                          child: Text(
                            _uploadProcess[index].fileName,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 10,
                                color: Colors.blue,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        SizedBox(
                          //宽度是屏幕宽度的0.5
                          width: MediaQuery.of(context).size.width * 0.6,
                          child: LinearProgressIndicator(
                            value:_uploadProcess[index].progress,
                            backgroundColor: Colors.grey[200],
                            valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
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
                icon: const Icon(Icons.image),
                color: Colors.blue,
                onPressed: chooseImage,
              ),
              //发送文件按钮
              IconButton(
                icon: const Icon(Icons.attach_file),
                color: Colors.blue,
                onPressed: chooseFile,
              ),
              IconButton(
                icon: const Icon(Icons.send),
                color: Colors.blue,
                onPressed: sendMessage,
              ),
            ],
          ),
        ],
      ),
    );
  }

  ///选择图片
  void chooseImage() async {
    //image_picker只支持android和ios，web，
    //所以这边要判断一下
    if (kIsWeb || Platform.isIOS || Platform.isAndroid) {
      final ImagePicker _picker = ImagePicker();

      //选择图片
      XFile? onceimages = await _picker.pickImage(source: ImageSource.gallery);

      List<File> images = [];
      images.add(File(onceimages!.path));

      for (File image in images) {
        await uploadFile(image, image.lengthSync().toString());
      }
    }else{
      const XTypeGroup jpgsTypeGroup = XTypeGroup(
        label: 'JPEGs',
        extensions: <String>['jpg', 'jpeg'],
      );
      const XTypeGroup pngTypeGroup = XTypeGroup(
        label: 'PNGs',
        extensions: <String>['png'],
      );
      final List<XFile> files = await openFiles(acceptedTypeGroups: <XTypeGroup>[
        jpgsTypeGroup,
        pngTypeGroup,
      ]);
      if (files.isEmpty) {
        return;
      }

      for (XFile file in files) {
        await uploadFile(File(file.path), (await file.length()).toString() );
      }

    }


  }

  ///选择文件
  void chooseFile() async {
    const XTypeGroup fileTypeGroup = XTypeGroup(
      label: 'Files',
    );
    final List<XFile> files = await openFiles(acceptedTypeGroups: <XTypeGroup>[
      fileTypeGroup,
    ]);
    if (files.isEmpty) {
      return;
    }

    for (XFile file in files) {
      await uploadFile(File(file.path), (await file.length()).toString() );
    }

  }

  ///拖拽发送文件
  void _dragDone(DropDoneDetails detail) {
    List<XFile> files = detail.files;

    for (var xfile in files) {
      File file = File(xfile.path);

      if (kDebugMode) {
        print("文件路径：${file.path}");
      }

      //判断是不是文件夹
      if (FileSystemEntity.isDirectorySync(file.path)) {
        //层次遍历并发送文件
        Directory dir = Directory(file.path);
        List<FileSystemEntity> list = dir.listSync(recursive: true);
        for (var f in list) {
          if (FileSystemEntity.isFileSync(f.path)) {
            uploadFile(File(f.path), f.statSync().size.toString());
          }
        }
        return;
      } else {
        uploadFile(file, file.lengthSync().toString());
      }

    }
  }


  ///尝试播放视频
  void _playVideo(String url,String fileName,int index) async {



    //如果已经初始化过了，直接返回
    if(_videoControllersIsInit[index]!){
      return;
    }
    _videoControllersIsInit[index] = true;

    //下载文件
    String filePath = await downloadFile(url, fileName,open: false);

    //初始化视频控制器
    VideoPlayerController controller = VideoPlayerController.file(File(filePath));

    print("初始化视频控制器：${controller.hashCode})");
    setState(() {
      _videoControllers[index] = controller;
      _videoControllers[index]!.initialize().then((_) {
        setState(() {
          _videoControllers[index]!.play();
          //延迟100毫秒，防止视频还没播放就暂停了
          Future.delayed(const Duration(milliseconds: 100), () {
            setState(() {
              _videoControllers[index]!.pause();
            });
          });
        });
      });
    });
  }

  ///上传文件
  ///返回文件的url
  Future<dynamic> uploadFile(File file, String fileSize) async {

    //如果文件不存在，直接返回
    if (!file.existsSync()) {
      throw Exception('文件不存在');
    }

    UploadProcess uploadProcess = UploadProcess("上传：${file.path.split('/').last}", 0,false);

    setState(() {
      _uploadProcess.add(uploadProcess);
    });


    //计算文件hash
    String fileHash = (await calculateFileHash(file)).toString();

    //通过hash值判断文件是否已经上传过
    var response = await HttpTool.get(
        '${Env.HOST}/hash/$fileHash',
        params: {}
    );
    if (response.data != null && response.data != "") {



      setState(() {

        uploadProcess.progress = 1;

        //延迟100毫秒，让进度条显示完成
        Future.delayed(const Duration(milliseconds: 100), () {
          uploadProcess.isComplete = true;
        });

        _uploadProcess.remove(uploadProcess);
      });

      //如果文件已经上传过，直接返回文件的url

      //发送文件信息和文件名称
      sendFileData(response.data,name:file.path.split('/').last);

      return response.data;
    }


    if (kDebugMode) {
      print('文件hash：$fileHash');
    }


    // 计算文件的总块数和每个块的大小
    final fileSize = await file.length();
    int chunkSize = 5 * 1024 * 1024; // 每个块大小为 5MB
    final totalChunks = (fileSize / chunkSize).ceil();

    // 创建 Dio 实例，并设置请求头
    final dio = Dio();
    dio.options.headers['content-type'] = 'multipart/form-data';
    dio.options.headers['cookie'] = HttpTool.headers['cookie'];

    // 遍历每一块并上传
    for (var i = 0; i < totalChunks; i++) {
      // 计算当前块的起始位置和大小
      final startByte = i * chunkSize;
      var endByte = (i + 1) * chunkSize;
      if (endByte > fileSize) {
        endByte = fileSize;
      }
      chunkSize = endByte - startByte;

      // 创建 FormData 对象，并添加需要携带的参数
      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(
          file.readAsBytesSync().sublist(startByte, endByte),
          filename: 'chunk_$i', // 给当前块命名
        ),
        'filename': file.path.split('/').last, // 文件名称
        'chunkIndex': i.toString(), // 当前块的索引
        'totalChunks': totalChunks.toString(), // 总块数
        'chunkSize': chunkSize.toString(), // 当前块大小
        'fileSize': fileSize.toString(), // 文件总大小
        'hash': fileHash, // 文件 hash
      });


      // 发送请求,添加上传进度监听
      response = await dio.post('${Env.HOST}/upload', data: formData,onSendProgress: (int sent, int total) {
        if (kDebugMode) {
          print('上传进度：${sent / total}');
          setState(() {
            uploadProcess.progress = sent.toDouble() / total.toDouble() /totalChunks.toDouble();
          });
        }
      });


    }

    setState(() {
      uploadProcess.isComplete = true;
      _uploadProcess.remove(uploadProcess);
    });


    if (response.data != null && response.data != "") {

      sendFileData(response.data);

      return response.data;
    }

  }

  ///发送文件数据，通过socket发送
  void sendFileData(Map<String, dynamic> data, {String name = ''}) {

    var type = 'file';
    if(identityPicture(data['name'])){
      type = 'image';
    }else if(identityVideo(data['name'])){
      type = 'video';
    }

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
        'type': type,
        'messageInfo': {
          'fileHash': data['hash'],
          'fileSize': data['size'],
          'fileName': name == '' ? data['name'] : name,
        }
      },
      'timestamp': DateTime.now().millisecondsSinceEpoch
    });
  }

  ///计算大文件hash
  Future<String> calculateFileHash(File file) async {

    //开始时间
    var start = DateTime.now().millisecondsSinceEpoch;

    var inputStream = file.openRead();
    var output = AccumulatorSink<Digest>();
    var input = md5.startChunkedConversion(output);

    await for (var chunk in inputStream) {
      input.add(chunk);
    }

    input.close();
    var digest = output.events.single;

    //结束时间
    var end = DateTime.now().millisecondsSinceEpoch;

    if (kDebugMode) {
      print('计算文件hash耗时：${end - start}ms');
    }

    return hex.encode(digest.bytes);
  }

  ///判断是否是图片
  bool identityPicture(String fileName) {
    switch(fileName.substring(fileName.lastIndexOf('.') + 1).toLowerCase()) {
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
      case 'bmp':
      case 'webp':
        return true;
      default:
        return false;
    }
  }

  ///判断是否是视频
  bool identityVideo(String fileName) {
    switch(fileName.substring(fileName.lastIndexOf('.') + 1).toLowerCase()) {
      case 'mp4':
      case 'avi':
      case 'rmvb':
      case 'rm':
      case 'flv':
      case '3gp':
      case 'mkv':
      case 'mov':
        return true;
      default:
        return false;
    }
  }

  ///下载文件
  Future<String> downloadFile(String fileUrl, String fileName, {bool open = true}) async {



    //获取文件保存路径
    String savePath = await getSavePath(fileName);

    //创建文件
    File file = File(savePath);

    //如果文件已经存在，直接打开
    if (file.existsSync() && open) {
      _openFile(file);
      return savePath;
    }

    if (kDebugMode) {
      print('开始下载文件：$fileUrl');
    }
    UploadProcess uploadProcess = UploadProcess("下载：$fileName", 0,false);

    setState(() {
      _uploadProcess.add(uploadProcess);
    });

    //创建文件夹
    Directory dir = Directory(savePath.substring(0, savePath.lastIndexOf('/')));
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }

    //创建文件
    file.createSync();




    //下载文件
    Dio dio = Dio();
    dio.options.headers['cookie'] = HttpTool.headers['cookie'];
    await dio.download(fileUrl, savePath, onReceiveProgress: (received, total) {
      if (total != -1) {
        print((received / total * 100).toStringAsFixed(0) + "%" + "  " + received.toString() + "  " + total.toString());
        setState(() {
          uploadProcess.progress = received.toDouble() / total.toDouble();
        });
      }
    }).then((response) {

      if (response.statusCode == 200 && open) {
          _openFile(file);
      }
    });

    setState(() {
      uploadProcess.isComplete = true;
      _uploadProcess.remove(uploadProcess);
    });


    return savePath;

  }

  ///获取文件保存路径
  getSavePath(String fileName) async {
    String savePath = '';

    //获取沙盒目录
    String dir = (await getApplicationDocumentsDirectory()).path;


    //判断是否是图片
    if(identityPicture(fileName)) {
      //创建Image目录，如果已经存在，则不创建
      Directory imageDir = Directory('$dir/Image');
      if (!imageDir.existsSync()) {
        imageDir.createSync();
      }
      //创建文件
      savePath = '$dir/Image/$fileName';
      return savePath;
    }

    //创建Download目录，如果已经存在，则不创建
    Directory downloadDir = Directory('$dir/Download');
    if (!downloadDir.existsSync()) {
      downloadDir.createSync();
    }

    //创建文件
    savePath = '$dir/Download/$fileName';

    return savePath;
  }

  ///打开图片
  void openImage(File file) async {
    //Todo 目前不需要任何操作
  }

  ///打开文件
  void _openFile(File file) async {

    Uri uri = Uri.file(file.path);
    if (kDebugMode) {
      print('打开文件：${file.path}');
    }
    final url = uri.toString();
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not open file';
    }
  }

  Future<VideoPlayerController> getVideoController(String fileUrl,String fileName) async {

    String videoPath = await downloadFile(fileUrl, fileName);
    return VideoPlayerController.file(File(videoPath));

  }

}
