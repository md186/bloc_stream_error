class EventRound extends StatelessWidget {
  final String firstName;
  final DateTime roundStart;
  final DateTime roundEnd;
  final int round;
  final String profileImage;
  final int partner;
  final String channelName;
  final int eventId;

  EventRound(this.firstName, this.roundStart, this.roundEnd, this.round,
      this.profileImage, this.partner, this.channelName, this.eventId,
      {Key? key})
      : super(key: key);


  @override
  Widget build(BuildContext context) {
    print('rebuild round');
    return Scaffold(
      body: SizedBox(
          height: MediaQuery.of(context).size.height * 1,
          width: MediaQuery.of(context).size.width * 1,
          child: Stack(
            children: [
              // Overlay

              BlocListener<LiveeventsBloc, LiveeventsState>(
                listener: (context, state) {
                  // TODO: implement listener
                  if (state is OpenVoting) {
                    BlocProvider.of<LivevideoCubit>(context)
                        .getEventTabs(LivecallGUI.startVoting);
                  }
                },
                child: BlocBuilder<LivevideoCubit, LivevideoState>(
                    builder: (context, navstate) {

                  return BlocBuilder<VideocallBloc, VideocallState>(
                      builder: (context, state) {
               
                    if (state is RunVideocall) {
                    

                      return Stack(
                        children: [
                          partnerPlaceholder(profileImage, context),
                          navstate.index == 0
                              ? ConferenceGUI(channelName)
                              : navstate.index == 1
                                  ? BlocProvider(
                                      create: (context) => VideocallmuteCubit(),
                                      child: ConferenceControlMenu(),
                                    )
                                  : navstate.index == 2
                                      ? BlocProvider(
                                          create: (context) => SumCubit()
                                            ..showRandom(),
                                          child: ConferenceControlDice(),
                                        )
                                      : navstate.index == 3
                                          ? ConferenceControlVote(
                                              partner: partner,
                                              profileImage: profileImage,
                                              event: eventId)
                                          : Container()
                        ],
                      );
                    }
                    if (state is UpdateVideoCallState) {
                      print(
                          '[LOG::LIVEEVENT] BlocBuilder VideocallBloc -- UpdateVideoCallState fired');

                      return Stack(
                        children: [
                          state.remote != -1
                              ? RtcRemoteView.SurfaceView(
                                  uid: state.remote,
                                  renderMode: VideoRenderMode.Fit,
                                  channelId: channelName)
                              : partnerPlaceholder(profileImage, context),
                          navstate.index == 0
                              ? ConferenceGUI(channelName)
                              : navstate.index == 1
                                  ? BlocProvider(
                                      create: (context) => VideocallmuteCubit(),
                                      child: ConferenceControlMenu(),
                                    )
                                  : navstate.index == 2
                                      ? BlocProvider(
                                          create: (context) => SumCubit()
                                          ..showRandom(),
                                          child: ConferenceControlDice(),
                                        )
                                      : navstate.index == 3
                                          ? ConferenceControlVote(
                                              partner: partner,
                                              profileImage: profileImage,
                                              event: eventId)
                                          : Container()
                        ],
                      );
                    }

                    return Container(
                      child: Text('Something went wrong'),

                    );
                  });
                }),
              ),

              Column(
                children: [
                  SizedBox(height: 65),
                  // Overlay Top
                  ConferenceInfoBar(firstName, roundStart, roundEnd, round,
                      profileImage, partner)
                ],
              ),
            ],
          )),
    );
  }

  Widget partnerPlaceholder(profileImage, BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 1,
      width: MediaQuery.of(context).size.width * 1,
      color: Color.fromRGBO(0, 0, 0, 1),
      child: ImageFiltered(
        imageFilter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Stack(
          children: [
            Container(
                height: MediaQuery.of(context).size.height * 1,
                width: MediaQuery.of(context).size.width * 1,
                child: Image.network(
                  profileImage,
                  //height: 300,
                  fit: BoxFit.cover,
                  frameBuilder: (_, image, loadingBuilder, __) {
                    if (loadingBuilder == null) {
                      return const SizedBox(
                        height: 300,
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    return image;
                  },
                  loadingBuilder: (BuildContext context, Widget image,
                      ImageChunkEvent? loadingProgress) {
                    if (loadingProgress == null) return image;
                    return SizedBox(
                      height: 300,
                      child: Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      ),
                    );
                  },
                )),
            Container(
              color: Color.fromRGBO(0, 0, 0, 0.5),
              height: MediaQuery.of(context).size.height * 1,
              width: MediaQuery.of(context).size.width * 1,
            )
          ],
        ),
      ),
    );
  }
}
