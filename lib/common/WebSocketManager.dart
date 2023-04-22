import 'package:web_socket_channel/io.dart';

class WebSocketManager {
  static IOWebSocketChannel? webSocketChannel;

  static final List<Function(dynamic)> _listeners = [];


  static void connect(String url) {

    webSocketChannel = IOWebSocketChannel.connect(url);
    //每收到一条消息,就将消息广播给所有监听者
    webSocketChannel!.stream.listen((message) {

      //去除重复的监听者
      _listeners.toSet().toList();

      for (var listener in _listeners) {

        //如果执行出现异常,则移除该监听者
        try {
          listener(message);
        } catch (e) {
          print("~~~~~~~~~~~~移除监听者（可能是因为该对象已经销毁）~~~~~~~~~~~~~");
          _listeners.remove(listener);
        }

      }
    });
  }


  // Send message through the websocket
  static void sendMessage(dynamic message) {
    if (webSocketChannel != null) {
      webSocketChannel!.sink.add(message);
    }
  }

  // Listen to incoming messages from the websocket and broadcast them to all listeners.
  static void addListener(Function(dynamic) listener) {
     _listeners.add(listener);
  }

  static void close() {
    if (webSocketChannel != null) {
      webSocketChannel!.sink.close();
      webSocketChannel = null;
    }
  }
}