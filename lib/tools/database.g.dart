// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $ChatDataTable extends ChatData
    with TableInfo<$ChatDataTable, ChatDataData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChatDataTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nicknameMeta =
      const VerificationMeta('nickname');
  @override
  late final GeneratedColumn<String> nickname = GeneratedColumn<String>(
      'nickname', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _avatarUrlMeta =
      const VerificationMeta('avatarUrl');
  @override
  late final GeneratedColumn<String> avatarUrl = GeneratedColumn<String>(
      'avatar_url', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _messageMeta =
      const VerificationMeta('message');
  @override
  late final GeneratedColumn<String> message = GeneratedColumn<String>(
      'message', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _messageTimeMeta =
      const VerificationMeta('messageTime');
  @override
  late final GeneratedColumn<int> messageTime = GeneratedColumn<int>(
      'message_time', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _senderAccountMeta =
      const VerificationMeta('senderAccount');
  @override
  late final GeneratedColumn<String> senderAccount = GeneratedColumn<String>(
      'sender_account', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _receiverAccountMeta =
      const VerificationMeta('receiverAccount');
  @override
  late final GeneratedColumn<String> receiverAccount = GeneratedColumn<String>(
      'receiver_account', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        nickname,
        avatarUrl,
        message,
        messageTime,
        senderAccount,
        receiverAccount
      ];
  @override
  String get aliasedName => _alias ?? 'chat_data';
  @override
  String get actualTableName => 'chat_data';
  @override
  VerificationContext validateIntegrity(Insertable<ChatDataData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('nickname')) {
      context.handle(_nicknameMeta,
          nickname.isAcceptableOrUnknown(data['nickname']!, _nicknameMeta));
    } else if (isInserting) {
      context.missing(_nicknameMeta);
    }
    if (data.containsKey('avatar_url')) {
      context.handle(_avatarUrlMeta,
          avatarUrl.isAcceptableOrUnknown(data['avatar_url']!, _avatarUrlMeta));
    } else if (isInserting) {
      context.missing(_avatarUrlMeta);
    }
    if (data.containsKey('message')) {
      context.handle(_messageMeta,
          message.isAcceptableOrUnknown(data['message']!, _messageMeta));
    } else if (isInserting) {
      context.missing(_messageMeta);
    }
    if (data.containsKey('message_time')) {
      context.handle(
          _messageTimeMeta,
          messageTime.isAcceptableOrUnknown(
              data['message_time']!, _messageTimeMeta));
    } else if (isInserting) {
      context.missing(_messageTimeMeta);
    }
    if (data.containsKey('sender_account')) {
      context.handle(
          _senderAccountMeta,
          senderAccount.isAcceptableOrUnknown(
              data['sender_account']!, _senderAccountMeta));
    } else if (isInserting) {
      context.missing(_senderAccountMeta);
    }
    if (data.containsKey('receiver_account')) {
      context.handle(
          _receiverAccountMeta,
          receiverAccount.isAcceptableOrUnknown(
              data['receiver_account']!, _receiverAccountMeta));
    } else if (isInserting) {
      context.missing(_receiverAccountMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ChatDataData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ChatDataData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      nickname: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}nickname'])!,
      avatarUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}avatar_url'])!,
      message: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}message'])!,
      messageTime: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}message_time'])!,
      senderAccount: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sender_account'])!,
      receiverAccount: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}receiver_account'])!,
    );
  }

  @override
  $ChatDataTable createAlias(String alias) {
    return $ChatDataTable(attachedDatabase, alias);
  }
}

