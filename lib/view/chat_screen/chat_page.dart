import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebaseauth/services/database_services.dart';
import 'package:firebaseauth/view/chat_screen/group_info.dart';
import 'package:firebaseauth/view/chat_screen/message_tile.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sizer/sizer.dart';

class ChatPage extends StatefulWidget {
  ChatPage({
    Key? key,
    required this.groupName,
    required this.groupId,
    required this.userName,
  }) : super(key: key);
  final String groupId;
  final String groupName;
  final String userName;

  @override
  State<ChatPage> createState() => _ChattPageState();
}

class _ChattPageState extends State<ChatPage> {
  bool isLoading = false;
  String imageUrl = "";
  File? imageFile;
  bool isShowSticker = false;
  final FocusNode focusNode = FocusNode();

  String? peerId;
  String? peerAvatar;
  String? id;
  void onFocusChange() {
    if (focusNode.hasFocus) {
      // Hide sticker when keyboard appear
      setState(() {
        isShowSticker = false;
      });
    }
  }

  Future uploadFile() async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    Reference reference = FirebaseStorage.instance.ref().child(fileName);
    UploadTask uploadTask = reference.putFile(imageFile!);

    try {
      TaskSnapshot snapshot = await uploadTask;
      imageUrl = await snapshot.ref.getDownloadURL();
      setState(() {
        isLoading = false;
        onSendMessage(imageUrl, 1);
      });
    } on FirebaseException catch (e) {
      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(msg: e.message ?? e.toString());
    }
  }

  void onSendMessage(String content, int type) async {
    // type: 0 = text, 1 = image, 2 = sticker
    if (content.trim() != '') {
      // CallController().notification(
      //     firebaseToken:
      //         "duhjpSgoSj-r0zeOx1odcY:APA91bHL2H2ym7L8neto3Oyr7bGMOFf5uJrOiIuQsOoHJSosF_bmAI594RVbzZ1S3CttSYzaKixOhToqLnjUXDk6LYUu7jqLOeZAr4qeXS8CJSoYgyAEk3zgulzlIJ7OQKJe7ltu7Obe");
      _textEditingController.clear();

      var documentReference = FirebaseFirestore.instance
          .collection(FirebaseString.messages)
          .doc(widget.groupId)
          .collection(widget.groupId)
          .doc(DateTime.now().millisecondsSinceEpoch.toString());

      FirebaseFirestore.instance.runTransaction((transaction) async {
        transaction.set(
          documentReference,
          {
            'idFrom': id,
            'idTo': peerId,
            'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
            'content': content,
            'type': type
          },
        );
      });
      // await PushNotificationRepository.pushNotification(
      //     context: context,
      //     messages: content,
      //     userID: widget.userId,
      //     peerId: widget.peerId);
      listScrollController.animateTo(0.0,
          duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    }
  }

  Future getImage() async {
    ImagePicker imagePicker = ImagePicker();
    PickedFile? pickedFile;

    pickedFile = await imagePicker.getImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      imageFile = File(pickedFile.path);
      if (imageFile != null) {
        setState(() {
          isLoading = true;
        });
        uploadFile();
      }
    }
  }

  final int _limitIncrement = 20;
  int _limit = 20;
  Stream<QuerySnapshot>? chats;
  String adminName = "";
  bool shouldPop = true;
  _scrollListener() {
    if (listScrollController.offset >=
            listScrollController.position.maxScrollExtent &&
        !listScrollController.position.outOfRange) {
      setState(() {
        _limit += _limitIncrement;
      });
    }
  }

  final ScrollController listScrollController = ScrollController();
  @override
  void initState() {
    getChatAdminName();
    focusNode.addListener(onFocusChange);
    listScrollController.addListener(_scrollListener);
    super.initState();
  }

  getChatAdminName() {
    DataBaseServices().getChats(widget.groupId).then((value) {
      setState(() {
        chats = value;
      });
    });
    DataBaseServices().getGroupAdmin(widget.groupId).then((value) {
      setState(() {
        adminName = value;
      });
    });
  }

  TextEditingController _textEditingController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GroupInfo(
                        groupName: widget.groupName,
                        groupId: widget.groupId,
                        adminName: adminName,
                      ),
                    ));
              },
              icon: const Icon(
                Icons.info,
              ))
        ],
        elevation: 0,
        centerTitle: true,
        backgroundColor: primaryColor,
        title: Text(
          widget.groupName,
          style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
        ),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: WillPopScope(
          onWillPop: () async {
            return shouldPop;
          },
          child: Column(
            children: [
              Expanded(
                child: chatMessages(),
              ),
              SizedBox(height: 1.h),
              Container(
                padding: EdgeInsets.fromLTRB(3.w, 0, 3.w, 1.h),
                alignment: Alignment.bottomCenter,
                width: MediaQuery.of(context).size.width,
                color: Colors.transparent,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                        child: TextFormField(
                      controller: _textEditingController,
                      decoration: InputDecoration(
                          prefixIcon: InkWell(
                            onTap: () {
                              getImage();
                            },
                            child: const Icon(Icons.attach_file),
                          ),
                          hintText: "Write the message...",
                          hintStyle:
                              TextStyle(color: Colors.black, fontSize: 14.sp),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(100),
                              borderSide:
                                  BorderSide(color: Colors.red, width: 1.w))),
                    )),
                    SizedBox(
                      width: 1.w,
                    ),
                    GestureDetector(
                      onTap: () {
                        listScrollController.animateTo(0.0,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOut);
                        sendMessage();
                      },
                      child: CircleAvatar(
                        radius: 7.w,
                        backgroundColor: primaryColor,
                        child: const Center(
                            child: Icon(
                          Icons.send,
                          color: Colors.white,
                        )),
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  chatMessages() {
    return StreamBuilder(
      stream: chats,
      builder: (context, AsyncSnapshot snapshot) {
        return snapshot.hasData
            ? ListView.builder(
                controller: listScrollController,
                shrinkWrap: true,
                itemCount: snapshot.data.docs.length + 1,
                itemBuilder: (context, index) {
                  if (index == snapshot.data.docs.length) {
                    SizedBox(
                      height: 2.h,
                    );
                  } else {
                    return MessageTile(
                      // time: snapshot.data.docs[index]['time'].toString(),
                      message: snapshot.data.docs[index]['message'],
                      sender: snapshot.data.docs[index]['sender'],
                      sentByMe: widget.userName ==
                          snapshot.data.docs[index]['sender'],
                    );
                  }
                },
              )
            : Container();
      },
    );
  }

  sendMessage() {
    // final String time = DateTime.now().toString().substring(10, 16);

    if (_textEditingController.text.isNotEmpty) {
      Map<String, dynamic> chatMessageMap = {
        "message": _textEditingController.text,
        "sender": widget.userName,
        "time": DateTime.now().toString()
      };
      DataBaseServices().sendMessage(widget.groupId, chatMessageMap);
      setState(() {
        _textEditingController.clear();
      });
    }
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    listScrollController.dispose();
    focusNode.dispose();
    super.dispose();
  }
}
