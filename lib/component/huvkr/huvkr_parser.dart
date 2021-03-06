// This source code is a part of Project Violet.
// Copyright (C) 2020. rollrat. Licensed under the MIT License.

import 'package:communityexplorer/component/interface.dart';
import 'package:communityexplorer/other/html/parser.dart';
import 'package:communityexplorer/other/xpath_to_selector.dart';
import 'package:flutter/foundation.dart';

class HuvkrParser {
  /*
  public List<Pattern> Extract(string html)
  {
      HtmlDocument document = new HtmlDocument();
      document.LoadHtml(html);
      var result = new List<Pattern>();
      var root_node = document.DocumentNode;
      for (int i = 1; ; i++)
      {
          var node = root_node.SelectSingleNode($"/html[1]/body[1]/div[2]/div[1]/div[2]/div[2]/div[2]/div[1]/table[2]/tr[{1+i*1}]");
          if (node == null) break;
          var pattern = new Pattern();
          pattern.thumbnail = node.SelectSingleNode("./td[1]/div[1]/a[1]/img[1]").InnerText;
          pattern.title = node.SelectSingleNode("./td[2]/a[1]").InnerText;
          pattern.comment = node.SelectSingleNode("./td[2]/a[1]/span[1]").InnerText;
          pattern.author = node.SelectSingleNode("./td[3]/table[1]/tr[1]/td[2]/span[1]/span[1]").InnerText;
          pattern.writetime = node.SelectSingleNode("./td[4]").InnerText;
          pattern.view = node.SelectSingleNode("./td[5]").InnerText;
          pattern.upvote = node.SelectSingleNode("./td[6]").InnerText;
          pattern.downvote = node.SelectSingleNode("./td[7]").InnerText;
          result.Add(pattern);
      }
      return result;
  }
  */

  static Future<List<ArticleInfo>> parseBoard(String html) async {
    var doc = await compute(parse, html);
    var result = List<ArticleInfo>();

    for (int i = 1;; i++) {
      var node = doc.querySelector(
          '/html/body/div[2]/div[1]/div[2]/div[2]/div[2]/div[1]/table[2]/tbody/tr[$i]'
              .toquerySelector());

      if (node.attributes['id'] == null) break;

      var thumbnail = node
          .querySelector("./td[1]/div[1]/a[1]/img[1]".toquerySelector())
          .attributes['src'];
      var title = node
          .querySelector('./td[2]/a[1]'.toquerySelector())
          .text
          .trim()
          .replaceAll(new RegExp(r"\s+"), " ")
          .replaceAll(new RegExp(r"\[\d+\]"), "");
      var comment = int.parse(node
          .querySelector('./td[2]/a[1]/span[1]'.toquerySelector())
          .text
          .split('[')
          .last
          .split(']')
          .first
          .trim());

      var author = node
          .querySelector('./td[3]/table[1]/tbody/tr[1]/td[2]/span[1]/span[1]'
              .toquerySelector())
          .text
          .trim();

      var writetime = DateTime.parse(node
          .querySelector('./td[4]'.toquerySelector())
          .text
          .replaceAll(new RegExp(r"\s+"), " ")
          .trim());
      var view = int.parse(node
          .querySelector('./td[5]'.toquerySelector())
          .text
          .replaceAll(',', '')
          .trim());
      var up = int.parse(node
          .querySelector('./td[6]'.toquerySelector())
          .text
          .replaceAll(',', '')
          .trim());
      var down = int.parse(node
          .querySelector('./td[7]'.toquerySelector())
          .text
          .replaceAll(',', '')
          .trim());

      var url = 'http://web.humoruniv.com/board/humor/' +
          node.querySelector('a').attributes['href'];

      result.add(ArticleInfo(
        thumbnail: thumbnail,
        title: title,
        comment: comment,
        nickname: author,
        writeTime: writetime,
        views: view,
        upvote: up,
        downvote: down,
        url: url,
        info: url.split('number=').last.split('&').first,
        hasImage: true,
        hasVideo: false,
      ));
    }

    return result;
  }

  /*
  public List<Pattern> Extract(string html)
  {
      HtmlDocument document = new HtmlDocument();
      document.LoadHtml(html);
      var result = new List<Pattern>();
      var root_node = document.DocumentNode;
      for (int i = 1; ; i++)
      {
          var node = root_node.SelectSingleNode($"/html[1]/body[1]/div[1]/div[6]/ul[1]/a[{1+i*1}]/li[1]/table[1]/tr[1]/td[2]");
          if (node == null) break;
          var pattern = new Pattern();
          pattern.title = node.SelectSingleNode("./dd[1]/span[2]/span[1]").InnerText;
          pattern.upvote = node.SelectSingleNode("./span[1]/span[1]").InnerText;
          pattern.downvote = node.SelectSingleNode("./span[1]/span[2]").InnerText;
          pattern.comment = node.SelectSingleNode("./span[1]/span[3]").InnerText;
          pattern.view = node.SelectSingleNode("./span[1]/span[4]").InnerText;
          pattern.writetime = node.SelectSingleNode("./div[1]/span[1]").InnerText;
          pattern.nick = node.SelectSingleNode("./div[1]/span[3]/span[1]/span[1]").InnerText;
          result.Add(pattern);
      }
      return result;
  }
  */
  static List<ArticleInfo> parseBoardMobile(String html) {}
}
