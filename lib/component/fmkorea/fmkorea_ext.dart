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
import 'package:communityexplorer/download/download_task.dart';
import 'package:communityexplorer/network/wrapper.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class FMKoreaExtractor extends BoardExtractor {
  RegExp urlMatcher;

  FMKoreaExtractor() {
    urlMatcher = RegExp(
        r'^https://www.fmkorea.com/index.php?mid=\w+&listStyle=webzine.*?$');
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
    return Color(0xFF456BC1);
  }

  @override
  String fav() {
    return 'https://image.fmkorea.com/touchicon/logo152.png';
  }

  @override
  String extractor() {
    return 'fmkorea';
  }

  @override
  String name() {
    return '에펨코리아';
  }

  @override
  String shortName() {
    return '펨코';
  }

  @override
  Future<PageInfo> next(BoardInfo board, int offset) async {
    // URL
    // 1. https://www.fmkorea.com/index.php?mid=afreecatv&listStyle=webzine&page=1n
    // 2. https://www.fmkorea.com/index.php?mid=afreecatv&listStyle=list&page=1
    // 3. https://www.fmkorea.com/afreecatv

    var query = Map<String, dynamic>.from(board.extrainfo);
    query['page'] = offset + 1;

    var url = board.url +
        '?' +
        query.entries
            .map((e) =>
                '${e.key}=${Uri.encodeQueryComponent(e.value.toString())}')
            .join('&');

    var html = (await HttpWrapper.getr(
      url,
      headers: {
        'Accept': HttpWrapper.accept,
        'User-Agent': HttpWrapper.userAgent,
      },
    ))
        .body;

    List<ArticleInfo> articles;

    articles = await FMKoreaParser.parseThumbnailView(html);

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
  String toMobile(String url) {
    return url;
  }

  @override
  Future<List<DownloadTask>> extractMedia(String url) async {}
}
