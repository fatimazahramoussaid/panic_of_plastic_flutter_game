import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:panic_of_plastic/app_lifecycle/app_lifecycle.dart';
import 'package:panic_of_plastic/audio/audio.dart';
import 'package:panic_of_plastic/game_intro/game_intro.dart';
import 'package:panic_of_plastic/l10n/l10n.dart';
import 'package:panic_of_plastic/settings/settings.dart';
import 'package:panic_of_plastic/share/share.dart';

class App extends StatelessWidget {
  const App({
    required this.audioController,
    required this.settingsController,
    required this.shareController,
    this.isTesting = false,
    super.key,
  });

  final bool isTesting;
  final AudioController audioController;
  final SettingsController settingsController;
  final ShareController shareController;

  @override
  Widget build(BuildContext context) {
    return AppLifecycleObserver(
      child: MultiRepositoryProvider(
        providers: [
          RepositoryProvider<AudioController>(
            create: (context) {
              final lifecycleNotifier =
                  context.read<ValueNotifier<AppLifecycleState>>();
              return audioController
                ..attachLifecycleNotifier(lifecycleNotifier);
            },
            lazy: false,
          ),
          RepositoryProvider<SettingsController>.value(
            value: settingsController,
          ),
          RepositoryProvider<ShareController>.value(
            value: shareController,
          )
        ],
        child: MaterialApp(
          theme: ThemeData(
            textTheme: AppTextStyles.textTheme,
          ),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: const GameIntroPage(),
        ),
      ),
    );
  }
}
