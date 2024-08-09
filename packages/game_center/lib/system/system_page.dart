import 'package:flutter/widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:yaru/yaru.dart';

class SystemPage extends StatelessWidget {
  const SystemPage({super.key});

  static IconData icon(bool selected) =>
      selected ? YaruIcons.computer_filled : YaruIcons.computer;
  static String label(BuildContext context) =>
      AppLocalizations.of(context).systemPageLabel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Center(
      child: Text(l10n.systemPageLabel),
    );
  }
}
