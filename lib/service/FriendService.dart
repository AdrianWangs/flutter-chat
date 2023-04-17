import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_demo/env/Env.dart';

import '../entity/FriendRequest.dart';
import '../tools/HttpTool.dart';

class FriendService {
  static const String _baseUrl = Env.HOST; // 将 your.backend.url 替换为实际的后端地址

  //
  // static Future<void> addFriend(User user, int friendId) async {
  //   final String url = '$_baseUrl/addFriend/$friendId';
  //
  //   try {
  //     await HttpTool.post(url, params: {'userId': user.id});
  //   } catch (e) {
  //     print(e);
  //     rethrow;
  //   }
  // }
  //
  // static Future<void> refuseFriend(User user, int friendId) async {
  //   final String url = '$_baseUrl/refuseFriend/$friendId';
  //
  //   try {
  //     await HttpTool.post(url, params: {'userId': user.id});
  //   } catch (e) {
  //     print(e);
  //     rethrow;
  //   }
  // }

  static Future<List<FriendRequest>> getFriendRequest() async {
    final String url = '$_baseUrl/friendRequest';
    Map<String, dynamic> params = {};

    try {
      Response response = await HttpTool.get(url, params: params);
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.data);
        List<FriendRequest> friendRequestList = [];
        for (var item in data) {
          FriendRequest friendRequest = FriendRequest.fromJson(item);
          friendRequestList.add(friendRequest);
        }
        return friendRequestList;
      } else {
        throw Exception('Failed to fetch friend request');
      }
    } catch (e) {
      print(e);
      rethrow;
    }
  }
}
