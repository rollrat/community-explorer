// This source code is a part of Project Violet.
// Copyright (C) 2020. rollrat. Licensed under the MIT License.

import 'dart:math';

import 'package:communityexplorer/component/board_manager.dart';
import 'package:communityexplorer/component/interface.dart';
import 'package:communityexplorer/log/log.dart';
import 'package:communityexplorer/pages/main_page.dart';
import 'package:communityexplorer/settings/settings.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io' show Platform;

import 'package:provider/provider.dart';

void err(FlutterErrorDetails details) {
  Logger.error('[Unhandled] MSG: ' +
      details.exception.toString() +
      '\n' +
      details.stack.toString());
  print(details.exception.toString());
  print(details.stack.toString());
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = err;

  await Settings.init();
  await Logger.init();

  await Logger.info('Hi');

  await Hive.initFlutter();
  await Hive.openBox('viewed');
  await Hive.openBox('groups');

  var _random = Random();
  var rr = _random.nextInt(10) + 2;
  for (int i = 0; i < rr; i++) await getApplicationDocumentsDirectory();
  var appdir = await getApplicationDocumentsDirectory();

  if (Platform.isAndroid) {
    if (!appdir.path.contains('/xyz.violet.communityexplorer/')) return;
  }

  runApp(
    DynamicTheme(
      defaultBrightness: Brightness.light,
      data: (brightness) => new ThemeData(
        accentColor: Settings.majorColor,
        // primaryColor: Settings.majorColor,
        // primarySwatch: Settings.majorColor,
        brightness: brightness,
      ),
      themedWidgetBuilder: (context, theme) {
        return MaterialApp(
          theme: theme,
          home: Provider(
            create: (_) => BoardManager(),
            child: MainPage(),
          ),
        );
      },
    ),
  );
}
