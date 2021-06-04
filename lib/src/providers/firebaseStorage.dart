import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class FirebaseStorageApi {
  final Reference _storageReference = FirebaseStorage.instance.ref();

  Future<String> uploadImage(File imageFile, String imageName) async {
    TaskSnapshot uploadTask = await _storageReference.child("$imageName.jpg").putFile(imageFile);
    String downloadUrl = await FirebaseStorage.instance.ref("$imageName.jpg").getDownloadURL();
    return downloadUrl;
  }
}