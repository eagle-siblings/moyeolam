import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:openvidu_client/openvidu_client.dart';
import 'package:youngjun/common/const/colors.dart';
import 'package:youngjun/common/button/btn_toggle.dart';
import 'package:youngjun/common/const/address_config.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../../common/confirm.dart';
import '../../common/layout/main_nav.dart';
import '../../fcm/view/arlet_list_view.dart';
import '../../user/viewmodel/auth_view_model.dart';
import '../service/setting_service.dart';


import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:youngjun/main.dart';

import '../../common/const/address_config.dart';


import 'package:youngjun/main/view/settings.dart';

import 'package:youngjun/main/view/settings.dart';


import 'package:dio/dio.dart';


void handleMessage(RemoteMessage? message, bool notificationStatus) {
  if (!notificationStatus) {
    return;
  }

  if (message != null && message.notification != null) {
    Navigator.of(navigatorKey.currentContext!).pushNamed(
      ArletListView.route,
      arguments: message,
    );
  }
}

Future<void> initLocalNotifications() async {
  const android = AndroidInitializationSettings('@mipmap/ic_launcher');
  const setting = InitializationSettings(android: android);

  final FlutterLocalNotificationsPlugin _localNotification = FlutterLocalNotificationsPlugin();

  await FlutterLocalNotificationsPlugin().initialize(
    setting,
    onDidReceiveNotificationResponse: (NotificationResponse response) async {
      final payload = response.payload ?? '';
      final parsedJson = jsonDecode(payload);
      if (parsedJson.containsKey('routeTo') && parsedJson['routeTo'] == '/arlet_list') {


      }
    },
  );

  final platform = _localNotification.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
  await platform?.createNotificationChannel(AndroidNotificationChannel(
    'my_notification_channel',
    'My Notification Channel',
    importance: Importance.high,
  ));
}


Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Title: ${message.notification?.title}');
  print('Body: ${message.notification?.body}');
  print(message.notification?.body);
  initPushNotifications();

}



Future<void> initPushNotifications() async {
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  // `_SettingsContentState` 클래스의 인스턴스 생성
  _SettingsContentState settingsContentState = _SettingsContentState();

  // `_notificationStatus` 값을 가져와서 사용
  bool notificationStatus = settingsContentState._notificationStatus;

  FirebaseMessaging.instance.getInitialMessage().then((message) {
    handleMessage(message, notificationStatus); // 앱이 백그라운드에서 열렸을 때 처리하는 함수 호출
  });

  FirebaseMessaging.onMessageOpenedApp.listen((message) {
    handleMessage(message, notificationStatus); // 앱이 백그라운드 상태에서 푸시 알림을 눌렀을 때 처리하는 함수 호출

  });

  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  initLocalNotifications();



}



class FirebaseApi with ChangeNotifier {
  final _firebaseMessaging = FirebaseMessaging.instance;
  // String? fcmToken;

  RemoteMessage? latestMessage; // 수신한 마지막 메시지 저장

  Future<void> initNotifications() async {
    await _firebaseMessaging.requestPermission();

    final fcmToken = await _firebaseMessaging.getToken();
    print('Token:  $fcmToken');
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {

      latestMessage = message; // 메시지 저장
      notifyListeners(); // 변경 알림
    });

    notifyListeners();
    initPushNotifications();
    initLocalNotifications();
  }

}







class Settings extends StatelessWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Setting page',
      home: Scaffold(
        backgroundColor: LIST_BLACK_COLOR,
        body: _SettingsContent(),
      ),
    );
  }
}

class _SettingsContent extends StatefulWidget {
  @override
  _SettingsContentState createState() => _SettingsContentState();
}

class _SettingsContentState extends State<_SettingsContent> {
  bool _notificationStatus = true; // 일
  late SettingService settingService;


  @override
  void initState() {
    super.initState();
    settingService = SettingService(dio);
    fetchSettingStatus();
  }

  final dio = Dio();


