// This source code is a part of Project Violet.
// Copyright (C) 2020. rollrat. Licensed under the MIT License.

import 'package:communityexplorer/component/interface.dart';
import 'package:communityexplorer/other/html/parser.dart';
import 'package:communityexplorer/other/xpath_to_selector.dart';
import 'package:flutter/foundation.dart';

class DogDripParser {
  static Future<List<ArticleInfo>> parseBoard(String html) async {
    var result = List<ArticleInfo>();
    var doc = (await compute(parse, html))
        .querySelector('table.ed.table.table-divider > tbody');

    var dtr = RegExp(r'(?<d>\d+)?\s*(?<t>방금|분|시간|일)\s+전');

    for (var tr in doc.querySelectorAll('tr')) {
      if (tr.attributes['class'] != null && tr.attributes['class'] == 'notice')
        continue;
      int base = 2;

      var id = tr.querySelector('/td[1]'.toquerySelector()).text.trim();

      if (int.tryParse(id) == null && id != '') {
        base = 1;
      }

      var classt =
          tr.querySelector('/td[$base]/span/a/span'.toquerySelector()).text;

      int sub = 1;

      if (tr.querySelector('/td[$base]/span/a[2]'.toquerySelector()) != null)
        sub = 2;

      var url = tr
          .querySelector('/td[$base]/span/a[$sub]'.toquerySelector())
          .attributes['href'];
      if (!url.startsWith('http')) url = 'https://www.dogdrip.net' + url;
      id = url.split(RegExp(r'/|\=|\&')).last;
      var title = tr
          .querySelector('/td[$base]/span/a[$sub]/span'.toquerySelector())
          .text
          .trim();
      String comment;
      if (tr.querySelector(
              '/td[$base]/span/a[$sub]/span[2]'.toquerySelector()) !=
          null)
        comment = tr
            .querySelector('/td[$base]/span/a[$sub]/span[2]'.toquerySelector())
            .text
            .trim();

      bool img = false;
      bool video = false;
      var icon = tr
          .querySelector('/td[$base]/span/a[$sub]/span[2]/i'.toquerySelector());

      if (icon == null) {
        icon = tr.querySelector(
            '/td[$base]/span/a[$sub]/span[3]/i'.toquerySelector());
      }

      if (icon != null) {
        if (icon.attributes['class'].contains('fa-image')) img = true;
        if (icon.attributes['class'].contains('fa-video')) video = true;
      }

      // img
      var author =
          tr.querySelector('/td[${base + 1}]/a'.toquerySelector()).text.trim();
      var upvote =
          tr.querySelector('/td[${base + 2}]'.toquerySelector()).text.trim();
      var writetimet =
          tr.querySelector('/td[${base + 3}]'.toquerySelector()).text.trim();

      DateTime writeTime;
      if (writetimet.contains('.'))
        writeTime = DateTime.parse(writetimet.replaceAll('.', '-'));
      else {
        var x = dtr.firstMatch(writetimet);

        switch (x.namedGroup('t')) {
          case '방금':
            writeTime = DateTime.now();
            break;
          case '분':
            writeTime = DateTime.now()
                .subtract(Duration(minutes: int.parse(x.namedGroup('d'))));
            break;
          case '시간':
            writeTime = DateTime.now()
                .subtract(Duration(hours: int.parse(x.namedGroup('d'))));
            break;
          case '일':
            writeTime = DateTime.now()
                .subtract(Duration(days: int.parse(x.namedGroup('d'))));
            break;
        }
      }

      // var views =
      //     tr.querySelector('/td[${base + 4}]'.toquerySelector()).text.trim();

      int views = 0;
      if (tr.querySelector('/td[${base + 4}]'.toquerySelector()) != null)
        views = int.parse(
            tr.querySelector('/td[${base + 4}]'.toquerySelector()).text.trim());

      result.add(ArticleInfo(
        info: id,
        url: url,
        preface: sub == 1 ? classt : null,
        title: title,
        comment: comment != null ? int.parse(comment) : 0,
        hasImage: img,
        hasVideo: video,
        nickname: author,
        upvote: int.parse(upvote),
        writeTime: writeTime,
        views: views,
      ));
    }

    return result;
  }
}
