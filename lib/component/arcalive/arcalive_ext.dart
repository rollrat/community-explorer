// This source code is a part of Project Violet.
// Copyright (C) 2020. rollrat. Licensed under the MIT License.

import 'dart:convert';
import 'dart:ui';

import 'package:charset_converter/charset_converter.dart';
import 'package:communityexplorer/component/arcalive/arcalive_parser.dart';
import 'package:communityexplorer/component/dcinside/dcinside_parser.dart';
import 'package:communityexplorer/component/huvkr/huvkr_parser.dart';
import 'package:communityexplorer/component/interface.dart';
import 'package:communityexplorer/download/download_task.dart';
import 'package:communityexplorer/network/wrapper.dart';
import 'package:communityexplorer/other/utils.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ArcaLiveExtractor extends BoardExtractor {
  RegExp urlMatcher;

  ArcaLiveExtractor() {
    urlMatcher = RegExp(r'^https?://.*?arca.live/b/[^/]+$');
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
    return Color(0xFF373a3c);
  }

  @override
  String fav() {
    return 'https://arca.live/static/apple-icon.png';
  }

  @override
  String extractor() {
    return 'arcalive';
  }

  @override
  String name() {
    return '아카라이브';
  }

  @override
  Future<PageInfo> next(BoardInfo board, int offset) async {
    // URL
    // 1. https://arca.live/b/tullius?mode=best&p=2

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

    articles = await ArcaLiveParser.parseBoard(html);

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
        url: 'https://arca.live/b/issue',
        name: '유머/이슈 채널',
        extrainfo: {},
        extractor: 'arcalive',
      ),
    ];
  }

  @override
  String toMobile(String url) {
    return url;
  }

  @override
  Future<List<DownloadTask>> extractMedia(String url) async {
    var match = urlMatcher.allMatches(url);

    var result = List<DownloadTask>();

    var g = ArcaLiveParser.parseArticle((await HttpWrapper.getr(url)).body);

    for (int i = 0; i < g['links'].length; i++) {
      result.add(
        DownloadTask(
          url: g['links'][i],
          // filename: fn,
          referer: url,
          format: FileNameFormat(
            channel: g['channel'],
            title: g['title'],
            filenameWithoutExtension: Utils.intToString(i, pad: 3),
            extension: g['links'][i].split('?')[0].split('.').last,
            extractor: 'arcalive',
          ),
        ),
      );
    }

    return result;
  }
}
