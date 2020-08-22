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

      var id = item.querySelector('/td[1]'.toQureySelector()).text.trim();
      var div = item.querySelector('/td[2]'.toQureySelector()).text.trim();
      var title =
          item.querySelector('/td[3]/div/a[1]'.toQureySelector()).text.trim();
      var com = 0;

      try {
        com = int.parse(item
            .querySelector('/td[3]/div/a[2]/span'.toQureySelector())
            .text
            .trim()
            .replaceAll('(', '')
            .replaceAll(')', ''));
      } catch (e) {}

      var writer = item.querySelector('/td[4]'.toQureySelector()).text.trim();
      var rt = item.querySelector('/td[5]'.toQureySelector()).text.trim();
      var recom = 0;
      if (rt != null && rt != '') recom = int.parse(rt);

      var hit =
          int.parse(item.querySelector('/td[6]'.toQureySelector()).text.trim());

      var dtt = item.querySelector('/td[7]'.toQureySelector()).text.trim();
      if (dtt.contains(':') && dtt.length <= 5)
        dtt = DateFormat('yyyy-MM-dd ').format(DateTime.now()) + dtt;
      var dt = DateTime.parse(dtt);

      var url = item
          .querySelector('/td[3]/div/a[1]'.toQureySelector())
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
      var div = item.querySelector('/td[1]'.toQureySelector()).text.trim();
      var title =
          item.querySelector('/td[2]/a[1]'.toQureySelector()).text.trim();
      var com = 0;

      try {
        com = int.parse(item
            .querySelector('/td[2]/span'.toQureySelector())
            .text
            .trim()
            .replaceAll('(', '')
            .replaceAll(')', ''));
      } catch (e) {}

      var writer = item.querySelector('/td[3]'.toQureySelector()).text.trim();
      var rt = item.querySelector('/td[4]'.toQureySelector()).text.trim();
      var recom = 0;
      if (rt != null && rt != '') recom = int.parse(rt);

      var hit =
          int.parse(item.querySelector('/td[5]'.toQureySelector()).text.trim());
      var url = item
          .querySelector('/td[2]/a[1]'.toQureySelector())
          .attributes['href'];

      var dtt = item.querySelector('/td[6]'.toQureySelector()).text.trim();
      if (dtt.contains(':') && dtt.length <= 5)
        dtt = DateFormat('yyyy-MM-dd ').format(DateTime.now()) + dtt;
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

      // var div = item.querySelector('/td[1]'.toQureySelector()).text.trim();
      // var title =
      //     item.querySelector('/td[2]/div/a[1]'.toQureySelector()).text.trim();
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
      //     .querySelector('/td[2]/div/a[1]'.toQureySelector())
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
}
