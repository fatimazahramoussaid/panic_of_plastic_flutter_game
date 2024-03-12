import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:panic_of_plastic/app/app.dart';
import 'package:panic_of_plastic/audio/audio.dart';
import 'package:panic_of_plastic/settings/persistence/persistence.dart';
import 'package:panic_of_plastic/settings/settings.dart';
import 'package:panic_of_plastic/share/share.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();


  final settings = SettingsController(
    persistence: LocalStorageSettingsPersistence(),
  );

  final audio = AudioController()..attachSettings(settings);

  await audio.initialize();

  final share = ShareController(
    gameUrl: 'https://endless-runner-9481713-383737.web.app/',
  );

  ;
  runApp(App(
          audioController: audio,
          settingsController: settings,
          shareController: share
        ));
}
