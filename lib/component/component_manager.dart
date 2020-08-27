// This source code is a part of Project Violet.
// Copyright (C) 2020. rollrat. Licensed under the MIT License.

import 'package:communityexplorer/component/arcalive/arcalive_data.dart';
import 'package:communityexplorer/component/arcalive/arcalive_ext.dart';
import 'package:communityexplorer/component/clien/clien_data.dart';
import 'package:communityexplorer/component/clien/clien_ext.dart';
import 'package:communityexplorer/component/dcinside/dcinside_data.dart';
import 'package:communityexplorer/component/dcinside/dcinside_ext.dart';
import 'package:communityexplorer/component/fmkorea/fmkorea_data.dart';
import 'package:communityexplorer/component/fmkorea/fmkorea_ext.dart';
import 'package:communityexplorer/component/huvkr/huvkr_data.dart';
import 'package:communityexplorer/component/huvkr/huvkr_ext.dart';
import 'package:communityexplorer/component/instiz/instiz_data.dart';
import 'package:communityexplorer/component/instiz/instiz_ext.dart';
import 'package:communityexplorer/component/instiz/instiz_parser.dart';
import 'package:communityexplorer/component/interface.dart';
import 'package:communityexplorer/component/mlbpark/mlbpark_data.dart';
import 'package:communityexplorer/component/mlbpark/mlbpark_ext.dart';
import 'package:communityexplorer/component/ruliweb/ruliweb_data.dart';
import 'package:communityexplorer/component/ruliweb/ruliweb_ext.dart';

class ComponentManager {
  static ComponentManager instance = ComponentManager();

  List<BoardExtractor> _dl;
  List<BoardData> _dd;

  ComponentManager() {
    _dl = [
      DCInsideExtractor(),
      HuvkrExtractor(),
      ArcaLiveExtractor(),
      RuliwebExtractor(),
      ClienExtractor(),
      FMKoreaExtractor(),
      MLBParkExtractor(),
      InstizExtractor(),
    ];
    _dd = [
      DCInsideData(),
      HuvkrData(),
      ArcaLiveData(),
      RuliwebData(),
      ClienData(),
      FMKoreaData(),
      MLBParkData(),
      InstizData(),
    ];
  }

  bool existsExtractor(String url) {
    return _dl.any((element) => element.acceptURL(url));
  }

  BoardExtractor getExtractorByName(String name) {
    return _dl.firstWhere((element) => element.extractor() == name);
  }

  BoardExtractor getExtractor(String url) {
    return _dl.firstWhere((element) => element.acceptURL(url));
  }

  bool existsData(String name) {
    return _dd.any((e) => e.accept(name));
  }

  BoardData getDataFromName(String name) {
    return _dd.firstWhere((element) => element.accept(name));
  }
}
