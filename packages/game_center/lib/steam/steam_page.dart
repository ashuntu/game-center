import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:game_center/layout.dart';
import 'package:game_center/steam/proton_model.dart';
import 'package:game_center/steam/steam_model.dart';
import 'package:game_center/widgets/expandable_page_section.dart';
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
    final notifier = ref.watch(steamModelProvider().notifier);

    return steam.when(
      data: (data) => AppScrollView(
        children: [
          Text(
            l10n.steamPageTitle,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: kPagePadding),
          YaruPopupMenuButton(
            child: Text(data.activeUser.name),
            itemBuilder: (context) => data.userConfigs.values.map(
              (id) {
                final user = SteamUser.fromConfig(id);
                return PopupMenuItem(
                  child: Text(user.name),
                  onTap: () => notifier.setActiveUser(user.id),
                );
              },
            ).toList(),
          ),
          _SteamSimpleSettings(),
          const SizedBox(height: kPagePadding),
          ExpandablePageSection(
            title: l10n.advancedTitle,
            children: [
              Text(
                l10n.steamProtonTitle,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: kPagePadding),
              _SteamProtonVersions(),
              const SizedBox(height: kPagePadding),
              Text(
                l10n.steamConfigsTitle,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: kPagePadding),
              _SteamGlobalConfigText(),
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
        child: Text('$error\n$stackTrace'),
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

    return Column(
      children: [
        YaruSwitchListTile(
          title: Text(l10n.steamEnableProton),
          value: checked,
          onChanged: (value) async {
            await steam.enableSteamPlay(enable: value);
          },
        ),
        YaruSwitchListTile(
          title: Text(l10n.steamEnableMangoHUD),
          value: steam.allGamesHaveOption(
            steamID: steam.activeUser.id,
            option: 'mangohud',
          ),
          onChanged: (value) async {
            value
                ? await steam.addAllGameLaunchOption(
                    steamID: steam.activeUser.id,
                    option: 'mangohud',
                  )
                : await steam.removeAllGameLaunchOption(
                    steamID: steam.activeUser.id,
                    option: 'mangohud',
                  );
          },
        ),
        YaruSwitchListTile(
          title: Text(l10n.steamEnableGameMode),
          value: steam.allGamesHaveOption(
            steamID: steam.activeUser.id,
            option: 'gamemoderun',
          ),
          onChanged: (value) async {
            value
                ? await steam.addAllGameLaunchOption(
                    steamID: steam.activeUser.id,
                    option: 'gamemoderun',
                  )
                : await steam.removeAllGameLaunchOption(
                    steamID: steam.activeUser.id,
                    option: 'gamemoderun',
                  );
          },
        ),
      ],
    );
  }
}

class _SteamProtonVersions extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final proton = ref.watch(protonModelProvider());
    final notifier = ref.watch(protonModelProvider().notifier);

    return proton.when(
      data: (data) => Column(
        children: [
          if (data.isEmpty)
            Text(l10n.steamNoProtonVersions)
          else
            for (final version in data)
              YaruTile(
                title: Text(version.name),
                trailing: Flex(
                  direction: Axis.horizontal,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.folder),
                      tooltip: l10n.openLocation,
                      onPressed: () {
                        FilePicker.platform.pickFiles(
                          initialDirectory: version.path,
                          dialogTitle: version.name,
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      tooltip: l10n.delete,
                      onPressed: () {
                        notifier.deleteProtonVersion(version.path);
                      },
                    ),
                  ],
                ),
              ),
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

class _SteamGlobalConfigText extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final steam = ref.watch(steamModelProvider());
    final controller = TextEditingController();

    steam.whenData((data) async {
      controller.text = vdf.encode(data.globalConfig).replaceAll('\t', '    ');
    });

    return steam.when(
      data: (data) => YaruExpansionPanel(
        headers: [
          Text(l10n.steamGlobalConfigTitle),
        ],
        children: [
          TextField(
            controller: controller,
            readOnly: true,
            maxLines: 16,
            style: Theme.of(context).textTheme.bodyLarge?.toMono(),
          ),
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

class _SteamUserConfigs extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final steam = ref.watch(steamModelProvider());

    return steam.when(
      data: (data) => YaruExpansionPanel(
        headers: [
          for (final config in data.userConfigs.values)
            Text(l10n.steamUserConfigTitle(SteamUser.fromConfig(config).name)),
        ],
        children: [
          for (final userID in data.userConfigs.keys)
            _SteamUserConfigText(userID: userID),
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
  const _SteamUserConfigText({required this.userID});

  final String userID;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final steam = ref.watch(steamModelProvider());
    final controller = TextEditingController();

    steam.whenData((data) async {
      controller.text =
          vdf.encode(data.userConfigs[userID]!).replaceAll('\t', '    ');
    });

    return steam.when(
      data: (data) => TextField(
        controller: controller,
        readOnly: true,
        maxLines: 16,
        style: Theme.of(context).textTheme.bodyLarge?.toMono(),
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
