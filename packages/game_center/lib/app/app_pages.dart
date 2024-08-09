import 'package:flutter/widgets.dart';
import 'package:game_center/about/about_page.dart';
import 'package:game_center/launcher/launcher_page.dart';
import 'package:game_center/settings/settings_page.dart';
import 'package:game_center/steam/steam_page.dart';
import 'package:game_center/system/system_page.dart';
import 'package:yaru/yaru.dart';

typedef AppPage = ({
  Widget Function(BuildContext context, bool selected) titleBuilder,
  WidgetBuilder pageBuilder,
});

final pages = <AppPage>[
  (
    titleBuilder: (context, selected) => YaruMasterTile(
          leading: Icon(LauncherPage.icon(selected)),
          title: Text(LauncherPage.label(context)),
        ),
    pageBuilder: (_) => const YaruDetailPage(
          body: LauncherPage(),
        ),
  ),
  (
    titleBuilder: (context, selected) => YaruMasterTile(
          leading: Icon(SteamPage.icon(selected)),
          title: Text(SteamPage.label(context)),
        ),
    pageBuilder: (_) => const YaruDetailPage(
          body: SteamPage(),
        ),
  ),
  (
    titleBuilder: (context, selected) => YaruMasterTile(
          leading: Icon(SystemPage.icon(selected)),
          title: Text(SystemPage.label(context)),
        ),
    pageBuilder: (_) => const YaruDetailPage(
          body: SystemPage(),
        ),
  ),
  (
    titleBuilder: (context, selected) => YaruMasterTile(
          leading: Icon(SettingsPage.icon(selected)),
          title: Text(SettingsPage.label(context)),
        ),
    pageBuilder: (_) => const YaruDetailPage(
          body: SettingsPage(),
        ),
  ),
  (
    titleBuilder: (context, selected) => YaruMasterTile(
          leading: Icon(AboutPage.icon(selected)),
          title: Text(AboutPage.label(context)),
        ),
    pageBuilder: (_) => const YaruDetailPage(
          body: AboutPage(),
        ),
  ),
];
