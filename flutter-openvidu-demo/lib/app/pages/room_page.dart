import 'dart:convert';
import 'dart:math' as math;

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:openvidu_client/openvidu_client.dart';
import 'package:flutter_openvidu_demo/app/utils/extensions.dart';
import 'package:flutter_openvidu_demo/app/widgets/config_view.dart';

import '../models/connection.dart';
import '../models/session.dart';
import '../utils/logger.dart';
import '../widgets/controls.dart';
import '../widgets/media_stream_view.dart';

class RoomPage extends StatefulWidget {
  final Session room;
  final String userName;
  final String serverUrl;
  final String secret;
  const RoomPage(
      {super.key,
      required this.room,
      required this.userName,
      required this.serverUrl,
      required this.secret});

  @override
  State<RoomPage> createState() => _RoomPageState();
}

class _RoomPageState extends State<RoomPage> {
  Map<String, RemoteParticipant> remoteParticipants = {};
  bool localPressed = false;
  Map<String, bool> remotePressed = {};
  MediaDeviceInfo? input;
  bool isInside = false;
  late OpenViduClient _openvidu;

  LocalParticipant? localParticipant;

  @override
  void initState() {
    super.initState();
    initOpenVidu();
    _listenSessionEvents();
  }

  Future<void> initOpenVidu() async {
    _openvidu = OpenViduClient('https://i9a502.p.ssafy.io/openvidu');
    localParticipant =
        await _openvidu.startLocalPreview(context, StreamMode.frontCamera);
    setState(() {});
  }

  void _listenSessionEvents() {
    _openvidu.on(OpenViduEvent.userJoined, (params) async {
      await _openvidu.subscribeRemoteStream(params["id"]);
    });
    _openvidu.on(OpenViduEvent.userPublished, (params) {
      _openvidu.subscribeRemoteStream(params["id"],
          video: params["videoActive"], audio: params["audioActive"]);
    });

    _openvidu.on(OpenViduEvent.addStream, (params) {
      remoteParticipants = {..._openvidu.participants};
      remotePressed = _openvidu.participants.keys.fold(<String, bool>{},(res, id){
        res[id] = false;
        return res;
      });
      setState(() {});
    });

    _openvidu.on(OpenViduEvent.removeStream, (params) {
      remoteParticipants = {..._openvidu.participants};
      remotePressed = _openvidu.participants.keys.fold(<String, bool>{},(res, id){
        res[id] = false;
        return res;
      });
      setState(() {});
    });

    _openvidu.on(OpenViduEvent.publishVideo, (params) {
      remoteParticipants = {..._openvidu.participants};
      remotePressed = _openvidu.participants.keys.fold(<String, bool>{},(res, id){
        res[id] = false;
        return res;
      });
      setState(() {});
    });
    _openvidu.on(OpenViduEvent.publishAudio, (params) {
      remoteParticipants = {..._openvidu.participants};
      remotePressed = _openvidu.participants.keys.fold(<String, bool>{},(res, id){
        res[id] = false;
        return res;
      });
      setState(() {});
    });
    _openvidu.on(OpenViduEvent.updatedLocal, (params) {
      localParticipant = params['localParticipant'];
      setState(() {});
    });
    _openvidu.on(OpenViduEvent.reciveMessage, (params) {
      String? data = params["data"];
      String? type = params["type"];
      String? from = params["from"];

      if (remoteParticipants.containsKey(from)) {
        remotePressed.update(from!, (value) => true);
        setState(() {});
        if (localPressed && !remotePressed.containsValue(false)) {
          _onDisconnect();
        }
      }

      // context.showMessageRecivedDialog(params["data"] ?? '');
    });
    _openvidu.on(OpenViduEvent.userUnpublished, (params) {
      remoteParticipants = {..._openvidu.participants};
      remotePressed = _openvidu.participants.keys.fold(<String, bool>{},(res, id){
        res[id] = false;
        return res;
      });
      setState(() {});
    });

    _openvidu.on(OpenViduEvent.error, (params) {
      context.showErrorDialog(params["error"]);
    });
  }

  Future<void> _onConnect() async {
    final dio = Dio();
    dio.options.baseUrl = '${widget.serverUrl}/openvidu/api';
    dio.options.headers['content-Type'] = 'application/json';
    dio.options.headers["authorization"] =
        'Basic ${base64Encode(utf8.encode('OPENVIDUAPP:${widget.secret}'))}';
    try {
      var response = await dio.post(
        '/sessions/${widget.room.sessionId}/connection',
        data: {"type": widget.room.type, "role": "PUBLISHER", "record": false},
      );
      final statusCode = response.statusCode ?? 400;
      if (statusCode >= 200 && statusCode < 300) {
        logger.i(response.data);
        final connection = Connection.fromJson(response.data);

        localParticipant = await _openvidu.publishLocalStream(
            token: connection.token!, userName: widget.userName);
        setState(() {
          isInside = true;
        });
      }
    } catch (e) {
      logger.e(e);
    }
  }

  void _onDisconnect() async {
    final nav = Navigator.of(context);
    await _openvidu.disconnect();
    nav.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: localParticipant == null
          ? Container()
          : !isInside
              ? ConfigView(
                  participant: localParticipant!,
                  onConnect: _onConnect,
                  userName: widget.userName,
                )
              : Column(
                  children: [
                    Expanded(
                      child: MediaStreamView(
                        borderRadius: BorderRadius.circular(15),
                        participant: localParticipant!,
                      ),
                    ),
                    SizedBox(
                      height: 100,
                      child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: math.max(0, remoteParticipants.length),
                          itemBuilder: (BuildContext context, int index) {
                            final remote =
                                remoteParticipants.values.elementAt(index);
                            return SizedBox(
                              width: 100,
                              height: 100,
                              child: MediaStreamView(
                                borderRadius: BorderRadius.circular(15),
                                participant: remote,
                              ),
                            );
                          }),
                    ),
                    if (localParticipant != null)
                      SafeArea(
                        top: false,
                        child: ControlsWidget(_openvidu, localParticipant!),
                      ),
                    SizedBox(
                      height: 100,
                      child: ListView.builder(itemCount: math.max(0, remotePressed.length), itemBuilder: (BuildContext context, int index) {
                        final pressed = remotePressed.values.elementAt(index);
                        return Text("$pressed");
                      }),
                    ),
                    SizedBox(
                      height: 100,
                      child: Text("$localPressed")
                    ),
                    ElevatedButton(
                      onPressed: () {
                        _openvidu.sendMessage(OvMessage.fromJson(<String, dynamic>{"data": "true", "type": "pressed"}));
                        setState(() {
                          localPressed = true;
                        });
                        if (!remotePressed.containsValue(false)) {
                          _onDisconnect();
                        }
                      },
                      child: const Text('CHECK'),
                    ),
                  ],
                ),
    );
  }
}
