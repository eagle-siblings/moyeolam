import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:moyeolam/common/confirm.dart';
import 'package:moyeolam/common/const/colors.dart';
import 'package:moyeolam/common/layout/title_bar.dart';
import 'package:moyeolam/common/secure_storage/secure_storage.dart';
import 'package:moyeolam/common/textfield_bar.dart';
import 'package:moyeolam/friends/component/friends_list.dart';
import 'package:moyeolam/friends/component/profile_card.dart';
import 'package:moyeolam/friends/model/friends_list_model.dart';
import 'package:moyeolam/friends/view/make_friend_view.dart';
import 'package:moyeolam/friends/view_model/friend_list_view_model.dart';
import 'package:moyeolam/friends/view_model/friend_search_view_model.dart';
import 'package:moyeolam/main.dart';

class FriendView extends ConsumerStatefulWidget{
  const FriendView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _FriendViewConsumerSate();

}

class _FriendViewConsumerSate extends ConsumerState<FriendView>{
  final UserInformation _userInformation = UserInformation(storage);
  TextEditingController _searchFriend = TextEditingController();
  final FriendListViewModel _friendListViewModel = FriendListViewModel();
  final FocusNode textFocus = FocusNode();



  @override
  void dispose() {
    // TODO: implement dispose
    _searchFriend.dispose();
    textFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    AsyncValue<List<FriendModel?>?> foundFriend = ref.watch(friendSearchProvider);
    var useKeyword = ref.watch(friendSearchNotifierProvider.notifier);
    return Scaffold(
      backgroundColor: BACKGROUND_COLOR,
      appBar: TitleBar(
        appBar: AppBar(),
        title: "모여람",
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const MakeFriendView(),
                ),
              );
            },
            icon: Icon(
              Icons.person_add,
              color: FONT_COLOR,
            ),
          )
        ],
      ),
      body: RefreshIndicator(
        onRefresh: ()async{
          ref.invalidate(friendSearchProvider);
        },
        child: GestureDetector(
          onTap: (){
            textFocus.unfocus();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                Container(
                  margin: EdgeInsets.all(8),
                  height: 80,
                  // color: Colors.yellow,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 32, right: 32),
                    child: TextFieldbox(
                      textFocus: textFocus,
                      defualtText: "친구 검색",
                      controller: _searchFriend,
                      setContents: (String value){
                        // useKeyword.setKeyword(value);
                      },
                      onSubmit: (String value){
                        useKeyword.setKeyword(value);
                        ref.invalidate(friendSearchProvider);
                        textFocus.unfocus();
                      },
                      suffixIcon: IconButton(
                        onPressed: (){
                          useKeyword.setKeyword(_searchFriend.text);
                          ref.invalidate(friendSearchProvider);
                          textFocus.unfocus();
                        },
                        icon: Icon(Icons.search_outlined),
                      ),
                      suffixIconColor: FONT_COLOR,
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 4, bottom: 4, right: 8, left: 8),
                  // color: Colors.deepOrange,
                  height: 160,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 12.0, bottom: 12, left: 20, right: 20),
                    child: ProfileCard(
                      future: _userInformation.getUserInfo(),
                    ),
                  ),
                ),
                Container(
                  height: 440,
                  // color: Colors.blue,
                  margin: EdgeInsets.all(8),
                  child: Padding(
                    padding: EdgeInsets.only(left: 20, right: 20),
                    child: foundFriend.when(
                        data: (data){
                          if(data != null) {
                            // print("data123: ${data[0]!.nickname}");
                            return data.isNotEmpty?
                            SearchList(data):
                            Center(
                              child: const Text("친구를 추가해보세요!",
                                style: TextStyle(
                                  fontWeight: FontWeight.w100,
                                  fontSize: 20,
                                  color: FONT_COLOR,
                                ),
                              ),
                            );
                          }else{
                            return const Text(
                              "아직 비어 있어요",
                              style: TextStyle(
                                fontSize: 20,
                              ),
                            );
                          }
                        },
                        error: (error, stackTrace){
                          return Text("Error: $error");
                        },
                        loading: (){
                          return const SpinKitFadingCube(
                            // FadingCube 모양 사용
                            color: Colors.blue, // 색상 설정
                            size: 50.0, // 크기 설정
                            duration: Duration(seconds: 2), //속도 설정
                          );
                        },
                    ),
                  ),

                )
              ],
            ),
          ),
        ),
      ),
    );
  }

Widget SearchList(List<FriendModel?> friends) {
  return ListView.builder(
    physics: AlwaysScrollableScrollPhysics(),
      itemCount: friends.length,
      itemBuilder: (context, index) {
        FriendModel? friend = friends[index];
        print("friend: ${friend!.nickname}");
        return ListTile(
          title: Text("${friend!.nickname}",
              style: TextStyle(
                fontSize: 20,
                color: FONT_COLOR,
                fontWeight: FontWeight.w200,
              )),
          leading: SizedBox(
            height: 100,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(100.0),
              child: friend.profileImageUrl != null ?Image.network("${friend.profileImageUrl}", fit: BoxFit.fill,):Icon(Icons.person,size:30,color: SUB_COLOR,),
            ),
          ),
          // leading: const CircleAvatar(
          //   // backgroundColor: colorList[index % 3],
          //   // backgroundColor: SUB_COLOR,
          //   // child: Icon(Icons.person,size: 30, ),
          // ),
            trailing: IconButton(
            onPressed: () async{
              showDialog(
                context: context,
                builder: (context) {
                  return ConfirmDialog(
                    title: "친구 삭제",
                    content: "${friend.nickname}님 을/를 친구 목록에서 삭제하시겠습니까?",
                    okTitle: "삭제",
                    okOnPressed: ()async{
                      await _friendListViewModel.deleteFriend(friend.memberId);
                      ref.invalidate(friendSearchProvider);
                      Navigator.of(context).pop();
                    },
                    cancelTitle: "취소",
                    cancelOnPressed: (){
                      Navigator.of(context).pop();
                    },
                  );
                },
              );
            },
            icon: const Icon(
              Icons.close,
              color: FONT_COLOR,
            ),

          ),
        );
      }
  );
}
}

