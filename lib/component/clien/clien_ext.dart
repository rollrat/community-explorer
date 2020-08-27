// This source code is a part of Project Violet.
// Copyright (C) 2020. rollrat. Licensed under the MIT License.

import 'dart:ui';

import 'package:charset_converter/charset_converter.dart';
import 'package:communityexplorer/component/arcalive/arcalive_parser.dart';
import 'package:communityexplorer/component/clien/clien_parser.dart';
import 'package:communityexplorer/component/dcinside/dcinside_parser.dart';
import 'package:communityexplorer/component/huvkr/huvkr_parser.dart';
import 'package:communityexplorer/component/interface.dart';
import 'package:communityexplorer/download/download_task.dart';
import 'package:communityexplorer/network/wrapper.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ClienExtractor extends BoardExtractor {
  RegExp urlMatcher;

  ClienExtractor() {
    urlMatcher = RegExp(r'^https://www.clien.net/service/(board|group)/.*?$');
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
    return Color(0xFF232F3E);
  }

  @override
  String fav() {
    return 'https://www.clien.net/service/image/icon180x180.png';
  }

  @override
  String extractor() {
    return 'clien';
  }

  @override
  String name() {
    return '클리앙';
  }

  @override
  Future<PageInfo> next(BoardInfo board, int offset) async {
    // URL
    // 1. https://www.clien.net/service/group/clien_all?&od=T33
    // 2. https://www.clien.net/service/board/park
    // 3. https://www.clien.net/service/board/image
    // 4. https://www.clien.net/service/board/kin

    var qurey = Map<String, dynamic>.from(board.extrainfo);
    qurey['p'] = offset + 1;

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

    articles = await ClienParser.parseBoard(html);

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
        url: 'https://www.clien.net/service/group/clien_all',
        name: '톺아보기',
        extrainfo: {'od': 'T33'},
        extractor: 'clien',
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
