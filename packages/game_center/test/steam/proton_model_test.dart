import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:game_center/steam/proton_model.dart';

import 'test_utils.dart';

void main() {
  test('build', () async {
    final container = createContainer();
    final provider = protonModelProvider();
    await container.read(provider.future);
    final model = container.read(provider.notifier);

    final directory = Directory(model.installLocation);
    expect(await directory.exists(), isTrue);
  });
}
