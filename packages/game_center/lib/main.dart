import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:game_center/app/app.dart';
import 'package:ubuntu_localizations/ubuntu_localizations.dart';
import 'package:yaru/yaru.dart';

Future<void> main() async {
  await initDefaultLocale();
  await YaruWindowTitleBar.ensureInitialized();

  runApp(
    const ProviderScope(
      child: App(),
    ),
  );
}
