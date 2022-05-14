import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:voice_recorder_app/widgets/settings_tile.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Configurações",
          style: Theme.of(context).appBarTheme.titleTextStyle!.copyWith(fontWeight: FontWeight.w400, fontSize: 20),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
          child: Wrap(
            runSpacing: 10,
            children: [
              SettingsTile("Linguagem", "Português", () {}),
              SettingsTile("Modo", "Claro", () {}),
              SettingsTile("Arquivos", "", () {}),
              SettingsTile("Lixo", "", () {}),
              SettingsTile("Privacidade", "", () {}),
              SettingsTile("Ajuda", "", () {}),
              SettingsTile("Sobre", "1.0.0", () {}),
              SettingsTile("Feedback", "", () {}),
            ],
          ),
        ),
      ),
    );
  }
}
