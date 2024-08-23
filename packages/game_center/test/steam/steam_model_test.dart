import 'package:flutter_test/flutter_test.dart';
import 'package:game_center/steam/steam_model.dart';

import 'test_utils.dart';

void main() {
  test('build', () async {
    final container = createContainer();
    final provider = steamModelProvider();
    final buildResult = await container.read(provider.future);

    expect(buildResult.globalConfig, isNotEmpty);
    expect(buildResult.userConfigs, isNotEmpty);
  });

  test('list users', () async {
    final container = createContainer();
    final model = container.read(steamModelProvider().notifier);
    await container.read(steamModelProvider().future);

    expect(await model.listUserDirs(), isNotEmpty);
  });

  test('enable Steam Play', () async {
    final container = createContainer();
    final model = container.read(steamModelProvider().notifier);
    await container.read(steamModelProvider().future);

    model.enableSteamPlay(enable: false);
    expect(
      model.globalConfig['InstallConfigStore']['Software']['Valve']['Steam']
          ['CompatToolMapping'],
      isEmpty,
    );

    model.enableSteamPlay(enable: true);
    expect(
      model.globalConfig['InstallConfigStore']['Software']['Valve']['Steam']
          ['CompatToolMapping'],
      isNotEmpty,
    );
    expect(
      model.globalConfig['InstallConfigStore']['Software']['Valve']['Steam']
          ['CompatToolMapping']['0'],
      isNotEmpty,
    );
  });

  test('list apps', () async {
    final container = createContainer();
    final model = container.read(steamModelProvider().notifier);
    await container.read(steamModelProvider().future);

    final users = await model.listUserDirs();
    for (final user in users) {
      final apps = await model.listApps(steamID: user);
      expect(apps, isNotEmpty);
    }
  });

  test('set launch options', () async {
    final container = createContainer();
    final model = container.read(steamModelProvider().notifier);
    await container.read(steamModelProvider().future);

    final users = await model.listUserDirs();
    for (final user in users) {
      final apps = await model.listApps(steamID: user);
      model.setGameLaunchOptions(
        steamID: user,
        appID: apps.keys.toList()[0],
        options: '%command%',
      );
      expect(
        model.userConfigs[user]!['UserLocalConfigStore']['Software']['Valve']
            ['Steam']['apps'][apps.keys.toList()[0]]['LaunchOptions'],
        equals('%command%'),
      );
    }
  });
}
