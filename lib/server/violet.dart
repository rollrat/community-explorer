// This source code is a part of Project Violet.
// Copyright (C) 2020. rollrat. Licensed under the MIT License.

import 'dart:convert';
import 'dart:math';

import 'package:communityexplorer/network/wrapper.dart';

class Violet {
  static String surl = 'http://asdf54as06d5f40asdfasd5f6a0s.com';
  // static String surl = 'http://127.0.0.1';

  static Future<String> report(
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

  static Future<String> contact(String id, String title, String body) async {
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
}
