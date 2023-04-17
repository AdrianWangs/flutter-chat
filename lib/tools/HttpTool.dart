import 'package:dio/dio.dart';

class HttpTool{

  static Dio dio = Dio();
  static Map<String, dynamic> headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  static Future get(String url, {required Map<String, dynamic> params}) async {
    try {
      Response response = await dio.get(url, queryParameters: params, options: Options(headers: headers));
      return response;
    } catch (e) {
      print(e);
    }
  }

  static Future post(String url, {required Map<String, dynamic> params}) async {
    try {
      Response response = await dio.post(url, data: params, options: Options(headers: headers));
      return response;
    } catch (e) {
      print(e);
    }
  }
}