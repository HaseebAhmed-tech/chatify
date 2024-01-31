import 'package:chatify/models/conversation.dart';
import 'package:chatify/providers/auth_provider.dart';
import 'package:chatify/services/database_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../resources/app_theme/theme_provider.dart';
import '../../../resources/constants/styles.dart';
import '../../conversation/conversation_ui.dart';

class RecentsView extends StatelessWidget {
  const RecentsView({super.key, required this.cons});
  final BoxConstraints cons;
  @override
  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ThemeProvider provider, child) {
      return Container(
        // color: Colors.blue,
        padding: EdgeInsets.symmetric(horizontal: cons.maxWidth * 0.01),
        child: Column(
          children: [
            ChangeNotifierProvider.value(
              value: AuthProvider.instance,
              builder: (context, child) {
                return _conversationListWidegt();
              },
            ),
          ],
        ),
      );
    });
  }

  Widget _conversationListWidegt() {
    return Builder(builder: (context) {
      AuthProvider authProvider = Provider.of<AuthProvider>(context);
      return Expanded(
        child: StreamBuilder<List<ConversationSnippet>>(
            stream: DatabaseService.instance
                .getUserConversations(authProvider.user!.uid),
            builder: (context, snapshot) {
              var data = snapshot.data;
              return snapshot.hasData
                  ? data!.isEmpty
                      ? Center(
                          child: Text(
                            'No Conversations yet',
                            style: Theme.of(context)
                                .textTheme
                                .displayMedium!
                                .copyWith(color: Styles.secondryTextColor),
                          ),
                        )
                      : ListView.builder(
                          itemCount: data.length,
                          shrinkWrap: true,
                          physics: const BouncingScrollPhysics(),
                          itemBuilder: (context, index) {
                            return ListTile(
                              // dense: true,
                              onTap: () {
                                Get.to(ConversationView(
                                  converstaionID: data[index].conversationID!,
                                  receiverID: data[index].id!,
                                  receiverImage: data[index].image!,
                                  recieverName: data[index].name!,
                                  cons: cons,
                                ));
                              },
                              leading: CircleAvatar(
                                radius: 25,
                                backgroundImage: NetworkImage(data[index]
                                        .image ??
                                    'https://www.pngitem.com/pimgs/m/146-1468479_my-profile-icon-blank-profile-picture-circle-hd.png'),
                                backgroundColor: Colors.grey,
                              ),
                              title: Text(data[index].name ?? 'Unknown',
                                  style: Theme.of(context)
                                      .textTheme
                                      .displayMedium),
                              subtitle: Text(
                                data[index].type == 'text'
                                    ? data[index].lastMessage ??
                                        'Start a conversation'
                                    : 'Image',
                                style: Theme.of(context)
                                    .textTheme
                                    .displaySmall!
                                    .copyWith(color: Styles.secondryTextColor),
                              ),
                              trailing: _listTileTrailingWidgets(
                                  context, data[index].timestamp!),
                            );
                          },
                        )
                  : Center(
                      child: SpinKitWanderingCubes(
                        color: Styles.primaryColor,
                        size: 50,
                      ),
                    );
            }),
      );
    });
  }

  Widget _listTileTrailingWidgets(BuildContext context, Timestamp lastDate) {
    debugPrint(lastDate.toDate().toString());
    final dateDiff = lastDate.toDate().difference(DateTime.now()).inHours.abs();
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.end,
      // mainAxisSize: MainAxisSize.max,
      children: [
        Text(
          timeago.format(lastDate.toDate()),
          style: TextStyle(color: Styles.secondryTextColor),
        ),
        Container(
          height: 10,
          width: 10,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: dateDiff < 1 ? Colors.blue : Colors.redAccent,
          ),
        ),
      ],
    );
  }
}
