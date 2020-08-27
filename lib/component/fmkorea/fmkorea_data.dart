// This source code is a part of Project Violet.
// Copyright (C) 2020. rollrat. Licensed under the MIT License.

import 'package:communityexplorer/component/interface.dart';

class FMKoreaData extends BoardData {
  @override
  bool accept(String name) {
    return ['에펨코리아', '펨코', 'fmkorea'].contains(name.replaceAll('.', ''));
  }

  @override
  List<BoardInfo> getLists() {
    return [
      BoardInfo(
        url: 'https://www.fmkorea.com/index.php',
        name: '포텐 터짐',
        extrainfo: {'mid': 'best', 'listStyle': 'webzine'},
        extractor: 'fmkorea',
      ),
      BoardInfo(
        url: 'https://www.fmkorea.com/index.php',
        name: '유머/이슈/정보',
        extrainfo: {'mid': 'humor', 'listStyle': 'webzine'},
        extractor: 'fmkorea',
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
