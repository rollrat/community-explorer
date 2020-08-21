// This source code is a part of Project Violet.
// Copyright (C) 2020. rollrat. Licensed under the MIT License.

import 'package:communityexplorer/component/interface.dart';
import 'package:communityexplorer/other/html/parser.dart';
import 'package:communityexplorer/other/xpath_to_selector.dart';

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
  static List<ArticleInfo> parseBoard(String html) {
    var doc = parse(html);
    var result = List<ArticleInfo>();

    for (int i = 1;; i++) {
      var node = doc.querySelector(
          '/html/body/div[2]/div[1]/div[2]/div[2]/div[2]/div[1]/table[2]/tbody/tr[$i]'
              .toQureySelector());

      if (node.attributes['id'] == null) break;

      var thumbnail = node
          .querySelector("./td[1]/div[1]/a[1]/img[1]".toQureySelector())
          .attributes['src'];
      var title = node
          .querySelector('./td[2]/a[1]'.toQureySelector())
          .text
          .trim()
          .replaceAll(new RegExp(r"\s+"), " ")
          .replaceAll(new RegExp(r"\[\d+\]"), "");
      var comment = int.parse(node
          .querySelector('./td[2]/a[1]/span[1]'.toQureySelector())
          .text
          .split('[')
          .last
          .split(']')
          .first
          .trim());

      var author = node
          .querySelector('./td[3]/table[1]/tbody/tr[1]/td[2]/span[1]/span[1]'
              .toQureySelector())
          .text
          .trim();

      var writetime = DateTime.parse(node
          .querySelector('./td[4]'.toQureySelector())
          .text
          .replaceAll(new RegExp(r"\s+"), " ")
          .trim());
      var view = int.parse(node
          .querySelector('./td[5]'.toQureySelector())
          .text
          .replaceAll(',', '')
          .trim());
      var up = int.parse(node
          .querySelector('./td[6]'.toQureySelector())
          .text
          .replaceAll(',', '')
          .trim());
      var down = int.parse(node
          .querySelector('./td[7]'.toQureySelector())
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
      ));
    }

    return result;
  }
}
