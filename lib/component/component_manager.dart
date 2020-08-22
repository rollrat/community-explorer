// This source code is a part of Project Violet.
// Copyright (C) 2020. rollrat. Licensed under the MIT License.

import 'package:communityexplorer/component/arcalive/arcalive_ext.dart';
import 'package:communityexplorer/component/clien/clien_ext.dart';
import 'package:communityexplorer/component/dcinside/dcinside_ext.dart';
import 'package:communityexplorer/component/huvkr/huvkr_ext.dart';
import 'package:communityexplorer/component/interface.dart';
import 'package:communityexplorer/component/ruliweb/ruliweb_ext.dart';

class ComponentManager {
  static ComponentManager instance = ComponentManager();

  List<BoardExtractor> _dl;

  ComponentManager() {
    _dl = [
      DCInsideExtractor(),
      HuvkrExtractor(),
      ArcaLiveExtractor(),
      RuliwebExtractor(),
      ClienExtractor(),
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
}
