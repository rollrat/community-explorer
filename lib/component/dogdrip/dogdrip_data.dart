// This source code is a part of Project Violet.
// Copyright (C) 2020. rollrat. Licensed under the MIT License.

import 'package:communityexplorer/component/interface.dart';
import 'package:communityexplorer/other/html/parser.dart';
import 'package:flutter/foundation.dart';

class DogDripData extends BoardData {
  @override
  bool accept(String name) {
    return ['개드립', 'dogdrip'].contains(name.replaceAll('.', ''));
  }

  @override
  List<BoardInfo> getLists() {
    // return [
    //   BoardInfo(
    //     url: 'https://www.dogdrip.net/index.php',
    //     name: '개드립',
    //     extrainfo: {'mid': 'dogdrip', 'sort_index': 'popular'},
    //     extractor: 'dogdrip',
    //   ),
    //   BoardInfo(
    //     url: 'https://www.dogdrip.net/index.php',
    //     name: '유저 개드립',
    //     extrainfo: {'mid': 'userdog', 'sort_index': 'popular'},
    //     extractor: 'dogdrip',
    //   ),
    // ];

    return [
      '개드립|dogdrip',
      '유저 개드립|userdog',
      '붐업 베스트|boomupbest',
      //
      '읽을 거리 판|doc',
      //
      '주식 판|stock',
      '인터넷 방송 판|ib',
      '탈것 판|vehicle',
      '익명 판|free',
      '컴퓨터/IT 판|computer',
      '영상 판|movie',
      '고민 상담 판|consultation',
      '스포츠 판|sports',
      '요리 판|cook',
      '덕후 판|duck',
      '창작 판|creation',
      '음악 판|music',
      '정치 사회 판|politics',
      '젠더 이슈 판|genderissue',
      //
      '리그 오브 레전드 판|lol',
      '게임 연재/정보 판|gameserial',
      '게임 판|game',
      '콘솔 게임 판|console',
      '모바일 게임 판|mobilegame',
      '로스트아크|lostark',
      '던전 앤 파이터|df',
      //
      '걸그룹 판|girlgroup',
      '짤빵 판|pic',
    ]
        .map((e) => BoardInfo(
              url: 'https://www.dogdrip.net/index.php',
              name: e.split('|').first,
              extrainfo: {'mid': e.split('|').last},
              extractor: 'dogdrip',
            ))
        .toList();
  }

  @override
  List<String> searchs() {
    return null;
  }

  @override
  BoardInfo getBoardFromName(String name) {}

  @override
  List<String> extraOptions() {
    return ['인기글|1|sort_index|popular'];
  }

  @override
  Future<bool> supportClass(String html) async {
    return (await compute(parse, html))
            .querySelector('div.ed.category.category-pill') !=
        null;
  }

  @override
  Future<List<String>> getClasses(String html) async {
    var doc = (await compute(parse, html))
        .querySelector('div.ed.category.category-pill')
        .querySelectorAll('a');

    return doc.map((e) {
      if (!e.attributes['href'].contains('/category/'))
        return '${e.text.trim()}|category|';
      return '${e.text.trim()}|category|${e.attributes['href'].split('/').last}';
    }).toList();
  }
}
