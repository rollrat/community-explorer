// This source code is a part of Project Violet.
// Copyright (C) 2020. rollrat. Licensed under the MIT License.

import 'dart:convert';
import 'dart:math';

import 'package:communityexplorer/component/board_manager.dart';
import 'package:communityexplorer/component/dcinside/dcinside_data.dart';
import 'package:communityexplorer/component/fmkorea/fmkorea_parser.dart';
import 'package:communityexplorer/component/instiz/instiz_parser.dart';
import 'package:communityexplorer/component/interface.dart';
import 'package:communityexplorer/log/log.dart';
import 'package:communityexplorer/pages/fcm_test.dart';
import 'package:communityexplorer/pages/main_page.dart';
import 'package:communityexplorer/settings/settings.dart';
import 'package:crypto/crypto.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
// import 'package:firebase_admob/firebase_admob.dart';
// import 'package:firebase_analytics/firebase_analytics.dart';
// import 'package:firebase_analytics/observer.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io' show Platform;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// Crashlytics랑 연동하자.
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
  await Hive.openBox('scraps');
  await Hive.openBox('record');
  await Hive.openBox('filter');
  await Hive.openBox('fcm');

  var gg = await BoardManager.get('구독');

  runApp(
    DynamicTheme(
      defaultBrightness: Brightness.light,
      data: (brightness) => new ThemeData(
        accentColor: Settings.majorColor,
        // primaryColor: Settings.majorColor,
        // primarySwatch: Settings.majorColor,
        brightness: brightness,
        backgroundColor:
            brightness == Brightness.dark ? const Color(0xFF121212) : null,
      ),
      themedWidgetBuilder: (context, theme) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: theme,
          home: MainPage(gg, false, true),
        );
      },
    ),
  );
}
