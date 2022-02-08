import 'package:flutter/material.dart';

class SettingsTile extends StatelessWidget {
  String title;
  String value = "";
  VoidCallback onTap;

  SettingsTile(this.title, this.value, this.onTap, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: false,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.headline2!.copyWith(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.subtitle2!.copyWith(fontSize: 14),
          ),
        ],
      ),
      onTap: onTap,
    );
  }
}
