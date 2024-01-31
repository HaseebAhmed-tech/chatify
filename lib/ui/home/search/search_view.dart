import 'package:chatify/models/contact.dart';
import 'package:chatify/providers/auth_provider.dart';
import 'package:chatify/resources/app_theme/theme_provider.dart';
import 'package:chatify/resources/constants/styles.dart';
import 'package:chatify/ui/conversation/conversation_ui.dart';
import 'package:chatify/widgets/textformfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../services/database_service.dart';

class SearchView extends StatefulWidget {
  const SearchView({
    super.key,
    required this.cons,
  });
  final BoxConstraints? cons;

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  ValueNotifier<String?>? search;

  _SearchViewState() {
    search = ValueNotifier<String?>('');
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ThemeProvider themeProvider, child) {
      return Container(
        padding: EdgeInsets.symmetric(
            vertical: widget.cons!.maxWidth * 0.02,
            horizontal: widget.cons!.maxWidth * 0.02),
        child: ChangeNotifierProvider<AuthProvider>.value(
            value: AuthProvider.instance,
            builder: (context, child) =>
                _searchPageUI(themeProvider, widget.cons)),
      );
    });
  }

  Widget _searchPageUI(ThemeProvider themeProvider, BoxConstraints? cons) {
    return Builder(builder: (context) {
      final AuthProvider authProvider = Provider.of<AuthProvider>(context);
      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          _userSearchField(themeProvider),
          authProvider.user != null
              ? _userList(authProvider.user!.uid, authProvider, cons)
              : Center(
                  child: SpinKitWanderingCubes(
                    color: Styles.primaryColor,
                    size: 50,
                  ),
                ),
        ],
      );
    });
  }

  Widget _userSearchField(ThemeProvider themeProvider) {
    return MyTextFormField(
      labelText: 'Search',
      showOutlineBorder: false,
      prefixIcon: Icon(
        Icons.search,
        color: Styles.primaryColor,
      ),
      onFieldSubmitted: (input) {
        search!.value = input;
      },
    );
  }

  Widget _userList(String uid, AuthProvider auth, BoxConstraints? cons) {
    return Expanded(
      child: ValueListenableBuilder<String?>(
        valueListenable: search!,
        builder: (context, value, child) {
          return StreamBuilder<List<Contact>>(
              stream: DatabaseService.instance.getUsersInDB(uid, search!.value),
              builder: (context, snapshot) {
                final data = snapshot.data;

                return snapshot.hasData
                    ? ListView.builder(
                        shrinkWrap: true,
                        physics: const BouncingScrollPhysics(),
                        itemCount: data!.length,
                        itemBuilder: (context, index) {
                          final isUserOnline = data[index]
                              .lastseen!
                              .toDate()
                              .isBefore(DateTime.now()
                                  .subtract(const Duration(hours: 1)));

                          return Padding(
                            padding: const EdgeInsets.only(top: 10.0),
                            child: ListTile(
                              onTap: () {
                                DatabaseService.instance
                                    .createOrGetConversation(
                                        auth.user!.uid,
                                        data[index].id!,
                                        data[index].image!,
                                        data[index].name!,
                                        (conversationID) async {
                                  await Get.to(ConversationView(
                                      converstaionID: conversationID,
                                      receiverID: data[index].id!,
                                      receiverImage: data[index].image!,
                                      recieverName: data[index].name!,
                                      cons: cons!));
                                });
                              },
                              visualDensity:
                                  VisualDensity.adaptivePlatformDensity,
                              // dense: true,
                              leading: CircleAvatar(
                                  radius: 25,
                                  backgroundImage: NetworkImage(
                                    data[index].image != null
                                        ? data[index].image!
                                        : 'https://www.pngitem.com/pimgs/m/146-1468479_my-profile-icon-blank-profile-picture-circle-hd.png',
                                  )),
                              title: Text(
                                data[index].name ?? 'Unknown',
                                style:
                                    Theme.of(context).textTheme.displayMedium,
                              ),

                              trailing: _listTileTrailingWidgets(
                                context,
                                isUserOnline,
                                timeago.format(data[index].lastseen!.toDate()),
                              ),
                            ),
                          );
                        },
                      )
                    : Center(
                        child: SpinKitWanderingCubes(
                          color: Styles.primaryColor,
                          size: 50,
                        ),
                      );
              });
        },
      ),
    );
  }

  Widget _listTileTrailingWidgets(
    BuildContext context,
    bool isUserOnline,
    String time,
  ) {
    // debugPrint(lastDate.toDate().toString());
    // final dateDiff = lastDate.toDate().difference(DateTime.now()).inHours.abs();
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.end,
      // mainAxisSize: MainAxisSize.max,
      children: [
        Text(
          !isUserOnline ? 'Active' : 'Last Seen',
          // timeago.format(lastDate.toDate()),
          style: Theme.of(context).textTheme.displaySmall,
        ),
        !isUserOnline
            ? Container(
                height: 10,
                width: 10,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.blue,
                ),
              )
            : Text(
                time,
                style: TextStyle(color: Styles.primaryTextColor),
              ),
      ],
    );
  }
}
