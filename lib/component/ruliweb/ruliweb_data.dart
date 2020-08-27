// This source code is a part of Project Violet.
// Copyright (C) 2020. rollrat. Licensed under the MIT License.

import 'package:communityexplorer/component/interface.dart';

class RuliwebData extends BoardData {
  @override
  bool accept(String name) {
    return ['루리웹', 'ruliweb'].contains(name.replaceAll('.', ''));
  }

  @override
  List<BoardInfo> getLists() {
    return [
      BoardInfo(
        url: 'https://bbs.ruliweb.com/best/humor/hit',
        name: '유머 힛갤',
        extrainfo: {},
        extractor: 'ruliweb',
      ),
      BoardInfo(
        url: 'https://bbs.ruliweb.com/community/board/300148',
        name: '정치유머 게시판',
        extrainfo: {'view_best': '1'},
        extractor: 'ruliweb',
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
