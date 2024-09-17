import 'dart:io';

import 'package:game_center/util.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vdf/vdf.dart';
import 'package:watcher/watcher.dart';
import 'package:path/path.dart' as path;

part 'steam_model.g.dart';

const steamDataDir = '.steam/steam';

/// Steam's global settings
String steamGlobalConfig(String installLocation) {
  return '$installLocation/$steamDataDir/config/config.vdf';
}

/// Steam user settings *(not to be confused with the Linux user)*.
///
/// Most users of Steam will only have 1 account per Linux user. However, it is
/// possible to log in to multiple Steam accounts from a single Linux user.
String steamUserConfig(String installLocation, String userID) {
  return '$installLocation/$steamDataDir/userdata/$userID/config/localconfig.vdf';
}

typedef Config = ({
  Map<String, dynamic> globalConfig,
  Map<String, Map<String, dynamic>> userConfigs,
});

@riverpod
class SteamModel extends _$SteamModel {
  late String installLocation;
  late Map<String, dynamic> globalConfig;
  late Map<String, Map<String, dynamic>> userConfigs;

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
    userConfigs = new Map();
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

    return (
      globalConfig: globalConfig,
      userConfigs: userConfigs,
    );
  }

  Future<List<String>> listUserDirs() async {
    var userdata =
        await Directory('$installLocation/$steamDataDir/userdata').list();
    var directories =
        userdata.where((x) => x is Directory).map((x) => x as Directory);
    return directories.map((dir) => path.basename(dir.path)).toList();
  }

  Future<void> updateGlobalConfig() async {
    final file = File(steamGlobalConfig(installLocation));
    globalConfig = vdfDecode(await file.readAsString());
    state = AsyncData((
      globalConfig: globalConfig,
      userConfigs: userConfigs,
    ));
  }

  Future<void> updateUserConfig(String steamID) async {
    final file = File(steamUserConfig(installLocation, steamID));
    userConfigs[steamID] = vdfDecode(await file.readAsString());
    state = AsyncData((
      globalConfig: globalConfig,
      userConfigs: userConfigs,
    ));
  }

  /// Enable/disable Steam Play (Proton) for all titles globally. This is
  /// disabled by default on Steam for Linux, but enabled by default on Steam
  /// Deck.
  Future<void> enableSteamPlay({
    required bool enable,
    String? protonVersion,
  }) async {
    Map<String, dynamic> config = Map.from(globalConfig);
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
            '0'
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
            'CompatToolMapping'
          ],
          {},
        ),
      );
    }

    final file = File(steamGlobalConfig(installLocation));
    await file.writeAsString(vdf.encode(config));
  }

  /// Check if Steam Play is enabled in the global config.
  bool steamPlayEnabled() {
    Map<String, dynamic> config = Map.from(globalConfig);
    final key = config['InstallConfigStore']?['Software']?['Valve']?['Steam']
        ?['CompatToolMapping'];
    Map<String, dynamic> compat = Map.castFrom(key ?? new Map());
    return compat.containsKey('0') && compat['0'].isNotEmpty;
  }

  /// Get a map of installed Steam apps for the given user.
  Future<Map<String, dynamic>> listApps({required String steamID}) async {
    Map<String, dynamic> config = Map.from(userConfigs[steamID]!);
    var apps = config['UserLocalConfigStore']['Software']['Valve']['Steam']
        ['apps'] as Map;
    return apps.cast<String, dynamic>();
  }

  Future<String> getGameLaunchOptions({
    required String steamID,
    required String appID,
  }) async {
    Map<String, dynamic> config = Map.from(userConfigs[steamID]!);
    String launchOptions = config['UserLocalConfigStore']['Software']['Valve']
        ['Steam']['apps'][appID]['LaunchOptions'];
    return launchOptions;
  }

  /// Set the raw launch options for a specific app.
  Future<void> setGameLaunchOptions({
    required String steamID,
    required String appID,
    required String options,
  }) async {
    Map<String, dynamic> config = Map.from(userConfigs[steamID]!);
    config['UserLocalConfigStore']['Software']['Valve']['Steam']['apps'][appID]
        ['LaunchOptions'] = options;
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
    String launchOptions = await getGameLaunchOptions(
      steamID: steamID,
      appID: appID,
    );
    List<String> options =
        launchOptions.isEmpty ? [] : launchOptions.split(RegExp(r'\s+'));
    if (!options.contains(option)) {
      options.add(option);
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
    String launchOptions = await getGameLaunchOptions(
      steamID: steamID,
      appID: appID,
    );
    List<String> options =
        launchOptions.isEmpty ? [] : launchOptions.split(RegExp(r'\s+'));
    options.remove(option);
    print(options);
    await setGameLaunchOptions(
      steamID: steamID,
      appID: appID,
      options: options.join(' '),
    );
  }
}
