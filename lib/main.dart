// This source code is a part of Project Violet.
// Copyright (C) 2020. rollrat. Licensed under the MIT License.

import 'package:communityexplorer/pages/main_page.dart';
import 'package:communityexplorer/settings/settings.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Settings.init();

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
