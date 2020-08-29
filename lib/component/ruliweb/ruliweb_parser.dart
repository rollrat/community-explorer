// This source code is a part of Project Violet.
// Copyright (C) 2020. rollrat. Licensed under the MIT License.

import 'package:communityexplorer/component/interface.dart';
import 'package:communityexplorer/other/html/parser.dart';
import 'package:communityexplorer/other/xpath_to_selector.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

class RuliwebParser {
  static Future<List<ArticleInfo>> parseBoard(String html) async {
    var doc = await compute(parse, html);
    var items = doc.querySelector('table.board_list_table > tbody');
    var result = List<ArticleInfo>();

    for (var item in items.querySelectorAll('tr')) {
      if (item.attributes['class'] != 'table_body') continue;

      var id = item.querySelector('/td[1]'.toquerySelector()).text.trim();
      var div = item.querySelector('/td[2]'.toquerySelector()).text.trim();
      var title =
          item.querySelector('/td[3]/div/a[1]'.toquerySelector()).text.trim();
      var com = 0;

      try {
        com = int.parse(item
            .querySelector('/td[3]/div/a[2]/span'.toquerySelector())
            .text
            .trim()
            .replaceAll('(', '')
            .replaceAll(')', ''));
      } catch (e) {}

      var writer = item.querySelector('/td[4]'.toquerySelector()).text.trim();
      var rt = item.querySelector('/td[5]'.toquerySelector()).text.trim();
      var recom = 0;
      if (rt != null && rt != '') recom = int.parse(rt);

      var hit =
          int.parse(item.querySelector('/td[6]'.toquerySelector()).text.trim());

      var dtt = item.querySelector('/td[7]'.toquerySelector()).text.trim();
      if (dtt.contains(':') && dtt.length <= 5)
        dtt = DateFormat('yyyy-MM-dd').format(DateTime.now()) + ' ' + dtt;
      else if (dtt.contains('.') && dtt.length <= 8)
        dtt = '20' + dtt.replaceAll('.', '-') + ' 00:00';
      var dt = DateTime.parse(dtt);

      var url = item
          .querySelector('/td[3]/div/a[1]'.toquerySelector())
          .attributes['href'];

      var hasImage = item.querySelector('i.icon-picture') != null;
      var hasVideo = item.querySelector('i.icon-youtube-play') != null;

      result.add(ArticleInfo(
        info: id,
        preface: div,
        title: title,
        comment: com,
        upvote: recom,
        nickname: writer,
        views: hit,
        writeTime: dt,
        url: url,
        hasImage: hasImage,
        hasVideo: hasVideo,
      ));
    }

    return result;
  }

  static Future<List<ArticleInfo>> parseSpecific(String html) async {
    var doc = await compute(parse, html);
    var items = doc.querySelector('table.board_list_table > tbody');
    var result = List<ArticleInfo>();

    for (var item in items.querySelectorAll('tr')) {
      var div = item.querySelector('/td[1]'.toquerySelector()).text.trim();
      var title =
          item.querySelector('/td[2]/a[1]'.toquerySelector()).text.trim();
      var com = 0;

      try {
        com = int.parse(item
            .querySelector('/td[2]/span'.toquerySelector())
            .text
            .trim()
            .replaceAll('(', '')
            .replaceAll(')', ''));
      } catch (e) {}

      var writer = item.querySelector('/td[3]'.toquerySelector()).text.trim();
      var rt = item.querySelector('/td[4]'.toquerySelector()).text.trim();
      var recom = 0;
      if (rt != null && rt != '') recom = int.parse(rt);

      var hit =
          int.parse(item.querySelector('/td[5]'.toquerySelector()).text.trim());
      var url = item
          .querySelector('/td[2]/a[1]'.toquerySelector())
          .attributes['href'];

      var dtt = item.querySelector('/td[6]'.toquerySelector()).text.trim();
      if (dtt.contains(':') && dtt.length <= 5)
        dtt = DateFormat('yyyy-MM-dd').format(DateTime.now()) + ' ' + dtt;
      else if (dtt.contains('.') && dtt.length <= 8)
        dtt = '20' + dtt.replaceAll('.', '-') + ' 00:00';
      var dt = DateTime.parse(dtt);

      var hasImage = item.querySelector('i.icon-picture') != null;
      var hasVideo = item.querySelector('i.icon-youtube-play') != null;

      result.add(ArticleInfo(
        info: url.split('/').last,
        preface: div,
        title: title,
        comment: com,
        upvote: recom,
        nickname: writer,
        views: hit,
        writeTime: dt,
        url: url,
        hasImage: hasImage,
        hasVideo: hasVideo,
      ));
    }

    return result;
  }

  static Future<List<ArticleInfo>> parseComic(String html) async {
    var doc = await compute(parse, html);
    var items =
        doc.querySelector('table.board_list_table > tbody > div.flex_wrapper');
    var result = List<ArticleInfo>();

    for (var item in items.querySelectorAll('tr')) {
      // if (item.attributes['class'] != 'table_body') continue;

      // var div = item.querySelector('/td[1]'.toquerySelector()).text.trim();
      // var title =
      //     item.querySelector('/td[2]/div/a[1]'.toquerySelector()).text.trim();
      // var com = 0;

      // try {
      //   com = int.parse(item.querySelector('/td[2]/div/a[2]/span').text.trim());
      // } catch (e) {}

      // var writer = item.querySelector('/td[3]').text.trim();
      // var rt = item.querySelector('/td[4]').text.trim();
      // var recom = 0;
      // if (rt != null && rt != '') recom = int.parse(rt);

      // var hit = int.parse(item.querySelector('/td[5]').text.trim());
      // var dt = DateTime.parse(item.querySelector('/td[6]').text.trim());

      // var url = item
      //     .querySelector('/td[2]/div/a[1]'.toquerySelector())
      //     .attributes['href'];

      // result.add(ArticleInfo(
      //   info: url.split('/').last,
      //   preface: div,
      //   title: title,
      //   comment: com,
      //   upvote: recom,
      //   nickname: writer,
      //   views: hit,
      //   writeTime: dt,
      //   url: url,
      // ));
    }

    return result;
  }

  static Map<String, dynamic> parseArticle(String html) {
    var doc = parse(html);

    var title = doc
        .querySelector(
            '/html[1]/body[1]/div[1]/div[1]/div[2]/div[3]/div[1]/div[1]/div[2]/div[1]/div[2]/div[1]/div[1]/div[1]/h4[1]/span[1]'
                .toquerySelector())
        .text
        .trim();
    var board = doc
        .querySelector(
            '/html[1]/body[1]/div[1]/div[1]/div[2]/div[3]/div[1]/div[1]/div[1]/div[1]/div[1]/div[1]/h3[1]/a[1]'
                .toquerySelector())
        .text
        .trim();
    var body = doc.querySelector(
        '/html[1]/body[1]/div[1]/div[1]/div[2]/div[3]/div[1]/div[1]/div[2]/div[1]/div[2]/div[2]'
            .toquerySelector());

    var links = List<String>();

    var imgs = body.querySelectorAll('img');
    var videos = body.querySelectorAll('video');

    try {
      if (imgs != null) {
        links.addAll(imgs.map((e) => 'https:' + e.attributes['src']));
      }
      if (videos != null) {
        links.addAll(videos.map((e) {
          return 'https:' + e.attributes['src'];
        }));
      }
    } catch (e) {
      // print(e);
    }

    return {
      'board': board,
      'title': title,
      'links': links,
    };
  }
}
