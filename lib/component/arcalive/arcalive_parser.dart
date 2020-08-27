// This source code is a part of Project Violet.
// Copyright (C) 2020. rollrat. Licensed under the MIT License.

import 'package:communityexplorer/component/interface.dart';
import 'package:communityexplorer/other/html/parser.dart';
import 'package:communityexplorer/other/xpath_to_selector.dart';
import 'package:flutter/foundation.dart';

class ArcaLiveParser {
  /*
  Pattern: /html[1]/body[1]/div[1]/div[3]/article[1]/div[1]/div[4]/div[2]/a[{8+i*1}]
  public class Pattern
  {
      public string no;
      public string class;
      public string title;
      public string comment;
      public string author;
      public string datetime;
      public string views;
      public string recom;
  }

  public List<Pattern> Extract(string html)
  {
      HtmlDocument document = new HtmlDocument();
      document.LoadHtml(html);
      var result = new List<Pattern>();
      var root_node = document.DocumentNode;
      for (int i = 1; ; i++)
      {
          var node = root_node.SelectSingleNode($"/html[1]/body[1]/div[1]/div[3]/article[1]/div[1]/div[4]/div[2]/a[{8+i*1}]");
          if (node == null) break;
          var pattern = new Pattern();
          pattern.no = node.SelectSingleNode("./div[1]/span[1]").InnerText;
          pattern.class = node.SelectSingleNode("./div[1]/span[2]/span[1]").InnerText;
          pattern.title = node.SelectSingleNode("./div[1]/span[2]/span[2]").InnerText;
          pattern.comment = node.SelectSingleNode("./div[1]/span[2]/span[3]").InnerText;
          pattern.author = node.SelectSingleNode("./div[2]/span[1]/span[1]").InnerText;
          pattern.datetime = node.SelectSingleNode("./div[2]/span[2]").InnerText;
          pattern.views = node.SelectSingleNode("./div[2]/span[3]").InnerText;
          pattern.recom = node.SelectSingleNode("./div[2]/span[4]").InnerText;
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
          '/html[1]/body[1]/div[1]/div[3]/article[1]/div[1]/div[4]/div[1]/a[$i]'
              .toQureySelector());

      bool f = false;

      if (node == null) {
        node = doc.querySelector(
            '/html[1]/body[1]/div[1]/div[3]/article[1]/div[1]/div[4]/div[2]/a[$i]'
                .toQureySelector());
        f = true;

        if (node == null) break;
      }

      var no = node
          .querySelector('div:nth-of-type(1) > span:nth-of-type(1)')
          .text
          .trim();
      if (no == '번호' || no == '공지') continue;

      var com = node.querySelector(f
          ? 'div:nth-of-type(1) > span:nth-of-type(2) > span:nth-of-type(3) > span:nth-of-type(1)'
          : 'div:nth-of-type(1) > span:nth-of-type(2) > span:nth-of-type(2) > span:nth-of-type(1)');

      result.add(
        ArticleInfo(
          info: node
              .querySelector('div:nth-of-type(1) > span:nth-of-type(1)')
              .text
              .trim(),
          preface: node
              .querySelector(
                  'div:nth-of-type(1) > span:nth-of-type(2) > span:nth-of-type(1)')
              .text
              .trim(),
          title: node
              .querySelector(f
                  ? 'div:nth-of-type(1) > span:nth-of-type(2) > span:nth-of-type(2)'
                  : 'div:nth-of-type(1) > span:nth-of-type(2) > span:nth-of-type(1)')
              .text
              .trim(),
          comment: com != null
              ? int.parse(
                  com.text.trim().replaceAll('[', '').replaceAll(']', ''))
              : 0,
          nickname: node
              .querySelector(
                  'div:nth-of-type(2) > span:nth-of-type(1) > span:nth-of-type(1)')
              .text
              .trim(),
          writeTime: DateTime.parse(node
                  .querySelector(
                      'div:nth-of-type(2) > span:nth-of-type(2) > time:nth-of-type(1)')
                  .attributes['datetime']
                  .trim())
              .toLocal(),
          views: int.parse(node
              .querySelector('div:nth-of-type(2) > span:nth-of-type(3)')
              .text
              .trim()),
          upvote: int.parse(node
              .querySelector('div:nth-of-type(2) > span:nth-of-type(4)')
              .text
              .trim()),
          url: 'https://arca.live' + node.attributes['href'],
          thumbnail: node.querySelector('img') != null
              ? 'http:' + node.querySelector('img').attributes['src']
              : null,
          hasImage: node.querySelector('span.ion-ios-photos-outline') != null,
          hasVideo: false,
        ),
      );
    }

    return result;
  }

  static Map<String, dynamic> parseArticle(String html) {
    var doc = parse(html);

    var channel = doc
        .querySelector(
            'html > body > div:nth-of-type(1) > div:nth-of-type(3) > article:nth-of-type(1) > div:nth-of-type(1) > div:nth-of-type(1) > a:nth-of-type(1)')
        .text
        .trim();
    var title = doc
        .querySelector(
            'html > body > div:nth-of-type(1) > div:nth-of-type(3) > article:nth-of-type(1) > div:nth-of-type(1) > div:nth-of-type(2) > div:nth-of-type(2) > div:nth-of-type(1) > div:nth-of-type(1)')
        .text
        .trim();
    var body = doc.querySelector(
        'html > body > div:nth-of-type(1) > div:nth-of-type(3) > article:nth-of-type(1) > div:nth-of-type(1) > div:nth-of-type(2) > div:nth-of-type(3) > div:nth-of-type(2)');

    var links = List<String>();

    var imgs = body.querySelectorAll('img');
    var videos = body.querySelectorAll('video');

    try {
      if (imgs != null) {
        links.addAll(
            imgs.map((e) => 'https:' + e.attributes['src'] + '?type=orig'));
      }
      if (videos != null) {
        links.addAll(videos.map((e) {
          if (e.attributes['data-orig'] == 'gif')
            return 'https:' + e.attributes['src'] + '.gif?type=orig';
          return 'https:' + e.attributes['src'] + '?type=orig';
        }));
      }
    } catch (e) {
      // print(e);
    }

    return {
      'channel': channel,
      'title': title,
      'links': links,
    };
  }
}
