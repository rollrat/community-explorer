// This source code is a part of Project Violet.
// Copyright (C) 2020. rollrat. Licensed under the MIT License.

import 'package:communityexplorer/component/arcalive/arcalive_ext.dart';
import 'package:communityexplorer/component/dcinside/dcinside_ext.dart';
import 'package:communityexplorer/component/huvkr/huvkr_ext.dart';
import 'package:communityexplorer/component/interface.dart';

class ComponentManager {
  static ComponentManager instance = ComponentManager();

  List<BoardExtractor> _dl;

  ComponentManager() {
    _dl = [
      DCInsideExtractor(),
      HuvkrExtractor(),
      ArcaLiveExtractor(),
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
