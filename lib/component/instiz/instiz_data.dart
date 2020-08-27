// This source code is a part of Project Violet.
// Copyright (C) 2020. rollrat. Licensed under the MIT License.

import 'package:communityexplorer/component/interface.dart';

class InstizData extends BoardData {
  @override
  bool accept(String name) {
    return ['인스티즈', 'instiz'].contains(name.replaceAll('.', ''));
  }

  @override
  List<BoardInfo> getLists() {
    return [
      BoardInfo(
        url: 'https://www.instiz.net/pt',
        name: '이슈',
        extrainfo: {},
        extractor: 'instiz',
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
