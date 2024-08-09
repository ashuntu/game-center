import 'package:flutter/widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:yaru/yaru.dart';

class LauncherPage extends StatelessWidget {
  const LauncherPage({super.key});

  static IconData icon(bool selected) =>
      selected ? YaruIcons.folder_open_filled : YaruIcons.folder;
  static String label(BuildContext context) =>
      AppLocalizations.of(context).launcherPageLabel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Center(
      child: Text(l10n.launcherPageLabel),
    );
  }
}
