import 'package:flutter/widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:yaru/yaru.dart';

class SteamPage extends StatelessWidget {
  const SteamPage({super.key});

  static IconData icon(bool selected) =>
      selected ? YaruIcons.games_filled : YaruIcons.games;
  static String label(BuildContext context) =>
      AppLocalizations.of(context).steamPageLabel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Center(
      child: Text(l10n.steamPageLabel),
    );
  }
}
