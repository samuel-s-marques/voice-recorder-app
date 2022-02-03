import 'package:sliding_sheet/sliding_sheet.dart';
import 'package:flutter/material.dart';

void showAudioBottomSheet(BuildContext context) async {
  await showSlidingBottomSheet(
    context,
    builder: (BuildContext context) {
      return SlidingSheetDialog(
        elevation: 8,
        cornerRadius: 15,
        builder: (context, state) {
          return Container(
          );
        },
        headerBuilder: (context, state) {
          return Text("Gravação 1");
        }
      );
    },
  );
}
