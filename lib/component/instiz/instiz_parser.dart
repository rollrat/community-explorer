// This source code is a part of Project Violet.
// Copyright (C) 2020. rollrat. Licensed under the MIT License.

import 'package:communityexplorer/component/interface.dart';
import 'package:communityexplorer/other/html/parser.dart';
import 'package:communityexplorer/other/xpath_to_selector.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

class InstizParser {
  static Future<List<ArticleInfo>> parseBoard(String html) async {
    var result = List<ArticleInfo>();
    var doc = await compute(parse, html);

    var now = DateFormat('yyyy-MM-dd').format(DateTime.now()) + ' ';

    var dtc = RegExp(r' (\d):');

    for (int i = 1;; i++) {
      var node = doc.querySelector(
          "//table[@id='mainboard']/tbody/tr[$i]".toquerySelector());

      if (node == null) break;

      if (node.attributes['id'] == 'topboard') continue;

      var id =
          int.parse(node.querySelector('/td[1]'.toquerySelector()).text.trim());
      var category = node.querySelector('/td[2]'.toquerySelector()).text.trim();

      var hasimg = node.querySelector('/td[3]/i'.toquerySelector()) != null;
      var title =
          node.querySelector('/td[3]/span/a'.toquerySelector()).text.trim();
      var url = 'https://www.instiz.net/' +
          node
              .querySelector('/td[3]/span/a'.toquerySelector())
              .attributes['href']
              .trim();
      var comment = 0;
      if (node.querySelector('/td[3]/a'.toquerySelector()) != null) {
        comment =
            int.parse(node.querySelector('/td[3]/a'.toquerySelector()).text);
      }

      var nick = node.querySelector('/td[4]/a'.toquerySelector()).text.trim();
      var datet = node.querySelector('/td[5]'.toquerySelector()).text.trim();
      DateTime date;
      if (datet.contains('.'))
        date = DateTime.parse(
            DateTime.now().year.toString() + '-' + datet.replaceAll('.', '-'));
      else {
        if (dtc.hasMatch(now + datet)) {
          date = DateTime.parse((now + datet).replaceAll(
              dtc, ' 0' + dtc.firstMatch(now + datet).group(1) + ':'));
        } else
          date = DateTime.parse(now + datet);
      }

      var view =
          int.parse(node.querySelector('/td[6]'.toquerySelector()).text.trim());
      var upvote =
          int.parse(node.querySelector('/td[7]'.toquerySelector()).text.trim());

      result.add(ArticleInfo(
        info: id.toString(),
        preface: category != '' ? category : null,
        hasImage: hasimg,
        title: title,
        url: url,
        comment: comment,
        nickname: nick,
        writeTime: date,
        views: view,
        upvote: upvote,
        hasVideo: false,
      ));
    }

    return result;
  }
}
