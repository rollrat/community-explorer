// This source code is a part of Project Violet.
// Copyright (C) 2020. rollrat. Licensed under the MIT License.

import 'package:communityexplorer/component/interface.dart';
import 'package:communityexplorer/other/html/parser.dart';
import 'package:communityexplorer/other/xpath_to_selector.dart';
import 'package:flutter/foundation.dart';

class ClienParser {
  static Future<List<ArticleInfo>> parseBoard(String html) async {
    var doc = await compute(parse, html);
    var items = doc.querySelector('div.list_content');
    var result = List<ArticleInfo>();

    for (var item in items.querySelectorAll('div.list_item')) {
      var sym = int.parse(item.querySelector('div.view_symph').text.trim());

      var board =
          item.querySelector('/div[2]/a[1]/span[2]'.toquerySelector()) != null
              ? item
                  .querySelector('/div[2]/a[1]/span[1]'.toquerySelector())
                  .text
              : null;

      var title =
          item.querySelector('/div[2]/a[1]/span[2]'.toquerySelector()) != null
              ? item
                  .querySelector('/div[2]/a[1]/span[2]'.toquerySelector())
                  .text
                  .trim()
              : item
                  .querySelector('/div[2]/a[1]'.toquerySelector())
                  .text
                  .trim();

      var hasimg = item.querySelector('span.icon_pic') != null;

      var comment = 0;

      try {
        comment = int.parse(item
            .querySelector('/div[2]/a[2]/span[1]'.toquerySelector())
            .text
            .trim());
      } catch (e) {}

      var nick = item.querySelector('/div[3]/span[2]'.toquerySelector()).text;

      if (nick == '') {
        nick = item
            .querySelector('/div[3]/span[2]/img[1]'.toquerySelector())
            .attributes['alt'];
      }

      var viewt = item.querySelector('/div[4]'.toquerySelector()).text.trim();
      var view = 0;

      if (viewt.contains('k'))
        view = (double.parse(viewt.replaceAll('k', '').trim()) * 1000).toInt();
      else
        view = int.parse(viewt);

      var dt = DateTime.parse(
          item.querySelector('/div[5]/span[1]/span[1]'.toquerySelector()).text);

      var url = 'https://www.clien.net' +
          item
              .querySelector('/div[2]/a[1]'.toquerySelector())
              .attributes['href'];

      result.add(ArticleInfo(
        upvote: sym,
        preface: board,
        title: title,
        comment: comment,
        nickname: nick,
        views: view,
        writeTime: dt,
        url: url,
        info: url.split('/').last.split('?').first,
        hasImage: hasimg,
        hasVideo: false,
      ));
    }

    return result;
  }
}