  Future<void> fetchSettingStatus() async {
    try {
      final settingfetch = await settingService.getSettings();

      if (settingfetch != null && settingfetch.data != null) {
        final notificationStatus = settingfetch.data?.isNotificationToggle;
        setState(() {
          _notificationStatus = notificationStatus ?? false;
        });

        print('fetch 성공!!!!');
        print(settingfetch.data?.isNotificationToggle);
      } else {
        throw Exception('fetch 노테이션 실패');
      }
    } catch (error) {
      print('에러입니다 여기에러인가: $error');
    }
  }

  Future<void> updateSettingStatus(bool status) async {
    try {

      final settingupdate = await settingService.patchSettings(status);
      print('Setting Update Response: $settingupdate');

      if (settingupdate != null && settingupdate.data != null) {
        setState(() {
          _notificationStatus = status;
        });
        print('Update 성공');
        print(settingupdate.data);
      }
    } catch (e) {
      print('업데이트 에러: $e');

    }
  }


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.0, 100.0, 20.0, 0.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              buildText('알림 설정', context),
              BtnToggle(
                value: _notificationStatus,
                onChanged: (bool newValue) {
                  updateSettingStatus(newValue); // 토글 동작 실행
                },
              ),
            ],
          ),
          buildDivider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              buildText('버전 정보', context),
              buildText('v1.01', context),
            ],
          ),
          buildDivider(),
          buildText('개발자 정보', context),
          InkWell(
            onTap: () {
              showpopup(
                context,
                '로그아웃',  // 타이틀 수정
                '지금 로그아웃 하시겠습니까?', // 컨텐츠 수정
                '예',
                '아니오',
                    () {
                  // 예
                  AuthViewModel().logOut();

                },
                    () {
                  // 아니오
                    },
              );
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildDivider(),
                buildText('로그아웃', context),
              ],
            ),
          ),
          InkWell(
            onTap: () {
              showpopup(
                context,
                '회원탈퇴', // 적절한 회원탈퇴 메시지로 수정
                '지금 회원탈퇴 하시겠습니까?', // 적절한 회원탈퇴 메시지로 수정
                '예',
                '아니오',
                    () {
                  // 예를 눌렀을 때 실행할 함수
                  AuthViewModel().signOut();
                },
                    () {
                  // 아니오를 눌렀을 때 실행할 함수
                  Navigator.pop(context); // 모달 창 닫기
                },
              );
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildDivider(),
                buildText('회원탈퇴', context),
              ],
            ),
          ),
          buildDivider(),
        ],
      ),
    );
  }

  Widget buildText(String text, BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: Colors.white,
        letterSpacing: 2.0,
        fontSize: 24.0,
        fontWeight: FontWeight.normal,
      ),
    );
  }

  Widget buildDivider() {
    return Column(
      children: [
        Container(
          width: 500,
          child: Divider(color: MAIN_COLOR, thickness: 1.5),
        ),
        SizedBox(height: 15.0),
      ],
    );
  }
}

void showpopup(
    BuildContext context,
    String title,
    String content,
    String okTitle,
    String cancelTitle,
    VoidCallback okOnPressed,
    VoidCallback cancelOnPressed,
    ) {
  showDialog(
    context: context,
    barrierDismissible: true, // 모달 외부 터치 시 닫히도록 설정
    builder: (context) {
      return ConfirmDialog(
        cancelOnPressed: () {
          if (cancelOnPressed != null) {
            cancelOnPressed(); // 취소 버튼 누를 때 실행할 함수 호출
            Navigator.pop(context); // 모달 닫기
          }
        },
        okOnPressed: () {
          if (okOnPressed != null) {
            okOnPressed(); // 확인 버튼 누를 때 실행할 함수 호출
            Navigator.pop(context); // 모달 닫기
          }
        },
        title: title, // title 변수 사용
        content: content, // content 변수 사용
        okTitle: okTitle,
        cancelTitle: cancelTitle,
      );
    },
  );
}