class ChatDataData extends DataClass implements Insertable<ChatDataData> {
  final int id;
  final String nickname;
  final String avatarUrl;
  final String message;
  final int messageTime;
  final String senderAccount;
  final String receiverAccount;
  const ChatDataData(
      {required this.id,
      required this.nickname,
      required this.avatarUrl,
      required this.message,
      required this.messageTime,
      required this.senderAccount,
      required this.receiverAccount});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['nickname'] = Variable<String>(nickname);
    map['avatar_url'] = Variable<String>(avatarUrl);
    map['message'] = Variable<String>(message);
    map['message_time'] = Variable<int>(messageTime);
    map['sender_account'] = Variable<String>(senderAccount);
    map['receiver_account'] = Variable<String>(receiverAccount);
    return map;
  }

  ChatDataCompanion toCompanion(bool nullToAbsent) {
    return ChatDataCompanion(
      id: Value(id),
      nickname: Value(nickname),
      avatarUrl: Value(avatarUrl),
      message: Value(message),
      messageTime: Value(messageTime),
      senderAccount: Value(senderAccount),
      receiverAccount: Value(receiverAccount),
    );
  }

  factory ChatDataData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ChatDataData(
      id: serializer.fromJson<int>(json['id']),
      nickname: serializer.fromJson<String>(json['nickname']),
      avatarUrl: serializer.fromJson<String>(json['avatarUrl']),
      message: serializer.fromJson<String>(json['message']),
      messageTime: serializer.fromJson<int>(json['messageTime']),
      senderAccount: serializer.fromJson<String>(json['senderAccount']),
      receiverAccount: serializer.fromJson<String>(json['receiverAccount']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'nickname': serializer.toJson<String>(nickname),
      'avatarUrl': serializer.toJson<String>(avatarUrl),
      'message': serializer.toJson<String>(message),
      'messageTime': serializer.toJson<int>(messageTime),
      'senderAccount': serializer.toJson<String>(senderAccount),
      'receiverAccount': serializer.toJson<String>(receiverAccount),
    };
  }

  ChatDataData copyWith(
          {int? id,
          String? nickname,
          String? avatarUrl,
          String? message,
          int? messageTime,
          String? senderAccount,
          String? receiverAccount}) =>
      ChatDataData(
        id: id ?? this.id,
        nickname: nickname ?? this.nickname,
        avatarUrl: avatarUrl ?? this.avatarUrl,
        message: message ?? this.message,
        messageTime: messageTime ?? this.messageTime,
        senderAccount: senderAccount ?? this.senderAccount,
        receiverAccount: receiverAccount ?? this.receiverAccount,
      );
  @override
  String toString() {
    return (StringBuffer('ChatDataData(')
          ..write('id: $id, ')
          ..write('nickname: $nickname, ')
          ..write('avatarUrl: $avatarUrl, ')
          ..write('message: $message, ')
          ..write('messageTime: $messageTime, ')
          ..write('senderAccount: $senderAccount, ')
          ..write('receiverAccount: $receiverAccount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, nickname, avatarUrl, message, messageTime,
      senderAccount, receiverAccount);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChatDataData &&
          other.id == this.id &&
          other.nickname == this.nickname &&
          other.avatarUrl == this.avatarUrl &&
          other.message == this.message &&
          other.messageTime == this.messageTime &&
          other.senderAccount == this.senderAccount &&
          other.receiverAccount == this.receiverAccount);
}

