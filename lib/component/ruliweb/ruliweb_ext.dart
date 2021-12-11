// This source code is a part of Project Violet.
// Copyright (C) 2020. rollrat. Licensed under the MIT License.

import 'dart:ui';

import 'package:charset_converter/charset_converter.dart';
import 'package:communityexplorer/component/dcinside/dcinside_parser.dart';
import 'package:communityexplorer/component/huvkr/huvkr_parser.dart';
import 'package:communityexplorer/component/interface.dart';
import 'package:communityexplorer/component/ruliweb/ruliweb_parser.dart';
import 'package:communityexplorer/download/download_task.dart';
import 'package:communityexplorer/network/wrapper.dart';
import 'package:communityexplorer/other/utils.dart';
import 'package:flutter/material.dart';
import 'package:communityexplorer/network/wrapper.dart' as http;

class RuliwebExtractor extends BoardExtractor {
  RegExp urlMatcher;

  RuliwebExtractor() {
    urlMatcher = RegExp(
        r'^https://(bbs|m).ruliweb.com/(community|best|family|ps|\w+)/(board|humor|political|\w+)/(\d+|now|hit).*?$');
  }

  @override
  bool acceptURL(String url) {
    return urlMatcher.stringMatch(url) == url;
  }

  @override
  Future<String> tidyURL(String url) async {
    var urlMatcher = RegExp(
        r'^http://(m|web).ruliweb.com/(community|best|family|ps|\w+)/(board|humor|political|\w+)/(\d+|now|hit).*?$');
    var match = urlMatcher.allMatches(url);

    var ismobile = match.first[1] == 'm';
    if (ismobile) {
      url = url.replaceAll('https://m.', 'https://bbs.');
    }

    return url;
  }

  @override
  Color color() {
    return Color(0xFF1F55BD);
  }

  @override
  String fav() {
    return 'https://img.ruliweb.com/img/2016/icon/ruliweb_icon_144_144.png';
  }

  @override
  String extractor() {
    return 'ruliweb';
  }

  @override
  String name() {
    return '루리웹';
  }

  @override
  String shortName() {
    return '루리';
  }

  @override
  Future<PageInfo> next(BoardInfo board, int offset) async {
    // URL
    // 1. https://bbs.ruliweb.com/best/cartoon/now?page=1
    // 2. https://bbs.ruliweb.com/community/board/300143?view_best=1
    // 3. https://bbs.ruliweb.com/hobby/board/300064

    var query = Map<String, dynamic>.from(board.extrainfo);
    query['page'] = offset + 1;

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

    if (board.url.startsWith('https://bbs.ruliweb.com/best/'))
      articles = await RuliwebParser.parseSpecific(html);
    else
      articles = await RuliwebParser.parseBoard(html);

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
        url: 'https://bbs.ruliweb.com/best/humor/hit',
        name: '유머 힛갤',
        extrainfo: {},
        extractor: 'ruliweb',
      ),
      BoardInfo(
        url: 'https://bbs.ruliweb.com/best/community/hit',
        name: '커뮤니티 힛갤',
        extrainfo: {},
        extractor: 'ruliweb',
      ),
    ];
  }

  @override
  String toMobile(String url) {
    return url.replaceAll('https://bbs.', 'https://m.');
  }

  @override
  Future<List<DownloadTask>> extractMedia(String url) async {
    var match = urlMatcher.allMatches(url);

    if (match.first[1] == 'm') url = url.replaceFirst('bbs.', 'm.');

    var result = List<DownloadTask>();

    var g = RuliwebParser.parseArticle((await http.get(url, headers: {
      'Referer': url,
      'User-Agent': HttpWrapper.userAgent,
      'Accept': HttpWrapper.accept,
    }))
        .body);

    for (int i = 0; i < g['links'].length; i++) {
      result.add(
        DownloadTask(
          url: g['links'][i],
          // filename: fn,
          referer: url.replaceAll('/img/', '/ori/'),
          format: FileNameFormat(
            board: g['board'],
            title: g['title'],
            filenameWithoutExtension: Utils.intToString(i, pad: 3),
            extension: g['links'][i].split('?')[0].split('.').last,
            extractor: 'ruliweb',
          ),
        ),
      );
    }

    return result;
  }
}
