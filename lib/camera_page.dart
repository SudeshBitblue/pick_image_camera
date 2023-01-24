import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({Key? key}) : super(key: key);

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  File? _image;

  Future<void> _pickImage() async {
    // PickedFile image = await ImagePicker().pickImage(source: ImageSource.camera);

    final ImagePicker _picker = ImagePicker();
    final PickedFile? pickedFile = await _picker.getImage(source: ImageSource.camera);
    setState(() {
      _image =  File(pickedFile!.path);
    });
  }

  Future<void> _saveImage() async {
    final _image = this._image;
    if (_image != null) {
      final appDir = await getExternalStorageDirectory();
      final fileName = DateTime.now().millisecondsSinceEpoch.toString();
      final savedImage = await _image.copy('${appDir?.path}/$fileName.jpg');
      print('Image saved to ${savedImage.path}');
    }
  }


  @override
  void initState() {

    if(!(checkCameraPermission() && checkStoragePermission())) {
      requestCameraPermission();
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Take and Save Photo'),
        ),
        body: Center(
          child: _image == null
              ? Text('No image selected.')
              : Image.file(_image!),
        ),
        floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            FloatingActionButton(
              onPressed: _pickImage,
              child: Icon(Icons.camera_alt),
            ),
            SizedBox(
              height: 10,
            ),
            FloatingActionButton(
              onPressed: _saveImage,
              child: Icon(Icons.save),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> requestCameraPermission() async {

    final permissions = [Permission.storage, Permission.camera];
    final results = await Future.wait(permissions.map((permission) => permission.request()));
    final grantedPermissions = results.where((result) => result.isGranted);
    // if(grantedPermissions.length == permissions.length){
    //   // all permissions are granted
    // }else{
    //   // some permissions are denied
    // }

    // final status = await Permission.camera.request();
    return grantedPermissions.length == permissions.length;
  }
  bool checkCameraPermission() {
    return Permission.camera.status == PermissionStatus.granted;
  }
  bool checkStoragePermission() {
    return Permission.storage.status == PermissionStatus.granted;
  }
}