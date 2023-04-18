class FriendRequest {
  late int id;
  late int userId;
  late int friendId;
  late String addTime;

  late String name;

  late String account;

  late int sex;

  late String avatarUrl;

  FriendRequest(
      this.id,
       this.userId,
       this.friendId,
       this.addTime,
       this.name,
       this.account,
       this.sex,
       this.avatarUrl);

  FriendRequest.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['userId'];
    friendId = json['friendId'];
    addTime = json['addTime'];
    name = json['name'];
    account = json['account'];
    sex = json['sex'];
    avatarUrl = json['avatarUrl'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['userId'] = userId;
    data['friendId'] = friendId;
    data['addTime'] = addTime;
    data['name'] = name;
    data['account'] = account;
    data['sex'] = sex;
    data['avatarUrl'] = avatarUrl;
    return data;
  }
}