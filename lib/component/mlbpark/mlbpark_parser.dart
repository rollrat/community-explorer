// This source code is a part of Project Violet.
// Copyright (C) 2020. rollrat. Licensed under the MIT License.

import 'package:communityexplorer/component/interface.dart';
import 'package:communityexplorer/other/html/parser.dart';
import 'package:communityexplorer/other/xpath_to_selector.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

class MLBParkParser {
  static Future<List<ArticleInfo>> parseBoard(String html) async {
    var result = List<ArticleInfo>();
    var doc = await compute(parse, html);
    var now = DateFormat('yyyy-MM-dd').format(DateTime.now()) + ' ';

    for (int i = 1;; i++) {
      var node = doc.querySelector(
          '/html[1]/body[1]/div[1]/div[3]/div[2]/div[1]/div[1]/table[1]/tbody[1]/tr[$i]'
              .toquerySelector());

      if (node == null) break;

      var not = node.querySelector('/td[1]'.toquerySelector()).text.trim();

      if (not == '공지') continue;

      var no = int.parse(not);

      var url = node
          .querySelector('/td[2]/a[1]'.toquerySelector())
          .attributes['href'];
      var title =
          node.querySelector('/td[2]/a[1]'.toquerySelector()).text.trim();

      String word;
      var comment = 0;

      var ff = node.querySelector('/td[2]/a[1]/span[1]'.toquerySelector());
      var bb = node.querySelector('/td[2]/a[1]/span[2]'.toquerySelector());

      if (ff != null) {
        if (ff.text.contains('[')) {
          comment = int.parse(ff.text.split('[').last.split(']').first.trim());
        } else {
          word = ff.text.trim();
        }
      }

      if (bb != null) {
        if (bb.text.contains('[')) {
          comment = int.parse(bb.text.split('[').last.split(']').first.trim());
        } else {
          word = bb.text.trim();
        }
      }

      var author = node.querySelector('/td[3]/span[2]'.toquerySelector()).text;

      var writeTimet =
          node.querySelector('/td[4]/span[1]'.toquerySelector()).text.trim();

      DateTime writeTime;
      if (writeTimet.contains(':')) {
        writeTime = DateTime.parse(now + writeTimet);
      } else
        writeTime = DateTime.parse(writeTimet);

      var views = int.parse(node
          .querySelector('/td[5]/span[1]'.toquerySelector())
          .text
          .trim()
          .replaceAll(',', ''));

      result.add(ArticleInfo(
        info: no.toString(),
        url: url,
        title: title,
        preface: word,
        comment: comment,
        nickname: author,
        writeTime: writeTime,
        upvote: 0,
        views: views,
        hasImage: false,
        hasVideo: false,
      ));
    }

    return result;
  }
}
