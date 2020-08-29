// This source code is a part of Project Violet.
// Copyright (C) 2020. rollrat. Licensed under the MIT License.

import 'package:communityexplorer/component/interface.dart';
import 'package:communityexplorer/other/html/parser.dart';
import 'package:communityexplorer/other/xpath_to_selector.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:flutter/foundation.dart';

class FMKoreaParser {
  static Future<List<ArticleInfo>> parseThumbnailView(String html) async {
    var result = List<ArticleInfo>();
    var doc = await compute(parse, html);

    var ww = doc.querySelector('div.fm_best_widget > ul');

    for (var ll in ww.querySelectorAll('li')) {
      var recom = int.parse(
          ll.querySelector('/div/a/span[2]'.toquerySelector()).text.trim());

      var url =
          ll.querySelector('/div/a[2]'.toquerySelector()).attributes['href'];
      // var thumbnail = ll
      //     .querySelector('/div/a[2]/img'.toquerySelector())
      //     .attributes['data-original'];
      var thumbnail = '';
      if (ll.querySelector('/div/a[2]/img'.toquerySelector()) != null)
        thumbnail = ll
            .querySelector('/div/a[2]/img'.toquerySelector())
            .attributes['data-original'];
      var title = HtmlUnescape()
          .convert(ll.querySelector('/div/h3/a'.toquerySelector()).text.trim());

      var board =
          ll.querySelector('/div/div/span/a'.toquerySelector()).text.trim();
      var prefix = '';
      if (ll.querySelector('/div/div/span/a[2]'.toquerySelector()) != null)
        prefix = ll
            .querySelector('/div/div/span/a[2]'.toquerySelector())
            .text
            .trim();

      var datet =
          ll.querySelector('/div/div[2]/span'.toquerySelector()).text.trim();
      DateTime dt;
      if (datet.contains('분 전')) {
        datet = datet.replaceAll('분 전', '').trim();
        dt = DateTime.now().subtract(Duration(minutes: int.parse(datet)));
      } else if (datet.contains('시간 전')) {
        datet = datet.replaceAll('시간 전', '').trim();
        dt = DateTime.now().subtract(Duration(hours: int.parse(datet)));
      } else {
        dt = DateTime.parse(datet.replaceAll('.', '-'));
      }

      var nick =
          ll.querySelector('/div/div[2]/span[2]'.toquerySelector()).text.trim();

      var id = url.split('/').last;

      var comment = 0;

      try {
        comment = int.parse(title.split('[').last.split(']').first);
      } catch (e) {}

      result.add(ArticleInfo(
        upvote: recom,
        url: 'https://www.fmkorea.com' + url,
        thumbnail: thumbnail != '' ? 'https:' + thumbnail : null,
        title: title,
        preface: '$board' + (prefix != '' ? '-$prefix' : ''),
        writeTime: dt,
        nickname: nick,
        hasImage: thumbnail != '',
        info: id,
        comment: comment,
        hasVideo: false,
      ));
    }

    return result;
  }

  static Future<List<ArticleInfo>> parseBoardView(String html) {}
}
