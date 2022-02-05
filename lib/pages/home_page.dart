import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sliding_sheet/sliding_sheet.dart';
import 'package:audio_session/audio_session.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:flutter_sound_platform_interface/flutter_sound_recorder_platform_interface.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

typedef Fn = void Function();

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  static const List<Tab> tabs = <Tab>[
    Tab(text: 'Gravar'),
    Tab(text: 'Lista'),
  ];

  FlutterSoundPlayer? _mPlayer = FlutterSoundPlayer();
  FlutterSoundRecorder? _mRecorder = FlutterSoundRecorder();
  final StopWatchTimer _stopWatchTimer = StopWatchTimer();
  late TabController _tabController;
  final Codec _codec = Codec.aacMP4;
  bool _mPlayerIsInited = false;
  bool _mRecorderIsInited = false;
  bool _mPlaybackReady = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: tabs.length, vsync: this);

    _mPlayer!.openPlayer().then((value) {
      setState(() {
        _mPlayerIsInited = true;
      });
    });

    openTheRecorder().then((value) {
      setState(() {
        _mRecorderIsInited = true;
      });
    });
  }

  @override
  void dispose() async {
    stopPlayer();
    _mPlayer!.closePlayer();
    _mPlayer = null;

    _mRecorder!.closeRecorder();
    _mRecorder = null;

    _tabController.dispose();
    super.dispose();
  }

  Future<Directory> getDirectory() async {
    Directory? applicationDirectory = await getApplicationSupportDirectory();
    Directory audiosFolder = Directory("${applicationDirectory.path}/audios/");

    if (await audiosFolder.exists()) {
      return audiosFolder;
    } else {
      await audiosFolder.create(recursive: true);
      return audiosFolder;
    }
  }

  Future<void> openTheRecorder() async {
    var status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      throw RecordingPermissionException("Permissão do microfone negada");
    }

    await _mRecorder!.openRecorder();
    final session = await AudioSession.instance;
    await session.configure(AudioSessionConfiguration(
      avAudioSessionCategory: AVAudioSessionCategory.playAndRecord,
      avAudioSessionCategoryOptions: AVAudioSessionCategoryOptions.allowBluetooth | AVAudioSessionCategoryOptions.defaultToSpeaker,
      avAudioSessionMode: AVAudioSessionMode.spokenAudio,
      avAudioSessionRouteSharingPolicy: AVAudioSessionRouteSharingPolicy.defaultPolicy,
      avAudioSessionSetActiveOptions: AVAudioSessionSetActiveOptions.none,
      androidAudioAttributes: const AndroidAudioAttributes(
        contentType: AndroidAudioContentType.speech,
        flags: AndroidAudioFlags.none,
        usage: AndroidAudioUsage.voiceCommunication,
      ),
      androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
      androidWillPauseWhenDucked: true,
    ));

    _mRecorderIsInited = true;
  }

  void record() async {
    Directory? applicationDirectory = await getDirectory();

    _mRecorder!
        .startRecorder(
      toFile: "${applicationDirectory.path}/AUDIO.mp4",
      codec: _codec,
      audioSource: AudioSource.microphone,
    )
        .then((_) {
      _stopWatchTimer.onExecute.add(StopWatchExecute.start);
      setState(() {});
    });
  }

  void stopRecorder() async {
    await _mRecorder!.stopRecorder().then((value) {
      setState(() {
        _stopWatchTimer.onExecute.add(StopWatchExecute.reset);
        _mPlaybackReady = true;
      });
    });
  }

  void pauseRecorder() async {
    await _mRecorder!.pauseRecorder().then((_) {
      setState(() {
        _stopWatchTimer.onExecute.add(StopWatchExecute.stop);
      });
    });
  }

  void resumeRecorder() async {
    await _mRecorder!.resumeRecorder().then((_) {
      setState(() {
        _stopWatchTimer.onExecute.add(StopWatchExecute.start);
      });
    });
  }

  void cancelRecord() async {
    Directory? applicationDirectory = await getDirectory();

    await _mRecorder!.stopRecorder().then((value) {
      setState(() {
        _stopWatchTimer.onExecute.add(StopWatchExecute.reset);
        _mRecorder!.deleteRecord(fileName: "${applicationDirectory.path}/AUDIO.mp4");
      });
    });
  }

  void play() async {
    await _mPlayer!.startPlayer(
      fromURI: "/assets/audios/audio.m4a",
      codec: Codec.mp3,
      whenFinished: () {
        setState(() {});
      },
    );

    setState(() {});
  }

  Future<void> stopPlayer() async {
    if (_mPlayer != null) {
      await _mPlayer!.stopPlayer();
    }
  }

  Fn? getRecorderFn() {
    if (!_mRecorderIsInited || !_mPlayer!.isStopped) {
      return null;
    }

    if (_mRecorder!.isRecording) {
      return pauseRecorder;
    }

    if (_mRecorder!.isPaused) {
      return resumeRecorder;
    }

    return record;
  }

  Fn? getPlaybackFn() {
    if (!_mPlayerIsInited) {
      return null;
    }

    return _mPlayer!.isStopped
        ? play
        : () {
            stopPlayer().then((value) => setState(() {}));
          };
  }

  @override
  Widget build(BuildContext context) {
    void showAudioBottomSheet() async {
      await showSlidingBottomSheet(
        context,
        builder: (BuildContext context) {
          return SlidingSheetDialog(
            elevation: 8,
            cornerRadius: 15,
            builder: (context, state) {
              return Material(
                child: Container(
                  padding: const EdgeInsets.only(left: 24, right: 24, top: 15, bottom: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Text(
                          "Gravação 1",
                          style: Theme.of(context).textTheme.headline2!.copyWith(fontSize: 20),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(
                              Icons.skip_previous,
                              size: 24,
                              color: Color(0xFF323232),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 30.0),
                            child: SizedBox(
                              width: 56,
                              height: 56,
                              child: ElevatedButton(
                                onPressed: getPlaybackFn(),
                                child: Icon(_mPlayer!.isPlaying ? Icons.pause : Icons.play_arrow),
                                style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all<Color>(const Color(0xFFFF5656)),
                                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(50),
                                  )),
                                ),
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(
                              Icons.skip_next,
                              size: 24,
                              color: Color(0xFF323232),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              );
            },
          );
        },
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      appBar: AppBar(
        toolbarHeight: 90,
        title: const Text(
          "Gravador de Voz",
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.more_vert,
            ),
          )
        ],
        bottom: TabBar(
          tabs: const [Tab(text: "Gravar"), Tab(text: "Lista")],
          controller: _tabController,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          Column(
            children: [
              const SizedBox(
                height: 40,
              ),
              StreamBuilder<int>(
                stream: _stopWatchTimer.rawTime,
                initialData: 0,
                builder: (context, snap) {
                  final value = snap.data;
                  final displayTime = StopWatchTimer.getDisplayTime(value!);
                  return Text(
                    displayTime,
                    style: Theme.of(context).textTheme.headline1!.copyWith(fontSize: 38),
                  );
                },
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 40.0),
                child: Text(
                  "Alta qualidade",
                  style: Theme.of(context).textTheme.subtitle1,
                ),
              ),
              Container(
                width: double.infinity,
                height: 170,
                color: const Color(0xFFEAEAEA),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.only(bottom: 24.0, left: 24.0, right: 24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Visibility(
                      child: IconButton(
                        onPressed: () => cancelRecord(),
                        icon: const Icon(Icons.close),
                      ),
                      visible: _mRecorder!.isPaused ? true : false,
                      maintainSize: true,
                      maintainAnimation: true,
                      maintainState: true,
                    ),
                    SizedBox(
                      width: 56,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: getRecorderFn(),
                        child: _mRecorder!.isRecording ? const Icon(Icons.pause) : null,
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all<Color>(_mRecorder!.isRecording ? const Color(0xFFFF5656) : Colors.white),
                          shape: MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                            side: const BorderSide(color: Color(0xFFFF5656), width: 8),
                          )),
                        ),
                      ),
                    ),
                    Visibility(
                      child: SizedBox(
                        width: 40,
                        height: 40,
                        child: IconButton(
                          onPressed: () => stopRecorder(),
                          icon: const Icon(Icons.check),
                        ),
                      ),
                      visible: _mRecorder!.isPaused ? true : false,
                      maintainSize: true,
                      maintainAnimation: true,
                      maintainState: true,
                    ),
                  ],
                ),
              )
            ],
          ),
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(left: 24.0, right: 24.0, top: 20.0, bottom: 15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20.0),
                    child: TextField(
                      onTap: () => Navigator.pushNamed(context, "/search"),
                      readOnly: true,
                      decoration: const InputDecoration(
                        hintText: "Procurar",
                        suffixIcon: Icon(
                          Icons.search,
                          color: Color(0xFF777777),
                        ),
                      ),
                    ),
                  ),
                  DropdownButton(
                    items: [].map((value) {
                      return DropdownMenuItem(
                        child: Text(value),
                        value: value,
                      );
                    }).toList(),
                    onChanged: (_) {},
                    hint: Text("Categoria", style: Theme.of(context).textTheme.headline2!.copyWith(fontSize: 16)),
                    icon: const Icon(
                      Icons.arrow_drop_down_outlined,
                      color: Color(0xFF323232),
                      size: 24,
                    ),
                    underline: const SizedBox(),
                  ),
                  FutureBuilder(
                    future: getDirectory(),
                    builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                      if (snapshot.hasData) {
                        Directory dir = snapshot.data;
                        List<FileSystemEntity> audiosFiles = dir.listSync(recursive: true, followLinks: false);

                        if (audiosFiles.isEmpty) {
                          return Center(
                            child: Text(
                              "Nada encontrado",
                              style: Theme.of(context).textTheme.bodyText1,
                            ),
                          );
                        }

                        return ListView.separated(
                          shrinkWrap: true,
                          physics: const BouncingScrollPhysics(),
                          separatorBuilder: (context, index) => const SizedBox(height: 5),
                          itemCount: audiosFiles.length,
                          itemBuilder: (BuildContext context, int index) => ListTile(
                            onTap: () => showAudioBottomSheet(),
                            dense: true,
                            tileColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Gravação 1",
                                  style: Theme.of(context).textTheme.headline2,
                                ),
                                Text(
                                  "09:09",
                                  style: Theme.of(context).textTheme.subtitle2,
                                ),
                              ],
                            ),
                            subtitle: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "00:18:06",
                                  style: Theme.of(context).textTheme.subtitle2,
                                ),
                                Text(
                                  "1,4 mb",
                                  style: Theme.of(context).textTheme.subtitle2,
                                ),
                              ],
                            ),
                            leading: CircleAvatar(
                              radius: 35,
                              backgroundColor: const Color(0xFFEFEFEF),
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                onPressed: () {},
                                icon: const Icon(
                                  Icons.play_arrow,
                                  color: Color(0xFF323232),
                                ),
                                iconSize: 30,
                              ),
                            ),
                          ),
                        );
                      }

                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
