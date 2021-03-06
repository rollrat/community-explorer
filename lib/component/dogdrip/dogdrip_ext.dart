// This source code is a part of Project Violet.
// Copyright (C) 2020. rollrat. Licensed under the MIT License.

import 'dart:ui';

import 'package:charset_converter/charset_converter.dart';
import 'package:communityexplorer/component/dcinside/dcinside_parser.dart';
import 'package:communityexplorer/component/dogdrip/dogdrip_parser.dart';
import 'package:communityexplorer/component/huvkr/huvkr_parser.dart';
import 'package:communityexplorer/component/interface.dart';
import 'package:communityexplorer/download/download_task.dart';
import 'package:communityexplorer/network/wrapper.dart';
import 'package:flutter/material.dart';
import 'package:communityexplorer/network/wrapper.dart' as http;

class DogDripExtractor extends BoardExtractor {
  RegExp urlMatcher;

  DogDripExtractor() {
    urlMatcher =
        RegExp(r'^https://www.dogdrip.net/((\w+)(/\w+(/\d+))?|index\.php.*?)$');
  }

  @override
  bool acceptURL(String url) {
    return urlMatcher.stringMatch(url) == url;
  }

  @override
  Future<String> tidyURL(String url) async {
    return url;
  }

  @override
  Color color() {
    return Color(0xFF2e4361);
  }

  @override
  String fav() {
    return 'https://www.dogdrip.net/favicon.ico';
  }

  @override
  String extractor() {
    return 'dogdrip';
  }

  @override
  String name() {
    return '개드립';
  }

  @override
  String shortName() {
    return '개드립';
  }

  @override
  Future<PageInfo> next(BoardInfo board, int offset) async {
    // URL
    // 1. https://www.dogdrip.net/dogdrip
    // 2. https://www.dogdrip.net/?mid=dogdrip&sort_index=popular
    // 3. https://www.dogdrip.net/?mid=doc&category=18568364
    // 4. https://www.dogdrip.net/index.php?mid=dogdrip&page=1
    // 5. https://www.dogdrip.net/index.php?mid=dogdrip&sort_index=popular&page=2

    var query = Map<String, dynamic>.from(board.extrainfo);
    query['page'] = offset;

    var url = board.url +
        '?' +
        query.entries
            .map((e) =>
                '${e.key}=${Uri.encodeQueryComponent(e.value.toString())}')
            .join('&');

    var html = (await http.get(
      url,
      headers: {
        'Accept': HttpWrapper.accept,
        'User-Agent': HttpWrapper.userAgent,
      },
    ))
        .body;

    List<ArticleInfo> articles;

    articles = await DogDripParser.parseBoard(html);

    articles.forEach((element) {
      var uri = Uri.parse(element.url);
      var query = Map<String, String>.from(uri.queryParameters);
      query['page'] = '1';
      element.url = uri.replace(queryParameters: query).toString();
    });

    return PageInfo(
      articles: articles,
      board: board,
      offset: offset,
    );
  }

  @override
  List<BoardInfo> best() {
    return [
      BoardInfo(
        url: 'https://www.dogdrip.net/index.php',
        name: '개드립',
        extrainfo: {'mid': 'dogdrip', 'sort_index': 'popular'},
        extractor: 'dogdrip',
      ),
      BoardInfo(
        url: 'https://www.dogdrip.net/index.php',
        name: '유저 개드립',
        extrainfo: {'mid': 'userdog', 'sort_index': 'popular'},
        extractor: 'dogdrip',
      ),
    ];
  }

  @override
  String toMobile(String url) {
    return url;
  }

  @override
  Future<List<DownloadTask>> extractMedia(String url) async {}
}
