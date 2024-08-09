import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:game_center/app/app_pages.dart';
import 'package:ubuntu_localizations/ubuntu_localizations.dart';
import 'package:yaru/yaru.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return YaruTheme(
      builder: (context, yaru, child) => MaterialApp(
        theme: yaru.theme,
        darkTheme: yaru.darkTheme,
        highContrastTheme: yaruHighContrastLight,
        highContrastDarkTheme: yaruHighContrastDark,
        localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
          ...AppLocalizations.localizationsDelegates,
          ...GlobalUbuntuLocalizations.delegates,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: const _AppFrame(),
      ),
    );
  }
}

class _AppFrame extends StatelessWidget {
  const _AppFrame();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    YaruWindow.of(context).setTitle(l10n.appTitle);

    return Scaffold(
      appBar: _TitleBar(
        title: Text(l10n.appTitle),
      ),
      body: YaruMasterDetailPage(
        length: pages.length,
        tileBuilder: (context, index, selected, availableWidth) =>
            pages[index].titleBuilder(context, selected),
        pageBuilder: (context, index) => pages[index].pageBuilder(context),
        layoutDelegate: const YaruMasterFixedPaneDelegate(
          paneWidth: 164,
        ),
      ),
    );
  }
}

class _TitleBar extends StatelessWidget implements PreferredSizeWidget {
  const _TitleBar({required this.title});

  final Widget title;

  @override
  Widget build(BuildContext context) {
    return YaruWindowTitleBar(
      title: title,
    );
  }

  @override
  Size get preferredSize => const Size(0, kYaruTitleBarHeight);
}
