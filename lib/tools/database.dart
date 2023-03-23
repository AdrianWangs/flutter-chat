import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

part 'database.g.dart';

const _encrypted = true;
const _password = '123456';


class RecentChat extends Table {
  IntColumn get id => integer()();
  TextColumn get nickname => text()();
  TextColumn get avatarUrl => text()();
  TextColumn get lastMessage => text()();
  TextColumn get lastMessageTime => text()();
  TextColumn get account => text()();
}



class ChatData extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get nickname => text()();
  TextColumn get avatarUrl => text()();
  TextColumn get lastMessage => text()();
  TextColumn get lastMessageTime => text()();
  TextColumn get account => text()();
}


@DriftDatabase(tables: [ChatData, RecentChat])
class ChatDatabase extends _$ChatDatabase {
  ChatDatabase() : super(_openDatabase());

  @override
  int get schemaVersion => 1;

  //数据库迁移方法
  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      // 此处为数据库创建时的操作
      onCreate: (Migrator m) {
        return m.createAll();
      },
      // 此处为数据库升级时的操作
      onUpgrade: (Migrator m, int from, int to) async {

      },
      // 此处为数据库被打开时的操作
      beforeOpen: (details) async {
        if (_encrypted) {

        }
      },
    );
  }
}


QueryExecutor _openDatabase(){
  return LazyDatabase(() async{
    final path = (Platform.isIOS || Platform.isMacOS)
        ? await getApplicationDocumentsDirectory()
        : await getApplicationSupportDirectory();

    final dbFolder = Directory(join(path.path, 'db'));

    if (!dbFolder.existsSync()) {
      dbFolder.createSync();
    }

    final file = File(join(dbFolder.path, 'chat.db'));

    return NativeDatabase(
      File(file.path),
      setup: (db) async {
        if (_encrypted) {
          db.execute('PRAGMA key = "$_password"');
        }
      },
    );
  });
}
