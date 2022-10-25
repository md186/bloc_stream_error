import 'dart:async';
import 'dart:io';

import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:dio/dio.dart';
import 'package:permission_handler/permission_handler.dart';

class AgoraRepository {
    String url = Platform.isAndroid
      ? 'http://192.168.178.23:3006'
      : 'http://192.168.178.23:3006';
  var dio = Dio();

  RtcEngine? engine;
  String appId = '4b83f09c1527415d8b2de3694bbfcb20';

  final remoteStreamController = StreamController<dynamic>.broadcast();
  Stream<dynamic> get remoteId =>
      remoteStreamController.stream.asBroadcastStream();

  final localStreamController = StreamController<dynamic>.broadcast();
  Stream<dynamic> get localJoined =>
      localStreamController.stream.asBroadcastStream();

  bool? lastLocal;
  int? lastRemote;
  bool isMute = false;




  Future<void> requestPermission() async {
    // retrieve permissions

    var camStatus = await Permission.camera.status;
    var audioStatus = await Permission.microphone.status;
    if (camStatus.isDenied) {
      // We didn't ask for permission yet or the permission has been denied before but not permanently.
      await [Permission.camera].request();
    }

    if (audioStatus.isDenied) {
      // We didn't ask for permission yet or the permission has been denied before but not permanently.
      await [Permission.microphone].request();
    }
  }

  Future initForAgora(int userId, String channelName) async {
    final token = await createToken(channelName, userId);
    print('++ [initForAgora]: agora token created $token');

    // retrieve permissions
    await requestPermission();
    // create the engine for communicating with agora
    engine = await RtcEngine.create(appId);
    // set up event handling for the engine
    engine!.setEventHandler(RtcEngineEventHandler(
      joinChannelSuccess: (String channel, int uid, int elapsed) {
        print('[LOG::LIVEEVENT] initagora - $uid successfully joined channel: $channel');
        localStreamController.sink.add(
            {"engine": engine, "localJoined": true, "remoteId": lastRemote});
      },
      userJoined: (int uid, int elapsed) {
        print('[LOG::LIVEEVENT] initagora - remote user $uid joined channel');
        remoteStreamController.sink
            .add({"engine": engine, "localJoined": lastLocal, "remoteId": uid});
      },
      userOffline: (int uid, UserOfflineReason reason) async {
        print('[LOG::LIVEEVENT] initagora - remote user $uid left channel');
        remoteStreamController.sink
            .add({"engine": engine, "localJoined": lastLocal, "remoteId": -1});
      },
      
      rtcStats: (stats) {},
    ));
    
    // enable video
    await engine!.enableVideo();
    await engine!.joinChannel(token, channelName, null, userId);

    return engine;
  }

  Future<bool> muteUnmute() async {
    isMute = !isMute;
    await engine?.muteLocalAudioStream(isMute);
    return isMute;
  }
}