class ChatDataCompanion extends UpdateCompanion<ChatDataData> {
  final Value<int> id;
  final Value<String> nickname;
  final Value<String> avatarUrl;
  final Value<String> message;
  final Value<int> messageTime;
  final Value<String> senderAccount;
  final Value<String> receiverAccount;
  const ChatDataCompanion({
    this.id = const Value.absent(),
    this.nickname = const Value.absent(),
    this.avatarUrl = const Value.absent(),
    this.message = const Value.absent(),
    this.messageTime = const Value.absent(),
    this.senderAccount = const Value.absent(),
    this.receiverAccount = const Value.absent(),
  });
  ChatDataCompanion.insert({
    this.id = const Value.absent(),
    required String nickname,
    required String avatarUrl,
    required String message,
    required int messageTime,
    required String senderAccount,
    required String receiverAccount,
  })  : nickname = Value(nickname),
        avatarUrl = Value(avatarUrl),
        message = Value(message),
        messageTime = Value(messageTime),
        senderAccount = Value(senderAccount),
        receiverAccount = Value(receiverAccount);
  static Insertable<ChatDataData> custom({
    Expression<int>? id,
    Expression<String>? nickname,
    Expression<String>? avatarUrl,
    Expression<String>? message,
    Expression<int>? messageTime,
    Expression<String>? senderAccount,
    Expression<String>? receiverAccount,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nickname != null) 'nickname': nickname,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
      if (message != null) 'message': message,
      if (messageTime != null) 'message_time': messageTime,
      if (senderAccount != null) 'sender_account': senderAccount,
      if (receiverAccount != null) 'receiver_account': receiverAccount,
    });
  }

  ChatDataCompanion copyWith(
      {Value<int>? id,
      Value<String>? nickname,
      Value<String>? avatarUrl,
      Value<String>? message,
      Value<int>? messageTime,
      Value<String>? senderAccount,
      Value<String>? receiverAccount}) {
    return ChatDataCompanion(
      id: id ?? this.id,
      nickname: nickname ?? this.nickname,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      message: message ?? this.message,
      messageTime: messageTime ?? this.messageTime,
      senderAccount: senderAccount ?? this.senderAccount,
      receiverAccount: receiverAccount ?? this.receiverAccount,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (nickname.present) {
      map['nickname'] = Variable<String>(nickname.value);
    }
    if (avatarUrl.present) {
      map['avatar_url'] = Variable<String>(avatarUrl.value);
    }
    if (message.present) {
      map['message'] = Variable<String>(message.value);
    }
    if (messageTime.present) {
      map['message_time'] = Variable<int>(messageTime.value);
    }
    if (senderAccount.present) {
      map['sender_account'] = Variable<String>(senderAccount.value);
    }
    if (receiverAccount.present) {
      map['receiver_account'] = Variable<String>(receiverAccount.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChatDataCompanion(')
          ..write('id: $id, ')
          ..write('nickname: $nickname, ')
          ..write('avatarUrl: $avatarUrl, ')
          ..write('message: $message, ')
          ..write('messageTime: $messageTime, ')
          ..write('senderAccount: $senderAccount, ')
          ..write('receiverAccount: $receiverAccount')
          ..write(')'))
        .toString();
  }
}

class $RecentChatTable extends RecentChat
    with TableInfo<$RecentChatTable, RecentChatData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecentChatTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nicknameMeta =
      const VerificationMeta('nickname');
  @override
  late final GeneratedColumn<String> nickname = GeneratedColumn<String>(
      'nickname', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _avatarUrlMeta =
      const VerificationMeta('avatarUrl');
  @override
  late final GeneratedColumn<String> avatarUrl = GeneratedColumn<String>(
      'avatar_url', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _lastMessageMeta =
      const VerificationMeta('lastMessage');
  @override
  late final GeneratedColumn<String> lastMessage = GeneratedColumn<String>(
      'last_message', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _lastMessageTimeMeta =
      const VerificationMeta('lastMessageTime');
  @override
  late final GeneratedColumn<int> lastMessageTime = GeneratedColumn<int>(
      'last_message_time', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _senderAccountMeta =
      const VerificationMeta('senderAccount');
  @override
  late final GeneratedColumn<String> senderAccount = GeneratedColumn<String>(
      'sender_account', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _receiverAccountMeta =
      const VerificationMeta('receiverAccount');
  @override
  late final GeneratedColumn<String> receiverAccount = GeneratedColumn<String>(
      'receiver_account', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _accountMeta =
      const VerificationMeta('account');
  @override
  late final GeneratedColumn<String> account = GeneratedColumn<String>(
      'account', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        nickname,
        avatarUrl,
        lastMessage,
        lastMessageTime,
        senderAccount,
        receiverAccount,
        account
      ];
  @override
  String get aliasedName => _alias ?? 'recent_chat';
  @override
  String get actualTableName => 'recent_chat';
  @override
  VerificationContext validateIntegrity(Insertable<RecentChatData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('nickname')) {
      context.handle(_nicknameMeta,
          nickname.isAcceptableOrUnknown(data['nickname']!, _nicknameMeta));
    } else if (isInserting) {
      context.missing(_nicknameMeta);
    }
    if (data.containsKey('avatar_url')) {
      context.handle(_avatarUrlMeta,
          avatarUrl.isAcceptableOrUnknown(data['avatar_url']!, _avatarUrlMeta));
    } else if (isInserting) {
      context.missing(_avatarUrlMeta);
    }
    if (data.containsKey('last_message')) {
      context.handle(
          _lastMessageMeta,
          lastMessage.isAcceptableOrUnknown(
              data['last_message']!, _lastMessageMeta));
    } else if (isInserting) {
      context.missing(_lastMessageMeta);
    }
    if (data.containsKey('last_message_time')) {
      context.handle(
          _lastMessageTimeMeta,
          lastMessageTime.isAcceptableOrUnknown(
              data['last_message_time']!, _lastMessageTimeMeta));
    } else if (isInserting) {
      context.missing(_lastMessageTimeMeta);
    }
    if (data.containsKey('sender_account')) {
      context.handle(
          _senderAccountMeta,
          senderAccount.isAcceptableOrUnknown(
              data['sender_account']!, _senderAccountMeta));
    } else if (isInserting) {
      context.missing(_senderAccountMeta);
    }
    if (data.containsKey('receiver_account')) {
      context.handle(
          _receiverAccountMeta,
          receiverAccount.isAcceptableOrUnknown(
              data['receiver_account']!, _receiverAccountMeta));
    } else if (isInserting) {
      context.missing(_receiverAccountMeta);
    }
    if (data.containsKey('account')) {
      context.handle(_accountMeta,
          account.isAcceptableOrUnknown(data['account']!, _accountMeta));
    } else if (isInserting) {
      context.missing(_accountMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RecentChatData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RecentChatData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      nickname: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}nickname'])!,
      avatarUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}avatar_url'])!,
      lastMessage: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}last_message'])!,
      lastMessageTime: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}last_message_time'])!,
      senderAccount: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sender_account'])!,
      receiverAccount: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}receiver_account'])!,
      account: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}account'])!,
    );
  }

  @override
  $RecentChatTable createAlias(String alias) {
    return $RecentChatTable(attachedDatabase, alias);
  }
}

class RecentChatData extends DataClass implements Insertable<RecentChatData> {
  final int id;
  final String nickname;
  final String avatarUrl;
  final String lastMessage;
  final int lastMessageTime;
  final String senderAccount;
  final String receiverAccount;
  final String account;
  const RecentChatData(
      {required this.id,
      required this.nickname,
      required this.avatarUrl,
      required this.lastMessage,
      required this.lastMessageTime,
      required this.senderAccount,
      required this.receiverAccount,
      required this.account});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['nickname'] = Variable<String>(nickname);
    map['avatar_url'] = Variable<String>(avatarUrl);
    map['last_message'] = Variable<String>(lastMessage);
    map['last_message_time'] = Variable<int>(lastMessageTime);
    map['sender_account'] = Variable<String>(senderAccount);
    map['receiver_account'] = Variable<String>(receiverAccount);
    map['account'] = Variable<String>(account);
    return map;
  }

  RecentChatCompanion toCompanion(bool nullToAbsent) {
    return RecentChatCompanion(
      id: Value(id),
      nickname: Value(nickname),
      avatarUrl: Value(avatarUrl),
      lastMessage: Value(lastMessage),
      lastMessageTime: Value(lastMessageTime),
      senderAccount: Value(senderAccount),
      receiverAccount: Value(receiverAccount),
      account: Value(account),
    );
  }

  factory RecentChatData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RecentChatData(
      id: serializer.fromJson<int>(json['id']),
      nickname: serializer.fromJson<String>(json['nickname']),
      avatarUrl: serializer.fromJson<String>(json['avatarUrl']),
      lastMessage: serializer.fromJson<String>(json['lastMessage']),
      lastMessageTime: serializer.fromJson<int>(json['lastMessageTime']),
      senderAccount: serializer.fromJson<String>(json['senderAccount']),
      receiverAccount: serializer.fromJson<String>(json['receiverAccount']),
      account: serializer.fromJson<String>(json['account']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'nickname': serializer.toJson<String>(nickname),
      'avatarUrl': serializer.toJson<String>(avatarUrl),
      'lastMessage': serializer.toJson<String>(lastMessage),
      'lastMessageTime': serializer.toJson<int>(lastMessageTime),
      'senderAccount': serializer.toJson<String>(senderAccount),
      'receiverAccount': serializer.toJson<String>(receiverAccount),
      'account': serializer.toJson<String>(account),
    };
  }

  RecentChatData copyWith(
          {int? id,
          String? nickname,
          String? avatarUrl,
          String? lastMessage,
          int? lastMessageTime,
          String? senderAccount,
          String? receiverAccount,
          String? account}) =>
      RecentChatData(
        id: id ?? this.id,
        nickname: nickname ?? this.nickname,
        avatarUrl: avatarUrl ?? this.avatarUrl,
        lastMessage: lastMessage ?? this.lastMessage,
        lastMessageTime: lastMessageTime ?? this.lastMessageTime,
        senderAccount: senderAccount ?? this.senderAccount,
        receiverAccount: receiverAccount ?? this.receiverAccount,
        account: account ?? this.account,
      );
  @override
  String toString() {
    return (StringBuffer('RecentChatData(')
          ..write('id: $id, ')
          ..write('nickname: $nickname, ')
          ..write('avatarUrl: $avatarUrl, ')
          ..write('lastMessage: $lastMessage, ')
          ..write('lastMessageTime: $lastMessageTime, ')
          ..write('senderAccount: $senderAccount, ')
          ..write('receiverAccount: $receiverAccount, ')
          ..write('account: $account')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, nickname, avatarUrl, lastMessage,
      lastMessageTime, senderAccount, receiverAccount, account);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RecentChatData &&
          other.id == this.id &&
          other.nickname == this.nickname &&
          other.avatarUrl == this.avatarUrl &&
          other.lastMessage == this.lastMessage &&
          other.lastMessageTime == this.lastMessageTime &&
          other.senderAccount == this.senderAccount &&
          other.receiverAccount == this.receiverAccount &&
          other.account == this.account);
}

