import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/io.dart';

class Global{
  static SharedPreferences? prefs;
  static IOWebSocketChannel? channel;
}