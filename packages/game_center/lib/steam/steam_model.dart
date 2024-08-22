import 'dart:io';

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
      final home = Platform.environment['HOME'];
      if (home == null) {
        throw StateError('\$HOME not found.');
      }
      install = '$home/snap/steam/common';
    }

    installLocation = install;

    // global config
    final fileSystem = FileWatcher(steamGlobalConfig(installLocation));
    fileSystem.events.listen((event) async {
      switch (event.type) {
        case ChangeType.MODIFY:
          await updateGlobalConfig();
      }
    });
    final file = File(steamGlobalConfig(installLocation));
    globalConfig = vdfDecode(await file.readAsString());

    // user configs
    final users = await listUserDirs();
    userConfigs = new Map();
    for (final steamID in users) {
      final fileSystem = FileWatcher(steamUserConfig(installLocation, steamID));
      fileSystem.events.listen((event) async {
        switch (event.type) {
          case ChangeType.MODIFY:
            await updateUserConfig(steamID);
        }
      });
      final file = File(steamUserConfig(installLocation, steamID));
      userConfigs[steamID] = vdfDecode(await file.readAsString());
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
}
