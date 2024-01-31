import 'package:chatify/models/conversation.dart';
import 'package:chatify/providers/auth_provider.dart';
import 'package:chatify/services/cloud_storage_service.dart';
import 'package:chatify/services/database_service.dart';
import 'package:chatify/services/media_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../models/message.dart';
import '../../resources/constants/styles.dart';

class ConversationView extends StatefulWidget {
  final String converstaionID;
  final String receiverID;
  final String receiverImage;
  final String recieverName;
  final BoxConstraints cons;

  const ConversationView({
    super.key,
    required this.converstaionID,
    required this.receiverID,
    required this.receiverImage,
    required this.recieverName,
    required this.cons,
  });

  @override
  State<ConversationView> createState() => _ConversationViewState();
}

class _ConversationViewState extends State<ConversationView> {
  late final GlobalKey<FormState> _formKey;
  late final ValueNotifier<int> length;
  late String message;
  late ScrollController _scrollController;

  @override
  void initState() {
    _formKey = GlobalKey<FormState>();
    length = ValueNotifier<int>(1);
    message = '';
    _scrollController = ScrollController();
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(31, 31, 31, 1),
        title: Text(widget.recieverName),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: widget.cons.maxWidth * 0.02),
        child: ChangeNotifierProvider.value(
          value: AuthProvider.instance,
          child: _conversationPageUI(),
        ),
      ),
    );
  }

  _conversationPageUI() {
    return Builder(builder: (context) {
      final AuthProvider authProvider = Provider.of<AuthProvider>(context);

      return Stack(
        children: [
          _messageListView(authProvider.user!.uid),
          Align(
            alignment: Alignment.bottomCenter,
            child: ValueListenableBuilder(
              valueListenable: length,
              builder: (context, value, child) {
                return _messageField(context, widget.cons, authProvider);
              },
            ),
          ),
        ],
      );
    });
  }

  Widget _messageListView(String uid) {
    return SizedBox(
      height: widget.cons.maxHeight * 0.75,
      child: StreamBuilder<Conversation>(
          stream:
              DatabaseService.instance.getConversation(widget.converstaionID),
          builder: (context, snapshot) {
            final convData = snapshot.data;
            debugPrint('Conversation Data(UI): $convData');

            if (snapshot.hasData) {
              debugPrint('Conversation Data(UI): ${convData!.messages}');
              return convData.messages!.isNotEmpty
                  ? ListView.builder(
                      controller: _scrollController,
                      physics: const BouncingScrollPhysics(),
                      itemCount: convData.messages!.length,
                      itemBuilder: (context, index) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          _scrollController.animateTo(
                            _scrollController.position.maxScrollExtent,
                            duration: const Duration(milliseconds: 100),
                            curve: Curves.easeInOut,
                          );
                        });
                        final message = convData.messages![index];
                        return Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: message.senderID == uid
                                ? MainAxisAlignment.end
                                : MainAxisAlignment.start,
                            children: [
                              message.senderID == uid
                                  ? const SizedBox()
                                  : Padding(
                                      padding:
                                          const EdgeInsets.only(right: 8.0),
                                      child: CircleAvatar(
                                        radius: 20,
                                        backgroundImage:
                                            NetworkImage(widget.receiverImage),
                                      ),
                                    ),
                              message.type == MessageType.text
                                  ? _textMessageBubble(message.senderID == uid,
                                      message.content!, message.timestamp!)
                                  : _imageMessageBubble(message.senderID == uid,
                                      message.content!, message.timestamp!),
                            ],
                          ),
                        );
                      },
                    )
                  : Center(
                      child: Text(
                        'Start a conversation',
                        style:
                            Theme.of(context).textTheme.displayMedium!.copyWith(
                                  color: Styles.secondryTextColor,
                                ),
                      ),
                    );
            } else {
              return Center(
                  child: SpinKitDancingSquare(
                color: Styles.primaryColor,
              ));
            }
          }),
    );
  }

  Widget _textMessageBubble(bool isOwnMessage, String message, Timestamp time) {
    return Container(
      width: widget.cons.maxWidth * 0.75,
      height: widget.cons.maxHeight * 0.10,
      padding: EdgeInsets.symmetric(horizontal: widget.cons.maxWidth * 0.02),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
            colors: Styles.gradient(isOwnMessage),
            stops: const [0.30, 0.70],
            begin: Alignment.bottomLeft,
            end: Alignment.topRight),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          Text(message),
          Text(
            timeago.format(time.toDate()),
            style: TextStyle(color: Styles.secondryTextColor),
          ),
        ],
      ),
    );
  }

  Widget _imageMessageBubble(
      bool isOwnMessage, String imageURL, Timestamp time) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
            colors: Styles.gradient(isOwnMessage),
            stops: const [0.30, 0.70],
            begin: Alignment.bottomLeft,
            end: Alignment.topRight),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          FutureBuilder(
            future: precacheImage(NetworkImage(imageURL), context),
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return Container(
                  height: widget.cons.maxHeight * 0.30,
                  width: widget.cons.maxWidth * 0.40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: SpinKitDancingSquare(
                    color: Styles.scaffoldBackgroundColor,
                  ),
                );
              }
              return Container(
                height: widget.cons.maxHeight * 0.30,
                width: widget.cons.maxWidth * 0.40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  image: DecorationImage(
                    image: NetworkImage(imageURL),
                    fit: BoxFit.cover,
                  ),
                ),
              );
            },
          ),
          Text(
            timeago.format(time.toDate()),
            style: TextStyle(color: Styles.secondryTextColor),
          ),
        ],
      ),
    );
  }

  Widget _messageField(
      BuildContext context, BoxConstraints cons, AuthProvider auth) {
    return Container(
      height: length.value > 22
          ? length.value > 42
              ? cons.maxHeight * 0.15
              : cons.maxHeight * 0.1
          : cons.maxHeight * 0.08,
      decoration: BoxDecoration(
        color: const Color.fromRGBO(43, 43, 43, 1),
        borderRadius: BorderRadius.circular(100),
      ),
      margin: EdgeInsets.symmetric(
          horizontal: cons.maxWidth * 0.02, vertical: cons.maxHeight * 0.02),
      child: Form(
          key: _formKey,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              _messageTextField(cons),
              _sendMessageButton(cons, auth),
              _sendImageButton(cons, auth)
            ],
          )),
    );
  }

  _messageTextField(BoxConstraints cons) {
    return Container(
      width: cons.maxWidth * 0.55,
      alignment: Alignment.center,
      child: TextFormField(
        style: TextStyle(color: Styles.primaryTextColor),
        onChanged: (value) {
          // Chnaging the number of lines in the text field Based on Size of the Input Text
          value.length > 22
              ? value.length > 42
                  ? length.value = 3
                  : length.value = 2
              : length.value = 1;
          //---------------------------\\
        },
        onSaved: (input) {
          if (input != null) {
            message = input;
          }
        },
        maxLines: length.value,
        decoration: InputDecoration(
          isCollapsed: true,
          border: InputBorder.none,
          hintText: 'Type a message',
          hintStyle: TextStyle(color: Styles.secondryTextColor),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20),
        ),
        cursorColor: Styles.primaryTextColor,
        autocorrect: false,
      ),
    );
  }

  Widget _sendMessageButton(BoxConstraints cons, AuthProvider auth) {
    return SizedBox(
        width: cons.maxHeight * 0.05,
        height: cons.maxHeight * 0.05,
        child: IconButton(
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              _formKey.currentState!.save();
              final timeNow = Timestamp.now();
              DatabaseService.instance.updateMessages(widget.converstaionID,
                  Message(auth.user!.uid, message, timeNow, MessageType.text));
              DatabaseService.instance.updateUserSideConversation(
                  [auth.user!.uid, widget.receiverID],
                  auth.user!.uid,
                  message,
                  timeNow,
                  'text');
              _formKey.currentState!.reset();
              FocusScope.of(context).unfocus();
            }
          },
          icon: Icon(
            Icons.send,
            color: Styles.primaryTextColor,
          ),
        ));
  }

  Widget _sendImageButton(BoxConstraints cons, auth) {
    return SizedBox(
        width: cons.maxHeight * 0.05,
        height: cons.maxHeight * 0.05,
        child: FloatingActionButton(
          backgroundColor: Styles.primaryColor,
          onPressed: () async {
            MediaService.instance.getImageFromLibrary().then((image) async {
              if (image != null) {
                final timeNow = Timestamp.now();
                final uploadTask = await CloudStorageService.instance
                    .uploadMediaMessage(auth.user!.uid, image);
                final imageURL =
                    await uploadTask!.snapshot.ref.getDownloadURL();
                DatabaseService.instance.updateMessages(
                    widget.converstaionID,
                    Message(
                        auth.user!.uid, imageURL, timeNow, MessageType.image));
                DatabaseService.instance.updateUserSideConversation(
                    [auth.user!.uid, widget.receiverID],
                    auth.user!.uid,
                    'Image',
                    timeNow,
                    'image');
              }
            });
          },
          child: Icon(
            Icons.camera_enhance,
            color: Styles.primaryTextColor,
          ),
        ));
  }
}
