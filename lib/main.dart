import 'package:audio_manager/audio_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_audio_query/flutter_audio_query.dart';
import 'package:MusicPlayer/songWidget.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  var query;
  var selected;
  var title;
  @override
  void initState() {
    super.initState();
    setupAudio();
  }

  void setupAudio() {
    audioManagerInstance.onEvents((events, args) {
      switch (events) {
        case AudioManagerEvents.start:
          _slider = 0;
          break;
        case AudioManagerEvents.seekComplete:
          _slider = audioManagerInstance.position.inMilliseconds /
              audioManagerInstance.duration.inMilliseconds;
          setState(() {});
          break;
        case AudioManagerEvents.playstatus:
          isPlaying = audioManagerInstance.isPlaying;
          setState(() {
            selected = audioManagerInstance.info.url.substring(15);
            title = audioManagerInstance.info.title;
          });
          print(selected);
          break;
        case AudioManagerEvents.ended:
          audioManagerInstance.next();
          setState(() {});
          break;
        case AudioManagerEvents.timeupdate:
          _slider = audioManagerInstance.position.inMilliseconds /
              audioManagerInstance.duration.inMilliseconds;
          audioManagerInstance.updateLrc(args["position"].toString());
          setState(() {});
          break;
        case AudioManagerEvents.next:
          setState(() {
            selected = audioManagerInstance.info.url.substring(15);
            title = audioManagerInstance.info.title;
          });
          break;
        case AudioManagerEvents.previous:
          setState(() {
            selected = audioManagerInstance.info.url.substring(15);
            title = audioManagerInstance.info.title;
          });
          break;
        default:
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        resizeToAvoidBottomPadding: false,
        appBar: AppBar(
            title: Container(
          padding: EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: Colors.white,
          ),
          alignment: Alignment.centerLeft,
          child: TextField(
            onChanged: (q) {
              setState(() {
                query = q;
              });
            },
            decoration:
                InputDecoration(border: InputBorder.none, hintText: 'Поиск'),
          ),
        )),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Container(
              height: 500,
              child: FutureBuilder(
                future: query != null
                    ? FlutterAudioQuery().searchSongs(query: query)
                    : FlutterAudioQuery().getSongs(),
                builder: (context, snapshot) {
                  List<SongInfo> songInfo = snapshot.data;
                  if (snapshot.hasData) {
                    List<AudioInfo> _songList = List(songInfo.length);
                    _songList.asMap().forEach((i, e) {
                      _songList[i] = AudioInfo("file://${songInfo[i].filePath}",
                          desc: songInfo[i].displayName,
                          title: songInfo[i].title,
                          coverUrl: songInfo[i].albumArtwork ??
                              "assets/image/unknown.jpg");
                    });
                    if (_songList.isNotEmpty)
                      audioManagerInstance.audioList = _songList;

                    return SongWidget(
                      songList: songInfo,
                      selected: selected,
                    );
                  }
                  return Container(
                    height: MediaQuery.of(context).size.height * 0.4,
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          CircularProgressIndicator(),
                          SizedBox(
                            width: 20,
                          ),
                          Text(
                            "Loading....",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          )
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            bottomPanel(),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration d) {
    if (d == null) return "--:--";
    int minute = d.inMinutes;
    int second = (d.inSeconds > 60) ? (d.inSeconds % 60) : d.inSeconds;
    String format = ((minute < 10) ? "0$minute" : "$minute") +
        ":" +
        ((second < 10) ? "0$second" : "$second");
    return format;
  }

  Widget songProgress(BuildContext context) {
    var style = TextStyle(color: Colors.black);
    return Row(
      children: <Widget>[
        Text(
          _formatDuration(audioManagerInstance.position),
          style: style,
        ),
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 5),
            child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 2,
                  thumbColor: Colors.blueAccent,
                  overlayColor: Colors.blue,
                  thumbShape: RoundSliderThumbShape(
                    disabledThumbRadius: 5,
                    enabledThumbRadius: 5,
                  ),
                  overlayShape: RoundSliderOverlayShape(
                    overlayRadius: 10,
                  ),
                  activeTrackColor: Colors.blueAccent,
                  inactiveTrackColor: Colors.grey,
                ),
                child: Slider(
                  value: _slider ?? 0,
                  min: -0.01,
                  onChanged: (value) {
                    setState(() {
                      _slider = value;
                    });
                  },
                  onChangeEnd: (value) {
                    if (audioManagerInstance.duration != null) {
                      Duration msec = Duration(
                          milliseconds:
                              (audioManagerInstance.duration.inMilliseconds *
                                      value)
                                  .round());
                      audioManagerInstance.seekTo(msec);
                    }
                  },
                )),
          ),
        ),
        Text(
          _formatDuration(audioManagerInstance.duration),
          style: style,
        ),
      ],
    );
  }

  Widget bottomPanel() {
    return Container(
      decoration: BoxDecoration(
          border: Border.all(),
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      child: Column(children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0),
          child: Text(
            title ?? '',
            maxLines: 1,
            overflow: TextOverflow.fade,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: songProgress(context),
        ),
        Container(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              CircleAvatar(
                child: Center(
                  child: IconButton(
                      icon: Icon(
                        Icons.skip_previous,
                        color: Colors.white,
                      ),
                      onPressed: () => audioManagerInstance.previous()),
                ),
                backgroundColor: Colors.cyan.withOpacity(0.3),
              ),
              CircleAvatar(
                radius: 30,
                child: Center(
                  child: IconButton(
                    onPressed: () async {
                      audioManagerInstance.playOrPause();
                    },
                    padding: const EdgeInsets.all(0.0),
                    icon: Icon(
                      audioManagerInstance.isPlaying
                          ? Icons.pause
                          : Icons.play_arrow,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              CircleAvatar(
                backgroundColor: Colors.cyan.withOpacity(0.3),
                child: Center(
                  child: IconButton(
                      icon: Icon(
                        Icons.skip_next,
                        color: Colors.white,
                      ),
                      onPressed: () => audioManagerInstance.next()),
                ),
              ),
            ],
          ),
        ),
      ]),
    );
  }
}

var audioManagerInstance = AudioManager.instance;
bool showVol = false;
PlayMode playMode = audioManagerInstance.playMode;
bool isPlaying = false;
double _slider;
