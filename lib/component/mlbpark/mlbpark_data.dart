// This source code is a part of Project Violet.
// Copyright (C) 2020. rollrat. Licensed under the MIT License.

import 'package:communityexplorer/component/interface.dart';

class MLBParkData extends BoardData {
  @override
  bool accept(String name) {
    return ['MLBPARK', '엠팍', '엠엘비파크', 'mlbpark']
        .contains(name.replaceAll('.', ''));
  }

  @override
  List<BoardInfo> getLists() {
    return [
      BoardInfo(
        url: 'http://mlbpark.donga.com/mp/b.php',
        name: 'MLB타운',
        extrainfo: {'b': 'mlbtown'},
        extractor: 'mlbpark',
      ),
      BoardInfo(
        url: 'http://mlbpark.donga.com/mp/b.php',
        name: '한국야구타운',
        extrainfo: {'b': 'kbotown'},
        extractor: 'mlbpark',
      ),
      BoardInfo(
        url: 'http://mlbpark.donga.com/mp/b.php',
        name: 'BULLPEN',
        extrainfo: {'b': 'bullpen'},
        extractor: 'mlbpark',
      ),
    ];
  }

  @override
  List<String> searchs() {
    return null;
  }

  @override
  BoardInfo getBoardFromName(String name) {}

  @override
  List<String> extraOptions() {
    return null;
  }

  @override
  Future<bool> supportClass(String html) async {
    return false;
  }

  @override
  Future<List<String>> getClasses(String html) async {}
}
