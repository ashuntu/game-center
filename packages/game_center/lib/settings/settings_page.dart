import 'package:flutter/widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:yaru/yaru.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  static IconData icon(bool selected) =>
      selected ? YaruIcons.settings_filled : YaruIcons.settings;
  static String label(BuildContext context) =>
      AppLocalizations.of(context).settingsPageLabel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Center(
      child: Text(l10n.settingsPageLabel),
    );
  }
}
