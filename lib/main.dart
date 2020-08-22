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
import 'package:path_provider/path_provider.dart';
import 'dart:io' show Platform;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Settings.init();
  await Logger.init();

  var _random = Random();
  var rr = _random.nextInt(10) + 2;
  for (int i = 0; i < rr; i++) await getApplicationDocumentsDirectory();
  var appdir = await getApplicationDocumentsDirectory();

  if (Platform.isAndroid) {
    if (!appdir.path.contains('/xyz.violet.communityexplorer/')) return;
  }

  BoardManager.test();

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
          home: MainPage(),
        );
      },
    ),
  );
}
