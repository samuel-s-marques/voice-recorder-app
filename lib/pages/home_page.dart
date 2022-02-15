import 'dart:async';
import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:just_audio/just_audio.dart';
import 'package:logger/logger.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sliding_sheet/sliding_sheet.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'package:voice_recorder_app/utils/utils.dart';
import 'package:wakelock/wakelock.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

typedef Fn = void Function();

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  static const List<Tab> tabs = <Tab>[
    Tab(text: 'Gravar'),
    Tab(text: 'Lista'),
  ];

  FlutterSoundPlayer? _mPlayer = FlutterSoundPlayer();
  FlutterSoundRecorder? _mRecorder = FlutterSoundRecorder();
  final StopWatchTimer _stopWatchTimer = StopWatchTimer();
  late TabController _tabController;
  final Codec _codec = Codec.pcm16WAV;
  final String _fileExtension = "wav";
  final player = AudioPlayer();
  bool _mRecorderIsInited = false;
  int beingPlayed = -1;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: tabs.length, vsync: this);

    openTheRecorder().then((value) {
      setState(() {
        _mRecorderIsInited = true;
      });
    });

    WidgetsBinding.instance?.addObserver(this);
  }

  @override
  void dispose() async {
    WidgetsBinding.instance?.removeObserver(this);
    player.dispose();
    _mPlayer!.closePlayer();
    _mPlayer = null;

    _mRecorder!.closeRecorder();
    _mRecorder = null;

    _tabController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      player.stop();
    }
  }

  Future<void> openTheRecorder() async {
    var status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      throw RecordingPermissionException("Permissão do microfone negada");
    }

    await _mRecorder?.setLogLevel(Level.nothing);
    await _mRecorder!.openRecorder();

    _mRecorderIsInited = true;
  }

  void record() async {
    Directory? applicationDirectory = await getDirectory();
    player.stop();

    _mRecorder!
        .startRecorder(
      toFile: "${applicationDirectory.path}/temp.$_fileExtension",
      codec: _codec,
    )
        .then((_) async {
      _stopWatchTimer.onExecute.add(StopWatchExecute.start);
      await Wakelock.enable();
      setState(() {});
    });
  }

  void stopRecorder(String newTitle) async {
    await _mRecorder!.stopRecorder().then((value) async {
      setState(() {
        _stopWatchTimer.onExecute.add(StopWatchExecute.reset);
      });

      Directory? applicationDirectory = await getDirectory();
      File audioFile = File('${applicationDirectory.path}/temp.$_fileExtension');

      await audioFile.rename('${applicationDirectory.path}/$newTitle.$_fileExtension');
      await Wakelock.disable();
    });
  }

  void pauseRecorder() async {
    await _mRecorder!.pauseRecorder().then((_) async {
      setState(() {
        _stopWatchTimer.onExecute.add(StopWatchExecute.stop);
      });
      await Wakelock.disable();
    });
  }

  void resumeRecorder() async {
    await _mRecorder!.resumeRecorder().then((_) async {
      setState(() {
        _stopWatchTimer.onExecute.add(StopWatchExecute.start);
      });
      await Wakelock.enable();
    });
  }

  void cancelRecord() async {
    Directory? applicationDirectory = await getDirectory();

    await _mRecorder!.stopRecorder().then((value) async {
      setState(() {
        _stopWatchTimer.onExecute.add(StopWatchExecute.reset);
        _mRecorder!.deleteRecord(fileName: "${applicationDirectory.path}/temp.$_fileExtension");
      });
      await Wakelock.disable();
    });
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
                                onPressed: () {},
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

    void saveAudioBottomSheet() async {
      TextEditingController _recordingTitle = TextEditingController();
      String? selectedCategory;

      await showSlidingBottomSheet(
        context,
        builder: (BuildContext context) {
          return SlidingSheetDialog(
            elevation: 8,
            cornerRadius: 15,
            color: const Color(0xFFF2F2F2),
            builder: (context, state) {
              return Material(
                child: StatefulBuilder(
                  builder: (BuildContext context, void Function(void Function()) setState) {
                    return Container(
                      color: const Color(0xFFF2F2F2),
                      padding: const EdgeInsets.only(left: 24, right: 24, top: 30, bottom: 30),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: Text(
                              "Salvar gravação",
                              style: Theme.of(context).textTheme.headline2!.copyWith(fontSize: 20),
                            ),
                          ),
                          TextField(
                            controller: _recordingTitle,
                            style: Theme.of(context).textTheme.subtitle1!.copyWith(fontSize: 16),
                            maxLength: 30,
                            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r"^[\p{L}\p{N} ]+$", unicode: true))],
                            textCapitalization: TextCapitalization.sentences,
                            decoration: const InputDecoration(
                              labelText: "Título da gravação",
                            ),
                          ),
                          FutureBuilder(
                            future: getDirectory(),
                            builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                              List<String>? categories = [];

                              if (snapshot.hasData) {
                                Directory dir = snapshot.data;
                                List<FileSystemEntity> categoryList = dir.listSync(recursive: true, followLinks: false);

                                if (categoryList.isNotEmpty) {
                                  List<String?> list = categoryList.map((category) {
                                    if (category.statSync().type == FileSystemEntityType.directory) {
                                      if (category.name != null) {
                                        return category.name ?? "Categoria";
                                      }
                                    }
                                  }).toList();

                                  list.removeWhere((element) => element == null);
                                  categories = list.cast<String>();
                                }
                              }

                              return DropdownButton(
                                items: categories.map((value) {
                                  return DropdownMenuItem(
                                    child: Text(value),
                                    value: value,
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    selectedCategory = value.toString();
                                  });
                                },
                                hint: Text("Categoria", style: Theme.of(context).textTheme.headline2!.copyWith(fontSize: 16)),
                                value: selectedCategory,
                                icon: const Icon(
                                  Icons.arrow_drop_down_outlined,
                                  color: Color(0xFF323232),
                                  size: 24,
                                ),
                                underline: const SizedBox(),
                                isExpanded: true,
                              );
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            },
            footerBuilder: (context, state) {
              return Container(
                color: const Color(0xFFF2F2F2),
                child: Padding(
                  padding: const EdgeInsets.only(left: 24.0, right: 24.0, bottom: 24.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 10.0),
                          child: SizedBox(
                            height: 40,
                            child: ElevatedButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text(
                                "Cancelar",
                                style: Theme.of(context).textTheme.bodyText1!.copyWith(fontSize: 16),
                              ),
                              style: Theme.of(context).elevatedButtonTheme.style!.copyWith(
                                  backgroundColor: MaterialStateProperty.all(Theme.of(context).buttonTheme.colorScheme?.secondary)),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 10.0),
                          child: SizedBox(
                            height: 40,
                            child: ElevatedButton(
                              onPressed: () {
                                String now = DateFormat("h_mm a - EEE, d MMM, yyyy").format(DateTime.now());
                                String title = _recordingTitle.text.trim().isEmpty ? "Recording_$now" : _recordingTitle.text.trim();

                                if (selectedCategory != null && selectedCategory!.isNotEmpty) {
                                  title = "$selectedCategory/$title";
                                }

                                stopRecorder(title);
                                Navigator.pop(context);
                              },
                              child: Text(
                                "Salvar",
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyText1!
                                    .copyWith(fontSize: 16, color: Theme.of(context).buttonTheme.colorScheme?.secondary),
                              ),
                              style: Theme.of(context)
                                  .elevatedButtonTheme
                                  .style!
                                  .copyWith(backgroundColor: MaterialStateProperty.all(Theme.of(context).buttonTheme.colorScheme?.primary)),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      );
    }

    void handleTap(String value) {
      switch (value) {
        case "Configurações":
          Navigator.pushNamed(context, "/settings");
          break;
        case "Lixeira":
          break;
        case "Categorias":
          Navigator.pushNamed(context, "/categories");
          break;
      }
    }

    List<String> getItemsList() {
      if (_tabController.index == 0) {
        return ['Configurações', 'Lixeira'];
      } else {
        return ['Categorias', 'Configurações', 'Lixeira'];
      }
    }

    void rename(File file) async {
      String path = file.path;

      TextEditingController _recordingTitle = TextEditingController();
      String? selectedCategory;

      await showSlidingBottomSheet(
        context,
        builder: (BuildContext context) {
          return SlidingSheetDialog(
            elevation: 8,
            cornerRadius: 15,
            color: const Color(0xFFF2F2F2),
            builder: (context, state) {
              return Material(
                child: StatefulBuilder(
                  builder: (BuildContext context, void Function(void Function()) setState) {
                    return Container(
                      color: const Color(0xFFF2F2F2),
                      padding: const EdgeInsets.only(left: 24, right: 24, top: 30, bottom: 30),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: Text(
                              "Renomear gravação",
                              style: Theme.of(context).textTheme.headline2!.copyWith(fontSize: 20),
                            ),
                          ),
                          TextField(
                            controller: _recordingTitle,
                            style: Theme.of(context).textTheme.subtitle1!.copyWith(fontSize: 16),
                            maxLength: 30,
                            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r"^[\p{L}\p{N} ]+$", unicode: true))],
                            textCapitalization: TextCapitalization.sentences,
                            decoration: const InputDecoration(
                              labelText: "Novo título da gravação",
                            ),
                          ),
                          FutureBuilder(
                            future: getDirectory(),
                            builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                              List<String>? categories = [];

                              if (snapshot.hasData) {
                                Directory dir = snapshot.data;
                                List<FileSystemEntity> categoryList = dir.listSync(recursive: true, followLinks: false);

                                if (categoryList.isNotEmpty) {
                                  List<String?> list = categoryList.map((category) {
                                    if (category.statSync().type == FileSystemEntityType.directory) {
                                      if (category.name != null) {
                                        return category.name ?? "Categoria";
                                      }
                                    }
                                  }).toList();

                                  list.removeWhere((element) => element == null);
                                  categories = list.cast<String>();
                                }
                              }

                              return DropdownButton(
                                items: categories.map((value) {
                                  return DropdownMenuItem(
                                    child: Text(value),
                                    value: value,
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    selectedCategory = value.toString();
                                  });
                                },
                                hint: Text("Categoria", style: Theme.of(context).textTheme.headline2!.copyWith(fontSize: 16)),
                                value: selectedCategory,
                                icon: const Icon(
                                  Icons.arrow_drop_down_outlined,
                                  color: Color(0xFF323232),
                                  size: 24,
                                ),
                                underline: const SizedBox(),
                                isExpanded: true,
                              );
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            },
            footerBuilder: (context, state) {
              return Container(
                color: const Color(0xFFF2F2F2),
                child: Padding(
                  padding: const EdgeInsets.only(left: 24.0, right: 24.0, bottom: 24.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 10.0),
                          child: SizedBox(
                            height: 40,
                            child: ElevatedButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text(
                                "Cancelar",
                                style: Theme.of(context).textTheme.bodyText1!.copyWith(fontSize: 16),
                              ),
                              style: Theme.of(context).elevatedButtonTheme.style!.copyWith(
                                  backgroundColor: MaterialStateProperty.all(Theme.of(context).buttonTheme.colorScheme?.secondary)),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 10.0),
                          child: SizedBox(
                            height: 40,
                            child: ElevatedButton(
                              onPressed: () async {
                                String now = DateFormat.yMMMMd().format(DateTime.now());
                                String title = _recordingTitle.text.trim().isEmpty ? "Recording_$now" : _recordingTitle.text.trim();
                                int lastSeparator = path.lastIndexOf(Platform.pathSeparator);

                                if (selectedCategory != null && selectedCategory!.isNotEmpty) {
                                  title = "$selectedCategory/$title";
                                }

                                String newPath = path.substring(0, lastSeparator + 1) + title + _fileExtension;

                                await file.rename(newPath);
                                Navigator.pop(context);
                              },
                              child: Text(
                                "Salvar",
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyText1!
                                    .copyWith(fontSize: 16, color: Theme.of(context).buttonTheme.colorScheme?.secondary),
                              ),
                              style: Theme.of(context)
                                  .elevatedButtonTheme
                                  .style!
                                  .copyWith(backgroundColor: MaterialStateProperty.all(Theme.of(context).buttonTheme.colorScheme?.primary)),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      );
    }

    void categorize(File file) async {
      String path = file.path;

      TextEditingController _recordingTitle = TextEditingController();
      _recordingTitle.text = file.name!;
      String? selectedCategory;

      await showSlidingBottomSheet(
        context,
        builder: (BuildContext context) {
          return SlidingSheetDialog(
            elevation: 8,
            cornerRadius: 15,
            color: const Color(0xFFF2F2F2),
            builder: (context, state) {
              return Material(
                child: StatefulBuilder(
                  builder: (BuildContext context, void Function(void Function()) setState) {
                    return Container(
                      color: const Color(0xFFF2F2F2),
                      padding: const EdgeInsets.only(left: 24, right: 24, top: 30, bottom: 30),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: Text(
                              "Renomear gravação",
                              style: Theme.of(context).textTheme.headline2!.copyWith(fontSize: 20),
                            ),
                          ),
                          TextField(
                            controller: _recordingTitle,
                            style: Theme.of(context).textTheme.subtitle1!.copyWith(fontSize: 16),
                            maxLength: 30,
                            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r"^[\p{L}\p{N} ]+$", unicode: true))],
                            textCapitalization: TextCapitalization.sentences,
                            decoration: const InputDecoration(
                              labelText: "Novo título da gravação",
                            ),
                          ),
                          FutureBuilder(
                            future: getDirectory(),
                            builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                              List<String>? categories = [];

                              if (snapshot.hasData) {
                                Directory dir = snapshot.data;
                                List<FileSystemEntity> categoryList = dir.listSync(recursive: true, followLinks: false);

                                if (categoryList.isNotEmpty) {
                                  List<String?> list = categoryList.map((category) {
                                    if (category.statSync().type == FileSystemEntityType.directory) {
                                      if (category.name != null) {
                                        return category.name ?? "Categoria";
                                      }
                                    }
                                  }).toList();

                                  list.removeWhere((element) => element == null);
                                  categories = list.cast<String>();
                                }
                              }

                              return DropdownButton(
                                items: categories.map((value) {
                                  return DropdownMenuItem(
                                    child: Text(value),
                                    value: value,
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    selectedCategory = value.toString();
                                  });
                                },
                                hint: Text("Categoria", style: Theme.of(context).textTheme.headline2!.copyWith(fontSize: 16)),
                                value: selectedCategory,
                                icon: const Icon(
                                  Icons.arrow_drop_down_outlined,
                                  color: Color(0xFF323232),
                                  size: 24,
                                ),
                                underline: const SizedBox(),
                                isExpanded: true,
                              );
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            },
            footerBuilder: (context, state) {
              return Container(
                color: const Color(0xFFF2F2F2),
                child: Padding(
                  padding: const EdgeInsets.only(left: 24.0, right: 24.0, bottom: 24.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 10.0),
                          child: SizedBox(
                            height: 40,
                            child: ElevatedButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text(
                                "Cancelar",
                                style: Theme.of(context).textTheme.bodyText1!.copyWith(fontSize: 16),
                              ),
                              style: Theme.of(context).elevatedButtonTheme.style!.copyWith(
                                  backgroundColor: MaterialStateProperty.all(Theme.of(context).buttonTheme.colorScheme?.secondary)),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 10.0),
                          child: SizedBox(
                            height: 40,
                            child: ElevatedButton(
                              onPressed: () async {
                                String now = DateFormat.yMMMMd().format(DateTime.now());
                                String title = _recordingTitle.text.trim().isEmpty ? "Recording_$now" : _recordingTitle.text.trim();
                                int lastSeparator = path.lastIndexOf(Platform.pathSeparator);

                                if (selectedCategory != null && selectedCategory!.isNotEmpty) {
                                  title = "$selectedCategory/$title";
                                }

                                String newPath = path.substring(0, lastSeparator + 1) + title + _fileExtension;

                                await file.rename(newPath);
                                Navigator.pop(context);
                              },
                              child: Text(
                                "Salvar",
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyText1!
                                    .copyWith(fontSize: 16, color: Theme.of(context).buttonTheme.colorScheme?.secondary),
                              ),
                              style: Theme.of(context)
                                  .elevatedButtonTheme
                                  .style!
                                  .copyWith(backgroundColor: MaterialStateProperty.all(Theme.of(context).buttonTheme.colorScheme?.primary)),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      );
    }

    void delete(File file) async {
      return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            elevation: 8,
            backgroundColor: const Color(0xFFF2F2F2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            title: const Text("Tem certeza que quer deletar este áudio?"),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 10.0),
                child: SizedBox(
                  height: 40,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      "Cancelar",
                      style: Theme.of(context).textTheme.bodyText1!.copyWith(fontSize: 16),
                    ),
                    style: Theme.of(context)
                        .elevatedButtonTheme
                        .style!
                        .copyWith(backgroundColor: MaterialStateProperty.all(Theme.of(context).buttonTheme.colorScheme?.secondary)),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10.0),
                child: SizedBox(
                  height: 40,
                  child: ElevatedButton(
                    onPressed: () async {
                      await file.delete();
                      setState(() {});
                      Navigator.pop(context);
                    },
                    child: Text(
                      "Salvar",
                      style: Theme.of(context)
                          .textTheme
                          .bodyText1!
                          .copyWith(fontSize: 16, color: Theme.of(context).buttonTheme.colorScheme?.secondary),
                    ),
                    style: Theme.of(context)
                        .elevatedButtonTheme
                        .style!
                        .copyWith(backgroundColor: MaterialStateProperty.all(Theme.of(context).buttonTheme.colorScheme?.primary)),
                  ),
                ),
              ),
            ],
          );
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 90,
        title: const Text("Gravador de Voz"),
        actions: [
          PopupMenuButton(
            onSelected: handleTap,
            itemBuilder: (BuildContext context) {
              return getItemsList().map((String choice) {
                return PopupMenuItem(
                  child: Text(choice),
                  value: choice,
                );
              }).toList();
            },
          ),
        ],
        bottom: TabBar(
          tabs: const [Tab(text: "Gravar"), Tab(text: "Ouvir")],
          controller: _tabController,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          Column(
            children: [
              const SizedBox(height: 40),
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
                          onPressed: () => saveAudioBottomSheet(),
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
                        hintText: "Pesquisar",
                        suffixIcon: Icon(
                          Icons.search,
                          color: Color(0xFF777777),
                        ),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      DropdownButton(
                        items: [].map((value) {
                          return DropdownMenuItem(
                            child: Text(value, style: Theme.of(context).popupMenuTheme.textStyle),
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
                        borderRadius: BorderRadius.circular(10),
                      ),
                      DropdownButton(
                        items: ["Data", "A-Z", "Z-A", "Tamanho"].map((value) {
                          return DropdownMenuItem(
                            child: Text(value, style: Theme.of(context).popupMenuTheme.textStyle),
                            value: value,
                          );
                        }).toList(),
                        onChanged: (_) {},
                        hint: Text("Ordenar", style: Theme.of(context).textTheme.headline2!.copyWith(fontSize: 16)),
                        icon: const Icon(
                          Icons.arrow_drop_down_outlined,
                          color: Color(0xFF323232),
                          size: 24,
                        ),
                        underline: const SizedBox(),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ],
                  ),
                  FutureBuilder(
                    future: getDirectory(),
                    builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                      if (snapshot.hasData) {
                        Directory dir = snapshot.data;
                        List<FileSystemEntity?> audiosFiles = dir.listSync(recursive: true, followLinks: false).map((file) {
                          if (file.statSync().type == FileSystemEntityType.file) {
                            return file;
                          }
                        }).toList();

                        audiosFiles.removeWhere((element) => element == null);

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
                          itemBuilder: (BuildContext context, int index) {
                            File audioFile = File(audiosFiles[index]!.path);

                            DateFormat dayFormat = DateFormat.yMd();
                            DateFormat timeFormat = DateFormat.Hm();
                            String fileSize = getFileSize(audioFile.lengthSync(), 1);
                            DateTime createdAt = audioFile.lastModifiedSync();
                            String createdAtFormatted = "";
                            String fileName = audioFile.name ?? "Gravação";

                            if (createdAt.isToday()) {
                              createdAtFormatted = timeFormat.format(createdAt);
                            } else {
                              createdAtFormatted = dayFormat.format(createdAt);
                            }

                            return ListTile(
                              onTap: () => showAudioBottomSheet(),
                              title: AutoSizeText(
                                fileName,
                                maxLines: 1,
                                style: Theme.of(context).textTheme.headline2,
                              ),
                              subtitle: Text(
                                "$fileSize \u2022 $createdAtFormatted",
                                style: Theme.of(context).textTheme.subtitle2,
                              ),
                              trailing: PopupMenuButton(
                                onSelected: (value) {
                                  switch (value) {
                                    case "Compartilhar":
                                      Share.shareFiles([audioFile.path], text: fileName);
                                      break;
                                    case "Renomear":
                                      rename(audioFile);
                                      break;
                                    case "Categorizar":
                                      categorize(audioFile);
                                      break;
                                    case "Deletar":
                                      delete(audioFile);
                                      break;
                                  }
                                },
                                itemBuilder: (BuildContext context) {
                                  return ["Compartilhar", "Renomear", "Categorizar", "Deletar"].map((String choice) {
                                    return PopupMenuItem(
                                      child: Text(choice),
                                      value: choice,
                                    );
                                  }).toList();
                                },
                              ),
                              leading: CircleAvatar(
                                radius: 35,
                                backgroundColor: const Color(0xFFEFEFEF),
                                child: IconButton(
                                  padding: EdgeInsets.zero,
                                  onPressed: () async {
                                    if (player.playing && beingPlayed == index) {
                                      setState(() {
                                        beingPlayed = -1;
                                        player.pause();
                                      });
                                    } else {
                                      await player.setFilePath(audioFile.path);

                                      setState(() {
                                        beingPlayed = index;
                                        player.play();
                                      });
                                    }
                                  },
                                  icon: Icon(
                                    beingPlayed == index ? Icons.pause : Icons.play_arrow,
                                    color: const Color(0xFF323232),
                                  ),
                                  iconSize: 30,
                                ),
                              ),
                            );
                          },
                        );
                      }

                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    },
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