class RecentChatCompanion extends UpdateCompanion<RecentChatData> {
  final Value<int> id;
  final Value<String> nickname;
  final Value<String> avatarUrl;
  final Value<String> lastMessage;
  final Value<int> lastMessageTime;
  final Value<String> senderAccount;
  final Value<String> receiverAccount;
  final Value<String> account;
  const RecentChatCompanion({
    this.id = const Value.absent(),
    this.nickname = const Value.absent(),
    this.avatarUrl = const Value.absent(),
    this.lastMessage = const Value.absent(),
    this.lastMessageTime = const Value.absent(),
    this.senderAccount = const Value.absent(),
    this.receiverAccount = const Value.absent(),
    this.account = const Value.absent(),
  });
  RecentChatCompanion.insert({
    this.id = const Value.absent(),
    required String nickname,
    required String avatarUrl,
    required String lastMessage,
    required int lastMessageTime,
    required String senderAccount,
    required String receiverAccount,
    required String account,
  })  : nickname = Value(nickname),
        avatarUrl = Value(avatarUrl),
        lastMessage = Value(lastMessage),
        lastMessageTime = Value(lastMessageTime),
        senderAccount = Value(senderAccount),
        receiverAccount = Value(receiverAccount),
        account = Value(account);
  static Insertable<RecentChatData> custom({
    Expression<int>? id,
    Expression<String>? nickname,
    Expression<String>? avatarUrl,
    Expression<String>? lastMessage,
    Expression<int>? lastMessageTime,
    Expression<String>? senderAccount,
    Expression<String>? receiverAccount,
    Expression<String>? account,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nickname != null) 'nickname': nickname,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
      if (lastMessage != null) 'last_message': lastMessage,
      if (lastMessageTime != null) 'last_message_time': lastMessageTime,
      if (senderAccount != null) 'sender_account': senderAccount,
      if (receiverAccount != null) 'receiver_account': receiverAccount,
      if (account != null) 'account': account,
    });
  }

  RecentChatCompanion copyWith(
      {Value<int>? id,
      Value<String>? nickname,
      Value<String>? avatarUrl,
      Value<String>? lastMessage,
      Value<int>? lastMessageTime,
      Value<String>? senderAccount,
      Value<String>? receiverAccount,
      Value<String>? account}) {
    return RecentChatCompanion(
      id: id ?? this.id,
      nickname: nickname ?? this.nickname,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      senderAccount: senderAccount ?? this.senderAccount,
      receiverAccount: receiverAccount ?? this.receiverAccount,
      account: account ?? this.account,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (nickname.present) {
      map['nickname'] = Variable<String>(nickname.value);
    }
    if (avatarUrl.present) {
      map['avatar_url'] = Variable<String>(avatarUrl.value);
    }
    if (lastMessage.present) {
      map['last_message'] = Variable<String>(lastMessage.value);
    }
    if (lastMessageTime.present) {
      map['last_message_time'] = Variable<int>(lastMessageTime.value);
    }
    if (senderAccount.present) {
      map['sender_account'] = Variable<String>(senderAccount.value);
    }
    if (receiverAccount.present) {
      map['receiver_account'] = Variable<String>(receiverAccount.value);
    }
    if (account.present) {
      map['account'] = Variable<String>(account.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecentChatCompanion(')
          ..write('id: $id, ')
          ..write('nickname: $nickname, ')
          ..write('avatarUrl: $avatarUrl, ')
          ..write('lastMessage: $lastMessage, ')
          ..write('lastMessageTime: $lastMessageTime, ')
          ..write('senderAccount: $senderAccount, ')
          ..write('receiverAccount: $receiverAccount, ')
          ..write('account: $account')
          ..write(')'))
        .toString();
  }
}

abstract class _$ChatDatabase extends GeneratedDatabase {
  _$ChatDatabase(QueryExecutor e) : super(e);
  late final $ChatDataTable chatData = $ChatDataTable(this);
  late final $RecentChatTable recentChat = $RecentChatTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [chatData, recentChat];
}
