import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:voice_recorder_app/util/util.dart';

class AudioCard extends StatefulWidget {
  const AudioCard({Key? key}) : super(key: key);

  @override
  _AudioCardState createState() => _AudioCardState();
}

class _AudioCardState extends State<AudioCard> {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        showAudioBottomSheet(context);
      },
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
    );
  }
}
