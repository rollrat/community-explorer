// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'dart:convert';

import 'package:charset_converter/charset_converter.dart';
import 'package:communityexplorer/component/dogdrip/dogdrip_parser.dart';
import 'package:communityexplorer/component/huvkr/huvkr_parser.dart';
import 'package:communityexplorer/network/wrapper.dart';
import 'package:communityexplorer/other/html/parser.dart';
import 'package:communityexplorer/other/xpath_to_selector.dart';
import 'package:communityexplorer/server/violet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

import 'package:communityexplorer/main.dart';

void main() {
  test('Counter increments smoke test', () async {
    // print(XPathToquerySelector.getInstance()
    //     .toSelector(".//span[@class='reply_num']"));

    //print(DateTime.now().toUtc().millisecondsSinceEpoch);
    // print(await Violet.report("test.com", "1234", "test", "test"));

    // var url = 'https://www.dogdrip.net/doc';
    var url =
        'https://www.dogdrip.net/index.php?mid=gameserial&category=125480378&page=1';
    var html = (await HttpWrapper.getr(
      url,
      headers: {
        'Accept': HttpWrapper.accept,
        'UserAgent': HttpWrapper.userAgent,
      },
    ))
        .body;

    // print(html.length);

    // HuvkrParser.parseBoard(html).forEach((element) {
    //   print(element.title.trim());
    // });

    // (await DogDripParser.parseBoard(html)).forEach((element) {
    //   print(element.title);
    // });

    var doc = parse(html)
        .querySelector('div.ed.category.category-pill')
        .querySelectorAll('a');

    doc
        .map((e) {
          if (!e.attributes['href'].contains('/category/'))
            return '${e.text.trim()}|category|';
          return '${e.text.trim()}|category|${e.attributes['href'].split('/').last}';
        })
        .toList()
        .forEach((element) {
          print(element);
        });
  });
}
