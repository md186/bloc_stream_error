import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/liveevents/liveevents_bloc.dart';
import '../../bloc/navigation/livevideo/livevideo_cubit.dart';
import '../../bloc/videocall/videocall_bloc.dart';
import '../../repositories/agora_repository.dart';
import '../../repositories/secure_storage_repository.dart';
import 'widgets/call/round.dart';
import 'widgets/lobby/event_finished.dart';
import 'widgets/lobby/event_lobby.dart';

class LiveEventScreen extends StatelessWidget {
  final int eventId;
  LiveEventScreen({super.key, required this.eventId});

  @override
  Widget build(BuildContext context) {

    return BlocBuilder<LiveeventsBloc, LiveeventsState>(
        builder: (event, state) {
      if (state is LiveeventDataLoading) {
        return Scaffold(body: Center(child: const CircularProgressIndicator()));
      }

      if (state is CreateLiveeventRoom) {         
        return BlocProvider(
            create: (context) => VideocallBloc(
                RepositoryProvider.of<AgoraRepository>(context),
               RepositoryProvider.of<SecureStorageRepository>(context),
                )
              ..add(JoinEvent(channelName: state.channelName)),
            child: BlocProvider(
              create: (context) => LivevideoCubit(),
              child: EventRound(
                  state.firstName,
                  state.roundStart,
                  state.roundEnd,
                  state.round,
                  state.profileImage,
                  state.partner,
                  state.channelName,
                  eventId),
              
            ));
      }

      if (state is LiveeventFinishedState) {
        print('[LOG::LIVEEVENT] State Blocbuilder LiveeventFinishedState fired');

        return EventLobbyFinished(state);
      }

      if (state is LiveEventNotStarted) {
        print('[LOG::LIVEEVENT] State Blocbuilder LiveEventNotStarted fired');
        return EventLobby(state.currentRound, state);
      }
      return Scaffold(body: const Center(child: Text('something went wrong')));
    });
  }
}