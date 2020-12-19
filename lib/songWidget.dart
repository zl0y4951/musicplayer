import 'dart:io';
import 'main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_audio_query/flutter_audio_query.dart';

class SongWidget extends StatefulWidget {
  final List<SongInfo> songList;
  final String selected;

  SongWidget({@required this.songList, @required this.selected});

  @override
  _SongWidgetState createState() => _SongWidgetState();

  static String parseToMinutesSeconds(int ms) {
    String data;
    Duration duration = Duration(milliseconds: ms);

    int minutes = duration.inMinutes;
    int seconds = (duration.inSeconds) - (minutes * 60);

    data = minutes.toString() + ":";
    if (seconds <= 9) data += "0";

    data += seconds.toString();
    return data;
  }
}

class _SongWidgetState extends State<SongWidget> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: widget.songList.length,
        itemBuilder: (context, songIndex) {
          SongInfo song = widget.songList[songIndex];
          return Card(
              elevation: 5,
              child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListTile(
                    leading: song.albumArtwork != null
                        ? ClipRRect(
                            child: Image(
                              height: 90,
                              width: 150,
                              fit: BoxFit.cover,
                              image: FileImage(File(song.albumArtwork)),
                            ),
                            borderRadius: BorderRadius.circular(5),
                          )
                        : ClipRRect(
                            child: Image(
                                height: 50,
                                width: 50,
                                fit: BoxFit.fill,
                                image: AssetImage("assets/image/unknown.jpg")),
                          ),
                    title: Text(song.title,
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w700)),
                    subtitle: Text(
                      "${song.artist}",
                    ),
                    trailing: Text(
                        "${SongWidget.parseToMinutesSeconds(int.parse(song.duration))}",
                        style: TextStyle(
                            fontSize: 14,
                            color: Colors.black,
                            fontWeight: FontWeight.w500)),
                    selected: widget.selected == song.filePath.substring(8),
                    onTap: () {
                      widget.selected == song.filePath.substring(8)
                          ? audioManagerInstance.playOrPause()
                          : audioManagerInstance.play(index: songIndex);
                    },
                  )));
        });
  }
}
