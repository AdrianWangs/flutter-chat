
class FriendRequest {

  int id;
  int userId;
  int friendId;
  String addTime;


  FriendRequest({
    required this.id,
    required this.userId,
    required this.friendId,
    required this.addTime
  });

  static FriendRequest fromJson(Map<String, dynamic> json) {
    return FriendRequest(
      id: json['id'],
      userId: json['userId'],
      friendId: json['friendId'],
      addTime: json['addTime']
    );
  }





}