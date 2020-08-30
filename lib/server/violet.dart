// This source code is a part of Project Violet.
// Copyright (C) 2020. rollrat. Licensed under the MIT License.

import 'dart:convert';
import 'dart:math';

import 'package:communityexplorer/network/wrapper.dart';
import 'package:hive/hive.dart';

// xc는 서버에서 정상적인 제출인지를 확인하기 위해 사용한다.
// 위치랜덤까지 적용하려했지만 귀찮아서...
class Violet {
  static String surl = 'http://asdf54as06d5f40asdfasd5f6a0s.com';
  // static String surl = 'http://127.0.0.1';

  static Future<String> reportLegacy(
      String url, String id, String title, String body) async {
    int b = int.parse(id);
    int v = b ^ 69744485;
    int x = DateTime.now().toUtc().millisecondsSinceEpoch;
    var rnd = Random();
    var yy = '';
    var zz = '';
    yy += (rnd.nextInt(9) + 1).toString();
    for (int i = 0; i < 4; i++) yy += rnd.nextInt(10).toString();
    for (int i = 0; i < 5; i++) zz += rnd.nextInt(10).toString();
    return (await HttpWrapper.post(surl + '/api/report',
            body: jsonEncode({
              "id": id,
              "title": title,
              "xc": yy + x.toString().substring(x.toString().length - 6) + zz,
              "body": body,
              "valid": v.toString(),
              "url": url,
            })))
        .body;
  }

  static Future<String> contactLegacy(
      String id, String title, String body) async {
    int b = int.parse(id);
    int v = b ^ 69744485;
    int x = DateTime.now().toUtc().millisecondsSinceEpoch;
    var rnd = Random();
    var yy = '';
    var zz = '';
    yy += (rnd.nextInt(9) + 1).toString();
    for (int i = 0; i < 4; i++) yy += rnd.nextInt(10).toString();
    for (int i = 0; i < 5; i++) zz += rnd.nextInt(10).toString();
    return (await HttpWrapper.post(surl + '/api/contact',
            body: jsonEncode({
              "id": id,
              "title": title,
              "xc": yy + x.toString().substring(x.toString().length - 6) + zz,
              "body": body,
              "valid": v.toString()
            })))
        .body;
  }

  static Future<String> report(
      String url, String id, String title, String body) async {
    var token = Hive.box('fcm').get('token');
    return (await HttpWrapper.post(surl + '/api/report',
            body: jsonEncode({
              "token": token,
              "title": title,
              "body": body,
              "url": url,
            })))
        .body;
  }

  static Future<String> contact(String id, String title, String body) async {
    var token = Hive.box('fcm').get('token');
    return (await HttpWrapper.post(surl + '/api/contact',
            body: jsonEncode({
              "token": token,
              "title": title,
              "body": body,
            })))
        .body;
  }
}
