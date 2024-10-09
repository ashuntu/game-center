import 'dart:io';

import 'package:game_center/steam/steam_data.dart';
import 'package:game_center/util.dart';
import 'package:path/path.dart' as path;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vdf/vdf.dart';
import 'package:watcher/watcher.dart';

part 'steam_model.g.dart';

typedef Config = ({
  Map<String, dynamic> globalConfig,
  Map<String, Map<String, dynamic>> userConfigs,
  SteamUser activeUser,
});

class SteamUser {
  SteamUser({
    required this.id,
    required this.name,
  });

  factory SteamUser.fromConfig(Map<String, dynamic> config) {
    final id = config['UserLocalConfigStore']['friends'].keys.first;
    return SteamUser(
      id: id as String,
      name: config['UserLocalConfigStore']['friends'][id]['NameHistory']['0']
          as String,
    );
  }

  late final String id;
  late final String name;
}

@riverpod
class SteamModel extends _$SteamModel {
  late String installLocation;
  late Map<String, dynamic> globalConfig;
  late Map<String, Map<String, dynamic>> userConfigs;
  late SteamUser activeUser;

  @override
  Future<Config> build({String? install}) async {
    // default install location
    if (install == null) {
      final home = Platform.environment['SNAP_REAL_HOME'] ??
          Platform.environment['HOME'];
      if (home == null) {
        throw StateError('Home directory not found.');
      }
      install = '$home/snap/steam/common';
    }

    installLocation = install;

    // global config
    final file = File(steamGlobalConfig(installLocation));
    globalConfig = vdfDecode(await file.readAsString());

    final fileSystem = FileWatcher(steamGlobalConfig(installLocation));
    fileSystem.events.listen((event) async {
      switch (event.type) {
        case ChangeType.MODIFY:
          await updateGlobalConfig();
      }
    });

    // user configs
    final users = await listUserDirs();
    userConfigs = {};
    for (final steamID in users) {
      final file = File(steamUserConfig(installLocation, steamID));
      userConfigs[steamID] = vdfDecode(await file.readAsString());

      final fileSystem = FileWatcher(steamUserConfig(installLocation, steamID));
      fileSystem.events.listen((event) async {
        switch (event.type) {
          case ChangeType.MODIFY:
            await updateUserConfig(steamID);
        }
      });
    }

    activeUser = SteamUser.fromConfig(userConfigs.values.first);

    return (
      globalConfig: globalConfig,
      userConfigs: userConfigs,
      activeUser: activeUser,
    );
  }

  Future<List<String>> listUserDirs() async {
    final userdata =
        Directory('$installLocation/$steamDataDir/userdata').list();
    final directories =
        userdata.where((x) => x is Directory).map((x) => x as Directory);
    return directories.map((dir) => path.basename(dir.path)).toList();
  }

  Future<void> updateGlobalConfig() async {
    final file = File(steamGlobalConfig(installLocation));
    globalConfig = vdfDecode(await file.readAsString());
    state = AsyncData(
      (
        globalConfig: globalConfig,
        userConfigs: userConfigs,
        activeUser: activeUser,
      ),
    );
  }

  Future<void> updateUserConfig(String steamID) async {
    final file = File(steamUserConfig(installLocation, steamID));
    userConfigs[steamID] = vdfDecode(await file.readAsString());
    state = AsyncData(
      (
        globalConfig: globalConfig,
        userConfigs: userConfigs,
        activeUser: activeUser,
      ),
    );
  }

  Future<void> setActiveUser(String newActiveUserID) async {
    activeUser = SteamUser.fromConfig(userConfigs[newActiveUserID]!);
    state = AsyncData(
      (
        globalConfig: globalConfig,
        userConfigs: userConfigs,
        activeUser: activeUser,
      ),
    );
  }

  /// Enable/disable Steam Play (Proton) for all titles globally. This is
  /// disabled by default on Steam for Linux, but enabled by default on Steam
  /// Deck.
  Future<void> enableSteamPlay({
    required bool enable,
    String? protonVersion,
  }) async {
    var config = Map<String, dynamic>.from(globalConfig);
    if (enable) {
      config = Map.castFrom(
        safePut(
          config,
          [
            'InstallConfigStore',
            'Software',
            'Valve',
            'Steam',
            'CompatToolMapping',
            '0',
          ],
          {
            'name': protonVersion ?? 'proton_experimental',
            'config': '',
            'priority': '75',
          },
        ),
      );
    } else {
      config = Map.castFrom(
        safePut(
          config,
          [
            'InstallConfigStore',
            'Software',
            'Valve',
            'Steam',
            'CompatToolMapping',
          ],
          {},
        ),
      );
    }

    final file = File(steamGlobalConfig(installLocation));
    await file.writeAsString(vdf.encode(config));
    await updateGlobalConfig();
  }

