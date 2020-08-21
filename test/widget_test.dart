// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'dart:convert';

import 'package:charset_converter/charset_converter.dart';
import 'package:communityexplorer/component/huvkr/huvkr_parser.dart';
import 'package:communityexplorer/network/http_header.dart';
import 'package:communityexplorer/other/xpath_to_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

import 'package:communityexplorer/main.dart';

void main() {
  test('Counter increments smoke test', () async {
    // print(XPathToQureySelector.getInstance()
    //     .toSelector(".//span[@class='reply_num']"));

    var url = 'http://web.humoruniv.com/board/humor/list.html?table=pds';
    var html = (await http.get(
      url,
      headers: {
        'Accept': HttpWrapper.accept,
        'UserAgent': HttpWrapper.userAgent,
      },
    ))
        .body;

    print(html.length);

    HuvkrParser.parseBoard(html).forEach((element) {
      print(element.title.trim());
    });
  });
}
