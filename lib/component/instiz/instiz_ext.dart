// This source code is a part of Project Violet.
// Copyright (C) 2020. rollrat. Licensed under the MIT License.

import 'dart:ui';

import 'package:charset_converter/charset_converter.dart';
import 'package:communityexplorer/component/arcalive/arcalive_parser.dart';
import 'package:communityexplorer/component/clien/clien_parser.dart';
import 'package:communityexplorer/component/dcinside/dcinside_parser.dart';
import 'package:communityexplorer/component/fmkorea/fmkorea_parser.dart';
import 'package:communityexplorer/component/huvkr/huvkr_parser.dart';
import 'package:communityexplorer/component/instiz/instiz_parser.dart';
import 'package:communityexplorer/component/interface.dart';
import 'package:communityexplorer/component/mlbpark/mlbpark_parser.dart';
import 'package:communityexplorer/network/wrapper.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class InstizExtractor extends BoardExtractor {
  RegExp urlMatcher;

  InstizExtractor() {
    urlMatcher = RegExp(r'^https://www.instiz.net/.*?$');
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
    return Color(0xFF28C05E);
  }

  @override
  String fav() {
    return 'https://www.instiz.net/favicon.ico';
  }

  @override
  String extractor() {
    return 'instiz';
  }

  @override
  String name() {
    return '인스티즈';
  }

  @override
  Future<PageInfo> next(BoardInfo board, int offset) async {
    // URL
    // 1. https://www.instiz.net/pt?page=1

    var qurey = Map<String, dynamic>.from(board.extrainfo);
    qurey['page'] = offset + 1;

    var url = board.url +
        '?' +
        qurey.entries
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

    articles = await InstizParser.parseBoard(html);

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
        url: 'https://www.instiz.net/pt',
        name: '이슈',
        extrainfo: {},
        extractor: 'instiz',
      ),
    ];
  }

  @override
  String toMobile(String url) {
    return url;
  }
}