  /// Check if Steam Play is enabled in the global config.
  bool steamPlayEnabled() {
    final config = Map.from(globalConfig);
    final key = config['InstallConfigStore']?['Software']?['Valve']?['Steam']
        ?['CompatToolMapping'];
    final compat = Map.castFrom(key != null ? key as Map : {});
    return compat.containsKey('0') && (compat['0'] as Map).isNotEmpty;
  }

  /// Get a map of installed Steam apps for the given user.
  Map<String, dynamic> listApps({required String steamID}) {
    final config = Map.from(userConfigs[steamID]!);
    final apps = config['UserLocalConfigStore']['Software']['Valve']['Steam']
        ['apps'] as Map;
    return apps.cast<String, dynamic>();
  }

  bool allGamesHaveOption({
    required String steamID,
    required String option,
  }) {
    final apps = listApps(steamID: steamID);
    for (final app in apps.keys) {
      final launchOptions = getGameLaunchOptions(steamID: steamID, appID: app);
      final options =
          launchOptions.isEmpty ? [] : launchOptions.split(RegExp(r'\s+'));
      if (!options.contains(option)) {
        return false;
      }
    }

    return true;
  }

  String getGameLaunchOptions({
    required String steamID,
    required String appID,
  }) {
    final config = Map.from(userConfigs[steamID]!);
    final launchOptions = config['UserLocalConfigStore']['Software']['Valve']
        ['Steam']['apps'][appID]['LaunchOptions'] as String?;
    return launchOptions ?? '';
  }

  /// Set the raw launch options for a specific app.checked
  Future<void> setGameLaunchOptions({
    required String steamID,
    required String appID,
    required String options,
  }) async {
    final config = Map<String, dynamic>.from(userConfigs[steamID]!);
    config['UserLocalConfigStore']['Software']['Valve']['Steam']['apps'][appID]
        ['LaunchOptions'] = options;
    final file = File(steamUserConfig(installLocation, steamID));
    await file.writeAsString(vdf.encode(config));
    await updateUserConfig(steamID);
  }

  Future<void> addAllGameLaunchOption({
    required String steamID,
    required String option,
  }) async {
    final config = Map<String, dynamic>.from(userConfigs[steamID]!);
    final apps = listApps(steamID: steamID);
    for (final app in apps.keys) {
      final launchOptions = getGameLaunchOptions(
        steamID: steamID,
        appID: app,
      );
      final options =
          launchOptions.isEmpty ? [] : launchOptions.split(RegExp(r'\s+'));
      if (!options.contains(option)) {
        options.insert(0, option);
      }
      if (!options.contains('%command%')) {
        options.add('%command%');
      }

      config['UserLocalConfigStore']['Software']['Valve']['Steam']['apps'][app]
          ['LaunchOptions'] = options.join(' ');
    }

    final file = File(steamUserConfig(installLocation, steamID));
    await file.writeAsString(vdf.encode(config));
    await updateUserConfig(steamID);
  }

  Future<void> removeAllGameLaunchOption({
    required String steamID,
    required String option,
  }) async {
    final config = Map<String, dynamic>.from(userConfigs[steamID]!);
    final apps = listApps(steamID: steamID);
    for (final app in apps.keys) {
      final launchOptions = getGameLaunchOptions(
        steamID: steamID,
        appID: app,
      );
      final options =
          launchOptions.isEmpty ? [] : launchOptions.split(RegExp(r'\s+'));
      options.remove(option);
      config['UserLocalConfigStore']['Software']['Valve']['Steam']['apps'][app]
          ['LaunchOptions'] = options.join(' ');
    }

    final file = File(steamUserConfig(installLocation, steamID));
    await file.writeAsString(vdf.encode(config));
    await updateUserConfig(steamID);
  }

  // Adds an option to a game's launch options. This function does nothing if
  // the option already exists for the game.
  Future<void> addGameLaunchOption({
    required String steamID,
    required String appID,
    required String option,
  }) async {
    final launchOptions = getGameLaunchOptions(
      steamID: steamID,
      appID: appID,
    );
    final options =
        launchOptions.isEmpty ? [] : launchOptions.split(RegExp(r'\s+'));
    if (!options.contains(option)) {
      options.insert(0, option);
    }
    if (!options.contains('%command%')) {
      options.add('%command%');
    }
    await setGameLaunchOptions(
      steamID: steamID,
      appID: appID,
      options: options.join(' '),
    );
  }

  // Removes an option from a game's launch options. This function does nothing
  // if the option is not present.
  Future<void> removeGameLaunchOption({
    required String steamID,
    required String appID,
    required String option,
  }) async {
    final launchOptions = getGameLaunchOptions(
      steamID: steamID,
      appID: appID,
    );
    final options =
        launchOptions.isEmpty ? [] : launchOptions.split(RegExp(r'\s+'));
    options.remove(option);
    await setGameLaunchOptions(
      steamID: steamID,
      appID: appID,
      options: options.join(' '),
    );
  }
}
