import 'dart:io';

import 'package:cropperx/cropperx.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_demo/env/Env.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_selector/file_selector.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:flutter/foundation.dart' show Uint8List, kDebugMode, kIsWeb;
import 'package:path_provider/path_provider.dart';





class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _accountController = TextEditingController();
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  int _gender = 0;

  File? _image;

  Future<void> _selectAvatar() async {
    if (kIsWeb) {
      const typeGroup =
      XTypeGroup(label: 'images', extensions: ['jpg', 'png', 'jpeg']);
      final file = await openFile(acceptedTypeGroups: [typeGroup]);
      if (file != null) {
        await _cropImage(File(file.path!));
      }
    } else {
      if (Platform.isAndroid || Platform.isIOS) {
        final pickedFile =
        await ImagePicker().getImage(source: ImageSource.gallery);
        if (pickedFile != null) {
          await _cropImage(File(pickedFile.path));
        }
      } else if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
        const typeGroup =
        XTypeGroup(label: 'images', extensions: ['jpg', 'png']);
        final file = await openFile(acceptedTypeGroups: [typeGroup]);
        if (file != null) {
          await _cropImage(File(file.path!));
        }
      }
    }
  }



  late Cropper cropper;

  bool isCropping = false;

  final _cropperKey = GlobalKey(debugLabel: 'cropperKey');


  Future<void> _cropImage(File imageFile) async {

    if(imageFile.path.isEmpty) return;

    if(Platform.isMacOS || Platform.isLinux || Platform.isWindows) {
      // Define a key

      cropper = Cropper(
            cropperKey: _cropperKey, // Use your key here
            image: Image.file(imageFile),
            overlayType: OverlayType.circle,
            rotationTurns: 0,
            onScaleStart: (details) {
              print("onScaleStart: $details");
            },
            onScaleUpdate: (details) {
              print("onScaleUpdate: $details");
            },
            onScaleEnd: (details) {
              print("onScaleEnd: $details");
            },
          );


      setState(() {
        isCropping = true;
      });


      return;
    }




    File? croppedFile = await ImageCropper().cropImage(
      sourcePath: imageFile.path,
      cropStyle: CropStyle.circle,
      aspectRatioPresets: [
        CropAspectRatioPreset.square
      ],
      androidUiSettings: AndroidUiSettings(
        toolbarTitle: '裁剪头像',
        toolbarColor: Colors.blue,
        toolbarWidgetColor: Colors.white,
        statusBarColor: Colors.blue.shade900,
        activeControlsWidgetColor: Colors.blue.shade900,
        lockAspectRatio: true,
      ),
      iosUiSettings: const IOSUiSettings(
        title: '裁剪头像',
      ),
    );
    if (croppedFile != null) {
      setState(() {
        _image = croppedFile;
      });
    }
  }

  @override
  void dispose() {
    _accountController.dispose();
    _nicknameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  //将Uint8List保存到本地文件并转换为Image对象
  Future<File> saveAndDecodeImage(Uint8List data) async {
    //获取本地文件路径
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String appDocPath = appDocDir.path;
    String filePath = '$appDocPath/test.png';
    //将Uint8List写入本地文件
    File file = File(filePath);
    await file.writeAsBytes(data);
    return file;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('注册')),
      body: isCropping ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            cropper,
            const SizedBox(height: 16),
            const Text('正在裁剪头像...'),
            //按钮
            ElevatedButton(
              onPressed: () async {
                Uint8List? imageBytes = await Cropper.crop(
                  cropperKey: _cropperKey, // Reference it through the key
                );

                File file = await saveAndDecodeImage(imageBytes!);

                setState(() {
                  isCropping = false;
                  _image = file;
                });

              },
              child: const Text('完成'),
            ),
          ],
        ),
      ): Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: GestureDetector(
                  onTap: _selectAvatar,
                  child: _image == null
                      ? const CircleAvatar(
                    radius: 40,
                    child: Icon(Icons.person),
                  )
                      : CircleAvatar(
                    radius: 40,
                    backgroundImage: FileImage(_image!),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text('帐号'),
              TextField(
                controller: _accountController,
                decoration: const InputDecoration(hintText: '请输入帐号'),
              ),
              const SizedBox(height: 16),
              const Text('昵称'),
              TextField(
                controller: _nicknameController,
                decoration: const InputDecoration(hintText: '请输入昵称'),
              ),
              const SizedBox(height: 16),
              const Text('密码'),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(hintText: '请输入密码'),
              ),
              const SizedBox(height: 16),
              const Text('性别'),
              DropdownButtonFormField<int>(
                value: _gender,
                onChanged: (value) {
                  setState(() {
                    _gender = value ?? 0;
                  });
                },
                //value是下标，Text的是值
                items: ['男','女','保密'].asMap().entries.map((e) => DropdownMenuItem(
                  value: e.key,
                  child: Text(e.value),
                )).toList(),

                decoration: const InputDecoration(
                  hintText: '请选择性别',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: ElevatedButton(
                  onPressed: register,
                  child: const Text('注册'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 注册，将图片上传到服务器，并同时将用户信息保存到数据库
  void register() async{

    String account = _accountController.text;
    String nickname = _nicknameController.text;
    String password = _passwordController.text;
    String gender = _gender.toString();

    if(_image == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('请选择头像')));
      return;
    }

    File avatar = _image!;

    if(account.isEmpty || nickname.isEmpty || password.isEmpty || avatar.path.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('请填写完整信息')));
      return;
    }

    //同时上传图片和用户信息，使用Dio的FormData
    //构建请求体
    FormData formData = FormData.fromMap({
      'account': account,
      'name': nickname,
      'sex': gender,
      'password': password,
      'file': await MultipartFile.fromFile(avatar.path, filename: 'avatar.png'),
    });

    //发起请求
    try {
      Response response =
        await Dio().post("${Env.HOST}/register", data: formData);
      if (response.statusCode == 200) {
        //上传成功
        //弹窗提示
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('注册成功')));
        //隔一秒后返回登录页面
        Future.delayed(const Duration(seconds: 1), () {
          Navigator.of(context).pop();
        });
      } else {
        //上传失败
        //弹窗提示
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('注册失败')));
      }
    } catch (e) {
      print(e);
      //网络请求异常
      //弹窗提示
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('网络异常')));
    }
  }
}
