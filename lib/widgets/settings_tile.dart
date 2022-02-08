import 'package:flutter/material.dart';

class SettingsTile extends StatelessWidget {
  String title;
  String value = "";
  VoidCallback onTap;

  SettingsTile(this.title, this.value, this.onTap, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text(title), Text(value)],
      ),
      onTap: onTap,
    );
  }
}
