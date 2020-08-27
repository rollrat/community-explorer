// This source code is a part of Project Violet.
// Copyright (C) 2020. rollrat. Licensed under the MIT License.

import 'package:communityexplorer/component/interface.dart';

class HuvkrData extends BoardData {
  @override
  bool accept(String name) {
    return ['웃대', '웃긴대학', 'huvkr'].contains(name.replaceAll('.', ''));
  }

  @override
  List<BoardInfo> getLists() {
    return [
      BoardInfo(
        url: 'http://web.humoruniv.com/board/humor/list.html',
        name: '웃긴자료',
        extrainfo: {'table': 'pds'},
        extractor: 'huvkr',
      )
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
