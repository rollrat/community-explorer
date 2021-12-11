// This source code is a part of Project Violet.
// Copyright (C) 2020. rollrat. Licensed under the MIT License.

import 'dart:ui';

import 'package:charset_converter/charset_converter.dart';
import 'package:communityexplorer/component/arcalive/arcalive_parser.dart';
import 'package:communityexplorer/component/clien/clien_parser.dart';
import 'package:communityexplorer/component/dcinside/dcinside_parser.dart';
import 'package:communityexplorer/component/fmkorea/fmkorea_parser.dart';
import 'package:communityexplorer/component/huvkr/huvkr_parser.dart';
import 'package:communityexplorer/component/interface.dart';
import 'package:communityexplorer/component/mlbpark/mlbpark_parser.dart';
import 'package:communityexplorer/download/download_task.dart';
import 'package:communityexplorer/network/wrapper.dart';
import 'package:flutter/material.dart';
import 'package:communityexplorer/network/wrapper.dart' as http;

class MLBParkExtractor extends BoardExtractor {
  RegExp urlMatcher;

  MLBParkExtractor() {
    urlMatcher = RegExp(r'^http://mlbpark.donga.com/mp/b.php?b=.*?$');
  }

  @override
  bool acceptURL(String url) {
    return urlMatcher.stringMatch(url) == url;
  }

  @override
  Future<String> tidyURL(String url) async {
    if (url.contains('?')) return url.split('?')[0];
    return url;
  }

  @override
  Color color() {
    return Color(0xFFFF5202);
  }

  @override
  String fav() {
    return 'http://mlbpark.donga.com/favicon.ico';
  }

  @override
  String extractor() {
    return 'mlbpark';
  }

  @override
  String name() {
    return 'MLBPARK';
  }

  @override
  String shortName() {
    return '엠팍';
  }

  @override
  Future<PageInfo> next(BoardInfo board, int offset) async {
    // URL
    // 1. https://www.fmkorea.com/index.php?mid=afreecatv&listStyle=webzine&page=1n
    // 2. https://www.fmkorea.com/index.php?mid=afreecatv&listStyle=list&page=1
    // 3. https://www.fmkorea.com/afreecatv

    var query = Map<String, dynamic>.from(board.extrainfo);
    query['page'] = offset * 30 + 1;

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

    articles = await MLBParkParser.parseBoard(html);

    articles.forEach((element) {
      var uri = Uri.parse(element.url);
      var query = Map<String, String>.from(uri.queryParameters);
      query['p'] = '1';
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
  String toMobile(String url) {
    return url;
  }

  @override
  Future<List<DownloadTask>> extractMedia(String url) async {}
}
