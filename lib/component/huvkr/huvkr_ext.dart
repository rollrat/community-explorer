// This source code is a part of Project Violet.
// Copyright (C) 2020. rollrat. Licensed under the MIT License.

import 'dart:ui';

import 'package:charset_converter/charset_converter.dart';
import 'package:communityexplorer/component/dcinside/dcinside_parser.dart';
import 'package:communityexplorer/component/huvkr/huvkr_parser.dart';
import 'package:communityexplorer/component/interface.dart';
import 'package:communityexplorer/download/download_task.dart';
import 'package:communityexplorer/network/wrapper.dart';
import 'package:flutter/material.dart';
import 'package:communityexplorer/network/wrapper.dart' as http;

class HuvkrExtractor extends BoardExtractor {
  RegExp urlMatcher;

  HuvkrExtractor() {
    urlMatcher =
        RegExp(r'^http://(m|web).humoruniv.com/board(/humor)?/list.html.*?$');
  }

  @override
  bool acceptURL(String url) {
    return urlMatcher.stringMatch(url) == url;
  }

  @override
  Future<String> tidyURL(String url) async {
    var urlMatcher =
        RegExp(r'^http://(m|web).humoruniv.com/board(/humor)?/list.html.*?$');
    var match = urlMatcher.allMatches(url);

    var ismobile = match.first[1] == 'm';
    if (ismobile) {
      url = 'http://web.humoruniv.com/board/humor/list.html?' +
          url.split('?').last;
    }

    return url;
  }

  @override
  Color color() {
    return Color(0xFFEE4E73);
  }

  @override
  String fav() {
    return 'http://web.humoruniv.com/favicon.ico';
  }

  @override
  String extractor() {
    return 'huvkr';
  }

  @override
  String name() {
    return '웃긴대학';
  }

  @override
  String shortName() {
    return '웃대';
  }

  @override
  Future<PageInfo> next(BoardInfo board, int offset) async {
    // URL
    // 1. http://web.humoruniv.com/board/humor/list.html?table=pds

    var query = Map<String, dynamic>.from(board.extrainfo);
    query['pg'] = offset;

    var url = board.url +
        '?' +
        query.entries
            .map((e) =>
                '${e.key}=${Uri.encodeQueryComponent(e.value.toString())}')
            .join('&');

    var html = await CharsetConverter.decode(
        'euc-kr',
        (await http.get(
          url,
          headers: {
            'Accept': HttpWrapper.accept,
            'User-Agent': HttpWrapper.userAgent,
          },
        ))
            .bodyBytes);

    List<ArticleInfo> articles;

    articles = await HuvkrParser.parseBoard(html);

    articles.forEach((element) {
      var uri = Uri.parse(element.url);
      var query = Map<String, String>.from(uri.queryParameters);
      query['pg'] = '0';
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
        url: 'http://web.humoruniv.com/board/humor/list.html',
        name: '웃긴자료',
        extrainfo: {'table': 'pds'},
        extractor: 'huvkr',
      ),
      BoardInfo(
        url: 'http://web.humoruniv.com/board/humor/list.html',
        name: '만화',
        extrainfo: {'table': 'thema2', 'st': 'day'},
        extractor: 'huvkr',
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
