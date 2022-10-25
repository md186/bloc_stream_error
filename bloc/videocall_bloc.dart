// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../repositories/agora_repository.dart';
import '../../repositories/secure_storage_repository.dart';

part 'videocall_event.dart';
part 'videocall_state.dart';

class VideocallBloc extends Bloc<VideocallEvent, VideocallState> {
  final AgoraRepository _agoraRepository;
  final SecureStorageRepository _secureStorageRepo;
  VideocallBloc(this._agoraRepository, this._secureStorageRepo) : super(VideocallInitial()) {

    on<JoinEvent>((event, emit) async {
      final userFromToken = await _secureStorageRepo.getTokenPayloadUserId();

      
     final engine = await _agoraRepository.initForAgora(userFromToken, event.channelName);
      emit(RunVideocall(engine: engine));
    });

    

    on<UpdateVideoCall>((event, emit) {
      print('[LOG::LIVEEVENT] Bloc UpdateVideoCall fired -- ${event.joined} and ${event.remote}');
      emit(UpdateVideoCallState(engine: event.engine, joined: event.joined, remote: event.remote));
    });


    _agoraRepository.localJoined.listen((res) {
      print('[LOG::LIVEEVENT] Bloc Stream for LOCAL fired');
      _agoraRepository.lastLocal = res["localJoined"];
      _agoraRepository.lastRemote = res["remoteId"];
      add(UpdateVideoCall(engine: res["engine"], joined: _agoraRepository.lastLocal ?? false, remote: _agoraRepository.lastRemote ?? -1));
    });

    _agoraRepository.remoteId.listen((res) {
      print('[LOG::LIVEEVENT] Bloc Stream for REMOTE fired');
      _agoraRepository.lastLocal = res["localJoined"];
      _agoraRepository.lastRemote = res["remoteId"];
      add(UpdateVideoCall(engine: res["engine"], joined: _agoraRepository.lastLocal ?? false, remote: _agoraRepository.lastRemote ?? -1));
    });

  }
      

  @override
  Future<void> close() async {
    //cancel streams
    await _agoraRepository.localStreamController.close();
    await _agoraRepository.remoteStreamController.close();

    await _agoraRepository.engine?.leaveChannel();
    await _agoraRepository.engine?.destroy();
    
    await super.close();
  }
}
