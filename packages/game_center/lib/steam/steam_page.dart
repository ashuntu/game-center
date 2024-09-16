import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:game_center/layout.dart';
import 'package:game_center/steam/steam_model.dart';
import 'package:vdf/vdf.dart';
import 'package:yaru/yaru.dart';

class SteamPage extends ConsumerWidget {
  const SteamPage({super.key});

  static IconData icon(bool selected) =>
      selected ? YaruIcons.games_filled : YaruIcons.games;
  static String label(BuildContext context) =>
      AppLocalizations.of(context).steamPageLabel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final steam = ref.watch(steamModelProvider());

    return steam.when(
      data: (data) => AppScrollView(
        slivers: [
          SliverList.list(
            children: [
              Text(
                l10n.steamPageTitle,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: kPagePadding),
            ],
          ),
          _SteamSimpleSettings(),
          SliverList.list(
            children: [
              const SizedBox(height: kPagePadding),
              Text(
                l10n.steamGlobalConfigTitle,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: kPagePadding),
              _SteamGlobalConfigText(),
              const SizedBox(height: kPagePadding),
              Text(
                l10n.steamUserConfigTitle,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: kPagePadding),
              _SteamUserConfigs(),
            ],
          ),
        ],
      ),
      loading: () => Center(
        child: Text(l10n.loadingLabel),
      ),
      error: (error, stackTrace) => Center(
        child: Text(error.toString()),
      ),
    );
  }
}

class _SteamSimpleSettings extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final steam = ref.watch(steamModelProvider().notifier);
    final checked = steam.steamPlayEnabled();
    final l10n = AppLocalizations.of(context);

    return SliverList.list(children: [
      YaruSwitchListTile(
        title: Text(l10n.steamEnableProton),
        value: checked,
        onChanged: (value) async {
          await steam.enableSteamPlay(enable: value);
        },
      ),
    ]);
  }
}

class _SteamGlobalConfigText extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final steam = ref.watch(steamModelProvider());
    final controller = new TextEditingController();

    steam.whenData((data) async {
      controller.text = vdf.encode(data.globalConfig).replaceAll('\t', '    ');
    });

    return steam.when(
      data: (data) => TextField(
        controller: controller,
        readOnly: true,
        minLines: 16,
        maxLines: 16,
      ),
      error: (error, trace) => Center(
        child: Text(error.toString()),
      ),
      loading: () => Center(
        child: Text(l10n.loadingLabel),
      ),
    );
  }
}

class _SteamUserConfigs extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final steam = ref.watch(steamModelProvider());

    return steam.when(
      data: (data) => Column(
        children: [
          for (final userID in data.userConfigs.keys)
            _SteamUserConfigText(userID: userID)
        ],
      ),
      error: (error, trace) => Center(
        child: Text(error.toString()),
      ),
      loading: () => Center(
        child: Text(l10n.loadingLabel),
      ),
    );
  }
}

class _SteamUserConfigText extends ConsumerWidget {
  _SteamUserConfigText({required this.userID});

  final String userID;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final steam = ref.watch(steamModelProvider());
    final controller = new TextEditingController();

    steam.whenData((data) async {
      controller.text =
          vdf.encode(data.userConfigs[userID]!).replaceAll('\t', '    ');
    });

    return steam.when(
      data: (data) => TextField(
        controller: controller,
        readOnly: true,
        minLines: 16,
        maxLines: 16,
      ),
      error: (error, trace) => Center(
        child: Text(error.toString()),
      ),
      loading: () => Center(
        child: Text(l10n.loadingLabel),
      ),
    );
  }
}
