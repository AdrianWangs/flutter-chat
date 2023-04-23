import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/io.dart';

class WebSocketManager {
  static IOWebSocketChannel? webSocketChannel;

  static  String _url = "";

  static final List<Function(dynamic)> _listeners = [];
  static final List<Completer<dynamic>> _completers = [];

  //TODO 心跳监听
  static int lastReceiveTime = DateTime.now().millisecondsSinceEpoch;

  static late Timer _heartbeatTimer;

  static int outTime = 5;

  static bool isConnect = false;


  static void connect([String url = '']) {

    if(url.isNotEmpty){
      _url = url;
    }

    print("~~~~~~~~~~~~~连接~~~~~~~~~~~~~~~");

    webSocketChannel = IOWebSocketChannel.connect(
        _url,
        pingInterval: Duration(seconds: outTime),
        protocols: ['chat']
    );

    //每收到一条消息,就将消息广播给所有监听者
    webSocketChannel!.stream.listen((message) {

      //不管是不是心跳消息,都重置最后一次收到消息的时间
      resetLastReceiveTime();
      //去除重复的监听者
      _listeners.toSet().toList();

      List<int> index = [];

      for (var listener in _listeners) {

        //如果执行出现异常,则移除该监听者
        try {
          listener(message);
        } catch (e) {
          print(e);
          print("~~~~~~~~~~~~移除监听者（可能是因为该对象已经销毁）~~~~~~~~~~~~~");
          index.add(_listeners.indexOf(listener));
        }
      }

      //移除监听者
      for(var i in index){
        _listeners.removeAt(i);
      }

    },onDone: () {
      print("~~~~~~~~~~~~~连接关闭~~~~~~~~~~~~~~~");
      isConnect = false;
    });

    //如果连接失败,则重连
    webSocketChannel!.stream.handleError((error) {
      print("~~~~~~~~~~~~~连接失败~~~~~~~~~~~~~~~");
      isConnect = false;
    });

    //如果连接成功,则开启心跳
    startHeartbeat();

    // 处理队列中等待的消息
    for (var completer in _completers) {
      completer.complete();
    }
    _completers.clear();

  }



  static void startHeartbeat() {
    _heartbeatTimer = Timer.periodic(Duration(seconds: outTime), (timer) {

      print("~~~~~~~~~~~~~心跳发送~~~~~~~~~~~~~~~");

      final currentTime = DateTime.now().millisecondsSinceEpoch;
      if (currentTime - lastReceiveTime > outTime * 1000) {
        isConnect = false;
        reconnect();
      } else {
        sendMessage(jsonEncode({"heartBeat": "1"}));
      }
    });
  }

  static void stopHeartbeat() {
    //防止late变量未初始化
    _heartbeatTimer=Timer(const Duration(seconds: 1000000), () {});
    _heartbeatTimer.cancel();
  }


  static void reconnect() async {
    
    print("~~~~~~~~~~~~~重连~~~~~~~~~~~~~~~");
    if (webSocketChannel != null) {
      print("当前 WebSocket 连接的状态是 ${webSocketChannel!.innerWebSocket?.readyState}");
    }
    if(isConnect){
      return;
    }
    close();
    connect();
  }

  static void resetLastReceiveTime() {
    lastReceiveTime = DateTime.now().millisecondsSinceEpoch;
  }


  // Send message through the websocket
  static Future<void> sendMessage(dynamic message) async {

    print("~~~~~~~~~~~~~发送消息~~~~~~~~~~~~~~~");

    if (webSocketChannel?.innerWebSocket?.closeCode != null) {

      // 如果没有连接,则将消息加入队列中,等待连接成功后再发送
      print("~~~~~~~~~~~~~消息加入队列~~~~~~~~~~~~~~~");

      isConnect = false;

      Completer completer = Completer();
      _completers.add(completer);
      await completer.future;
    }

    webSocketChannel!.sink.add(message);
    resetLastReceiveTime();
  }

  // Listen to incoming messages from the websocket and broadcast them to all listeners.
  static void addListener(Function(dynamic) listener) {
    _listeners.add(listener);
  }

  static void close() {
    stopHeartbeat();
    if (webSocketChannel != null) {
      webSocketChannel!.sink.close();
      webSocketChannel = null;
    }
  }
}
