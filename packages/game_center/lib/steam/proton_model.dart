import 'dart:io';

import 'package:game_center/steam/steam_data.dart';
import 'package:path/path.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:watcher/watcher.dart';

part 'proton_model.g.dart';

@riverpod
class ProtonModel extends _$ProtonModel {
  late String installLocation;
  late List<String> protonVersions;

  Future<List<String>> build({String? install}) async {
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

    // directory isn't created by Steam by default, so ensure it exists
    final protonDir = Directory(protonDirectory(installLocation));
    protonDir.create(recursive: true);

    await updateProtonVersions();

    final fileSystem = FileWatcher(protonDirectory(installLocation));
    fileSystem.events.listen((event) async => await updateProtonVersions());

    return protonVersions;
  }

  Future<void> updateProtonVersions() async {
    final protonDir = Directory(protonDirectory(installLocation));
    final fileStream = await protonDir.list().toList();
    protonVersions = fileStream.map((x) => basename(x.path)).toList();

    state = AsyncData(protonVersions);
  }
}
