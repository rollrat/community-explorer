// This source code is a part of Project Violet.
// Copyright (C) 2020. rollrat. Licensed under the MIT License.

import 'package:communityexplorer/component/interface.dart';
import 'package:communityexplorer/other/html/parser.dart';
import 'package:flutter/foundation.dart';

class DCInsideParser {
  static Future<List<ArticleInfo>> parseGalleryBoard(String html) async {
    var doc = (await compute(parse, html)).querySelector('tbody');
    var result = List<ArticleInfo>();

    for (var tr in doc.querySelectorAll('tr')) {
      var no = tr.querySelector('td:nth-of-type(1)').text;

      if (int.tryParse(no) == null) continue;

      var type = tr
          .querySelector('td:nth-of-type(2) > a > em')
          .attributes['class']
          .split(' ')[1];
      var hashimg = type.contains('icon_pic') || type.contains('icon_recomimg');
      var hashvideo =
          type.contains('icon_toprecomimg') || type.contains('icon_movie');

      var title = tr.querySelector('td:nth-of-type(2) > a').text.trim();
      int reply = 0;
      try {
        reply = int.parse(tr
            .querySelector('span.reply_num')
            .text
            .replaceAll('[', '')
            .replaceAll(']', '')
            .split('/')
            .first
            .trim());
      } catch (e) {}
      var nick =
          tr.querySelector('td:nth-of-type(3)').attributes['data-nick'] ?? '';
      var uid = tr.querySelector('td:nth-of-type(3)').attributes['data-uid'];
      var ip = tr.querySelector('td:nth-of-type(3)').attributes['data-ip'];

      if (ip != null && ip != '') {
        nick += ' ($ip)';
      } else if (uid != null && uid != '') {
        nick += ' ($uid)';
      }

      var date = DateTime.parse(
          tr.querySelector('td:nth-of-type(4)').attributes['title']);
      var view = int.parse(tr.querySelector('td:nth-of-type(5)').text);
      var recom = int.parse(tr.querySelector('td:nth-of-type(6)').text);

      var link = 'https://gall.dcinside.com' +
          tr.querySelector('a').attributes['href'];

      result.add(
        ArticleInfo(
          info: no,
          title: title,
          comment: reply,
          nickname: nick,
          writeTime: date,
          views: view,
          upvote: recom,
          url: link,
          hasImage: hashimg,
          hasVideo: hashvideo,
        ),
      );
    }

    return result;
  }

  static Future<List<ArticleInfo>> parseMinorGalleryBoard(String html) async {
    var doc = (await compute(parse, html)).querySelector('tbody');
    var result = List<ArticleInfo>();

    for (var tr in doc.querySelectorAll('tr')) {
      var no = tr.querySelector('td:nth-of-type(1)').text;

      if (int.tryParse(no) == null) continue;

      var classify = tr.querySelector('td:nth-of-type(2)').text.trim();

      if (classify == '공지' || classify == '설문' || classify == 'AD') continue;

      var type = tr
          .querySelector('td:nth-of-type(3) > a > em')
          .attributes['class']
          .split(' ')[1];
      var hashimg = type.contains('icon_pic') || type.contains('icon_recomimg');
      var hashvideo =
          type.contains('icon_toprecomimg') || type.contains('icon_movie');

      var title = tr.querySelector('td:nth-of-type(3) > a').text.trim();
      int reply = 0;
      try {
        reply = int.parse(tr
            .querySelector('span.reply_num')
            .text
            .replaceAll('[', '')
            .replaceAll(']', '')
            .split('/')
            .first
            .trim());
      } catch (e) {}
      var nick =
          tr.querySelector('td:nth-of-type(4)').attributes['data-nick'] ?? '';
      var uid = tr.querySelector('td:nth-of-type(4)').attributes['data-uid'];
      var ip = tr.querySelector('td:nth-of-type(4)').attributes['data-ip'];

      if (ip != null && ip != '') {
        nick += ' ($ip)';
      } else if (uid != null && uid != '') {
        nick += ' ($uid)';
      }

      var date = DateTime.parse(
          tr.querySelector('td:nth-of-type(5)').attributes['title']);
      var view = int.parse(tr.querySelector('td:nth-of-type(6)').text);
      var recom = int.parse(tr.querySelector('td:nth-of-type(7)').text);

      var link = 'https://gall.dcinside.com' +
          tr.querySelector('a').attributes['href'];

      result.add(
        ArticleInfo(
          info: no,
          title: title,
          comment: reply,
          nickname: nick,
          writeTime: date,
          views: view,
          upvote: recom,
          preface: classify,
          url: link,
          hasImage: hashimg,
          hasVideo: hashvideo,
        ),
      );
    }

    return result;
  }
}
