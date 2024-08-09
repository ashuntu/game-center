import 'package:flutter/widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:yaru/yaru.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  static IconData icon(bool selected) =>
      selected ? YaruIcons.information_filled : YaruIcons.information;
  static String label(BuildContext context) =>
      AppLocalizations.of(context).aboutPageLabel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Center(
      child: Text(l10n.aboutPageLabel),
    );
  }
}
