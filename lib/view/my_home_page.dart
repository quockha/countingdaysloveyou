import 'package:countingdaysloveyou/global.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'dart:io';
class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String urlImages = "";
  Firestore firestore;
  CollectionReference get messages => firestore.collection('messages');
  File sampleImage;

  Function(DocumentSnapshot e) get i => null;
  @override
  void initState() {
    super.initState();
    final birthday = DateTime(2019, 07, 15);
    final date2 = DateTime.now();
    print("DEVK data: "+ date2.toString());
    final difference = date2.difference(birthday).inDays;
    print("DEVK time: "+ difference.toString());
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance.collection(keynamedata).snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) return new Text('Error: ${snapshot.error}');
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return new Text('Loading...');
            default:
              return new ListView.builder(
                itemCount: snapshot.data.documents.length,
                itemBuilder: (context, index) {
                  DocumentSnapshot document = snapshot.data.documents[index];
                  return GestureDetector(
                    onTap: () =>
                        _setOnClickListViewItem(context ,index, document.documentID, document[urlchild]),
                    child: ListTile(
                      title: new Text(document[namechild]),
                      subtitle: new Text(document[urlchild].toString()),
                    ),
                  );
                },
              );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _setOnclickAddData(),
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }

  _setOnClickListViewItem(BuildContext context, int index, String id, String url) {
    print("DEVK index: " + index.toString() + "    -    " + id);
    Navigator.pushNamed(context, '/home', arguments: url);
  }
  _setOnclickAddData() async {
    upLoadImages();
  }
  Future<void> deleteImage(String imageUrl, String token) async {
    String filePath = '${pathUrlImages}${imageUrl}?alt=media&token=${token}'
        .replaceAll(new RegExp(pathUrlImages), '')
        .split('?')[0];
    FirebaseStorage.instance
        .ref()
        .child(filePath)
        .delete()
        .then((_) => print('Successfully deleted $filePath storage item'));
  }

  Future upLoadImages() async {
    var tempImage = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      sampleImage = tempImage;
    });
    var strone = sampleImage.toString().substring(47);
    var mtext = strone.substring(0, strone.length - 5); //
    StorageReference storageReference =
    FirebaseStorage.instance.ref().child(mtext);
    StorageUploadTask uploadTask = storageReference.putFile(sampleImage);
    uploadTask.onComplete.then((s) async {
      String url = (await s.ref.getDownloadURL()).toString();
      select("Duong Quoc Khanh", url);
    });
  }

  Future<void> showImages(String images) async {
    final StorageReference firebaseStorageRef =
    FirebaseStorage.instance.ref().child(images);
    String url = (await firebaseStorageRef.getDownloadURL()).toString();
    print("DEVK URL: " + url);
  }

  Future<void> select(String name, String url) async {
    DocumentReference ref = await Firestore.instance
        .collection(keynamedata)
        .add({namechild: name, urlchild: url});
    print(ref.documentID);
  }

  Future<void> update(String id, String name, int tuoi) async {
    return Firestore.instance
        .collection(keynamedata)
        .document(id)
        .updateData({namechild: name, urlchild: tuoi});
  }

  Future<void> delete(String id) async {
    return Firestore.instance.collection(keynamedata).document(id).delete();
  }
}
