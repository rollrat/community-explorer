// This source code is a part of Project Violet.
// Copyright (C) 2020. rollrat. Licensed under the MIT License.

import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:core';

import 'package:collection/collection.dart';
import 'package:communityexplorer/component/component_manager.dart';
import 'package:communityexplorer/component/interface.dart';
import 'package:communityexplorer/log/log.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class BoardFixed {
  List<ArticleInfo> _scraps = List<ArticleInfo>();
  HashSet<String> _scrapURLS = HashSet<String>();
  List<ArticleInfo> _record = List<ArticleInfo>();
  List<String> _filter = List<String>();
  String name;

  BoardFixed(String name) {
    this.name = name;
  }

  Future<void> initFixed() async {
    var scrapt = Hive.box('scraps')
        .get(base64.encode(utf8.encode(name)), defaultValue: '[]');
    var recordt = Hive.box('record')
        .get(base64.encode(utf8.encode(name)), defaultValue: '[]');
    var filtert = Hive.box('filter')
        .get(base64.encode(utf8.encode(name)), defaultValue: '[]');
    if (scrapt == '') {
      _scraps = List<ArticleInfo>();
      await saveScrap();
    }
    if (recordt == '') {
      _record = List<ArticleInfo>();
      await saveRecord();
    }
    if (filtert == '') {
      _filter = List<String>();
      await saveFilter();
    }

    _scraps = (jsonDecode(scrapt) as List<dynamic>)
        .map((e) => ArticleInfo.fromMap(e as Map<String, dynamic>))
        .toList();
    _record = (jsonDecode(recordt) as List<dynamic>)
        .map((e) => ArticleInfo.fromMap(e as Map<String, dynamic>))
        .toList();
    _filter =
        (jsonDecode(filtert) as List<dynamic>).map((e) => e as String).toList();
    _scrapURLS.addAll(_scraps.map((e) => e.url));
  }

  Future<void> saveScrap() async {
    var scrapt = jsonEncode(_scraps.map((e) => e.toMap()).toList());
    await Hive.box("scraps")
        .put(base64.encode(utf8.encode(name)), scrapt == null ? '[]' : scrapt);
  }

  Future<void> saveRecord() async {
    var recordt = jsonEncode(_record.map((e) => e.toMap()).toList());
    await Hive.box("record").put(
        base64.encode(utf8.encode(name)), recordt == null ? '[]' : recordt);
  }

  Future<void> saveFilter() async {
    var filtert = jsonEncode(_filter);
    await Hive.box("filter").put(
        base64.encode(utf8.encode(name)), filtert == null ? '[]' : filtert);
  }

  List<ArticleInfo> getScraps() {
    return _scraps;
  }

  List<ArticleInfo> getRecord() {
    return _record;
  }

  List<String> getFilter() {
    return _filter;
  }

  Future<void> addScrap(ArticleInfo articleInfo) async {
    _scraps.add(articleInfo);
    _scrapURLS.add(articleInfo.url);
    await saveScrap();
  }

  Future<void> removeScrap(ArticleInfo articleInfo) async {
    _scraps.removeWhere((element) => element.url == articleInfo.url);
    _scrapURLS.remove(articleInfo.url);
    await saveScrap();
  }

  bool isScrapred(String url) {
    return _scrapURLS.contains(url);
  }

  Future<void> addFilter(String filt) async {
    _filter.add(filt);
    await saveFilter();
  }

  Future<void> removeFilter(String filt) async {
    _filter.removeWhere((element) => element == filt);
    await saveFilter();
  }

  Future<void> addRecord(ArticleInfo articleInfo) async {
    _record.add(articleInfo);
    await saveRecord();
  }
}

// Board Session
class BoardManager {
  // static BoardManager instance = BoardManager();

  BoardGroup _group;
  BoardFixed _fixed;
  // List<BoardInfo> _dl = List<BoardInfo>();
  List<ArticleInfo> _articles = List<ArticleInfo>();
  PriorityQueue<ArticleInfo> _queue =
      PriorityQueue<ArticleInfo>((a, b) => b.writeTime.compareTo(a.writeTime));
  // List<ArticleInfo> _scraps = List<ArticleInfo>();
  // HashSet<String> _scrapURLS = HashSet<String>();
  // List<ArticleInfo> _record = List<ArticleInfo>();
  // List<String> _filter = List<String>();

  bool hasInitError = false;

  static Future<BoardManager> get(String groupName) async {
    var bm = BoardManager();
    await bm._initGroup(groupName);
    bm._fixed = BoardFixed(groupName);
    await bm._fixed.initFixed();
    return bm;
  }

  static BoardManager getByGroup(BoardGroup group) {
    var bm = BoardManager();
    bm._group = group;
    return bm;
  }

  BoardFixed getFixed() {
    return _fixed;
  }

  void setFixed(BoardFixed fixed) {
    _fixed = fixed;
  }

  static List<String> getGlobalFilter() {
    var filtert = Hive.box('filter').get('global', defaultValue: '[]');
    if (filtert == '') {
      return List<String>();
    }
    return (jsonDecode(filtert) as List<dynamic>)
        .map((e) => e as String)
        .toList();
  }

  static Future<void> saveGlobalFilter(List<String> filter) async {
    var filtert = jsonEncode(filter);
    await Hive.box("filter").put('global', filtert == null ? '[]' : filtert);
  }

  // static void test() {
  //   // instance.registerBoard(BoardInfo(
  //   //   url: 'https://gall.dcinside.com/board/lists',
  //   //   name: '국내야구 갤러리',
  //   //   extrainfo: {'id': 'baseball_new9', 'exception_mode': 'recommend'},
  //   //   extractor: 'dcinside',
  //   // ));
  //   // instance.registerBoard(BoardInfo(
  //   //   url: 'https://gall.dcinside.com/mgallery/board/lists',
  //   //   name: '중세게임 마이너 갤러리',
  //   //   extrainfo: {'id': 'aoegame', 'exception_mode': 'recommend'},
  //   //   extractor: 'dcinside',
  //   // ));
  //   // instance.registerBoard(BoardInfo(
  //   //   url: 'https://gall.dcinside.com/board/lists',
  //   //   name: '초개념 갤러리',
  //   //   extrainfo: {'id': 'superidea'},
  //   //   extractor: 'dcinside',
  //   // ));
  //   // instance.registerBoard(BoardInfo(
  //   //   url: 'http://web.humoruniv.com/board/humor/list.html',
  //   //   name: '웃긴자료',
  //   //   extrainfo: {'table': 'pds'},
  //   //   extractor: 'huvkr',
  //   // ));
  //   // instance.registerBoard(BoardInfo(
  //   //   url: 'https://arca.live/b/hk3rd',
  //   //   name: '붕괴3rd 채널',
  //   //   extrainfo: {'mode': 'best'},
  //   //   extractor: 'arcalive',
  //   // ));
  //   // instance.registerBoard(BoardInfo(
  //   //   url: 'https://arca.live/b/nymphet',
  //   //   name: '님페트 채널',
  //   //   extrainfo: {},
  //   //   extractor: 'arcalive',
  //   // ));
  //   // instance.registerBoard(BoardInfo(
  //   //   url: 'https://bbs.ruliweb.com/best/humor/hit',
  //   //   name: '유머 힛갤',
  //   //   extrainfo: {},
  //   //   extractor: 'ruliweb',
  //   // ));
  //   // instance.registerBoard(BoardInfo(
  //   //   url: 'https://bbs.ruliweb.com/community/board/300148',
  //   //   name: '정치유머 게시판',
  //   //   extrainfo: {'view_best': '1'},
  //   //   extractor: 'ruliweb',
  //   // ));
  //   // instance.registerBoard(BoardInfo(
  //   //   url: 'https://www.clien.net/service/group/clien_all',
  //   //   // url: 'https://www.clien.net/service/board/park',
  //   //   name: '톺아보기',
  //   //   extrainfo: {'od': 'T33'},
  //   //   // extrainfo: {},
  //   //   extractor: 'clien',
  //   // ));
  // }

  String getName() {
    var s = _group.name.split('|');
    if (s.length > 1) s.removeLast();
    return s.join('|');
  }

  Color getColor() {
    return _group.color;
  }

  String getSubName() {
    return _group.subname;
  }

  Future<void> _initGroup(String group) async {
    var groupt = Hive.box('groups')
        .get(base64.encode(utf8.encode(group)), defaultValue: '');
    // var scrapt = Hive.box('scraps')
    //     .get(base64.encode(utf8.encode(group)), defaultValue: '[]');
    // var recordt = Hive.box('record')
    //     .get(base64.encode(utf8.encode(group)), defaultValue: '[]');
    // var filtert = Hive.box('filter')
    //     .get(base64.encode(utf8.encode(group)), defaultValue: '[]');
    if (group == '구독' && groupt == '') {
      _group = BoardGroup(
        boards: List<BoardInfo>(),
        name: '구독',
        subname: '일반',
        color: Colors.purple,
        subGroups: List<SubGroupInfo>(),
      );
      await saveGroup();
      // return;
    }
    // if (scrapt == '') {
    //   _scraps = List<ArticleInfo>();
    //   await saveScrap();
    // }
    // if (recordt == '') {
    //   _record = List<ArticleInfo>();
    //   await saveRecord();
    // }
    // if (recordt == '') {
    //   _record = List<ArticleInfo>();
    //   await saveRecord();
    // }
    // if (filtert == '') {
    //   _filter = List<String>();
    //   await saveFilter();
    // }
    if (groupt == '') return;

    _group = BoardGroup.fromMap(jsonDecode(groupt) as Map<String, dynamic>);
    // _scraps = (jsonDecode(scrapt) as List<dynamic>)
    //     .map((e) => ArticleInfo.fromMap(e as Map<String, dynamic>))
    //     .toList();
    // _record = (jsonDecode(recordt) as List<dynamic>)
    //     .map((e) => ArticleInfo.fromMap(e as Map<String, dynamic>))
    //     .toList();
    // _filter =
    //     (jsonDecode(filtert) as List<dynamic>).map((e) => e as String).toList();
    // _scrapURLS.addAll(_scraps.map((e) => e.url));
  }

  Future<void> saveGroup() async {
    var groupt = jsonEncode(_group.toMap());
    await Hive.box("groups")
        .put(base64.encode(utf8.encode(_group.name)), groupt);
  }

  // Future<void> saveScrap() async {
  //   var scrapt = jsonEncode(_scraps.map((e) => e.toMap()).toList());
  //   await Hive.box("scraps").put(base64.encode(utf8.encode(_group.name)),
  //       scrapt == null ? '[]' : scrapt);
  // }

  // Future<void> saveRecord() async {
  //   var recordt = jsonEncode(_record.map((e) => e.toMap()).toList());
  //   await Hive.box("record").put(base64.encode(utf8.encode(_group.name)),
  //       recordt == null ? '[]' : recordt);
  // }

  // Future<void> saveFilter() async {
  //   var filtert = jsonEncode(_filter);
  //   await Hive.box("filter").put(base64.encode(utf8.encode(_group.name)),
  //       filtert == null ? '[]' : filtert);
  // }

  // void registerBoard(BoardInfo info) {
  //   _dl.add(info);
  // }

  // void registerBoards(List<BoardInfo> info) {
  //   _dl.addAll(info);
  // }

  List<BoardInfo> getBoards() {
    return _group.boards;
  }

  List<SubGroupInfo> getSubGroups() {
    return _group.subGroups;
  }

  // List<ArticleInfo> getScraps() {
  //   return _scraps;
  // }

  // List<ArticleInfo> getRecord() {
  //   return _record;
  // }

  // List<String> getFilter() {
  //   return _filter;
  // }

  // Future<void> addScrap(ArticleInfo articleInfo) async {
  //   _scraps.add(articleInfo);
  //   _scrapURLS.add(articleInfo.url);
  //   await saveScrap();
  // }

  // Future<void> removeScrap(ArticleInfo articleInfo) async {
  //   _scraps.removeWhere((element) => element.url == articleInfo.url);
  //   _scrapURLS.remove(articleInfo.url);
  //   await saveScrap();
  // }

  // bool isScrapred(String url) {
  //   return _scrapURLS.contains(url);
  // }

  // Future<void> addFilter(String filt) async {
  //   _filter.add(filt);
  //   await saveFilter();
  // }

  // Future<void> removeFilter(String filt) async {
  //   _filter.removeWhere((element) => element == filt);
  //   await saveFilter();
  // }

  // Future<void> addRecord(ArticleInfo articleInfo) async {
  //   _record.add(articleInfo);
  //   await saveRecord();
  // }

  Future<void> deleteBoard(BoardInfo board) async {
    _group.boards.remove(board);
    _articles.removeWhere((element) => element.page.board == board);

    var tq = _queue.removeAll().toList();
    tq.removeWhere((element) => element.page.board == board);
    _queue.clear();
    _queue.addAll(_distinct(tq));

    await saveGroup();
  }

  Future<void> deleteSubGroup(SubGroupInfo subGroup) async {
    _group.subGroups.remove(subGroup);

    await saveGroup();
  }

  List<ArticleInfo> getArticles() {
    return _filterted();
  }

  Future<List<ArticleInfo>> init() async {
    _articles = List<ArticleInfo>();
    _queue = PriorityQueue<ArticleInfo>(
        (a, b) => b.writeTime.compareTo(a.writeTime));

    // Donot use catchError.
    // catchError method block all async tasks.
    await Future.wait(_group.boards.map((board) async {
      // if (!board.isEnabled) return;
      try {
        var ext = ComponentManager.instance.getExtractorByName(board.extractor);
        var causeErr = false;
        var page = await ext.next(board, 0).catchError((e, st) {
          Logger.error('[Board Init Parser] E: ' +
              board.extractor +
              ', U: ' +
              board.url +
              ', X: ' +
              jsonEncode(board.extrainfo) +
              ', MSG: ' +
              e.toString() +
              '\n' +
              st.toString());
          hasInitError = true;
          causeErr = true;
        });
        if (causeErr) return;
        if (page.articles.length == 0) return;
        page.articles.forEach((element) => element.page = page);
        page.articles.sort((x, y) => y.writeTime.compareTo(x.writeTime));
        page.articles.last.isLastArticle = true;
        _queue.addAll(page.articles);
      } catch (e, st) {
        Logger.error('[Board Init] E: ' +
            board.extractor +
            ', U: ' +
            board.url +
            ', X: ' +
            jsonEncode(board.extrainfo) +
            ', MSG: ' +
            e.toString() +
            '\n' +
            st.toString());
        hasInitError = true;
      }
    }));

    _tidy();

    return await next();
  }

  Future<List<ArticleInfo>> refresh() async {
    await Future.wait(_group.boards.map((board) async {
      // if (!board.isEnabled) return;
      try {
        var ext = ComponentManager.instance.getExtractorByName(board.extractor);
        var causeErr = false;
        var page = await ext.next(board, 0).catchError((e, st) {
          Logger.error('[Board Refresh Parser] E: ' +
              board.extractor +
              ', U: ' +
              board.url +
              ', X: ' +
              jsonEncode(board.extrainfo) +
              ', MSG: ' +
              e.toString() +
              '\n' +
              st.toString());
          hasInitError = true;
          causeErr = true;
        });
        if (causeErr) return;
        if (page.articles.length == 0) return;
        page.articles.forEach((element) => element.page = page);
        page.articles.sort((x, y) => y.writeTime.compareTo(x.writeTime));
        page.articles.last.isLastArticle = true;
        _queue.addAll(page.articles);
      } catch (e, st) {
        Logger.error('[Board Refresh] E: ' +
            board.extractor +
            ', U: ' +
            board.url +
            ', X: ' +
            jsonEncode(board.extrainfo) +
            ', MSG: ' +
            e.toString() +
            '\n' +
            st.toString());
      }
    }));

    _tidy();

    var nn = List<ArticleInfo>();

    while (_articles.first.writeTime.compareTo(_queue.first.writeTime) < 0) {
      nn.add(_queue.removeFirst());
    }

    _articles.insertAll(0, nn);

    _tidy();

    return _filterted();
  }

  Future<List<ArticleInfo>> next() async {
    _tidy();

    for (int i = 0; i < 16; i++) {
      if (_queue.length == 0) break;

      var e = _queue.removeFirst();
      _articles.add(e);

      if (e.isLastArticle) await _innerNext(e.page);
    }

    _tidy();

    return _filterted();
  }

  Future<void> _innerNext(PageInfo ppage) async {
    try {
      var ext =
          ComponentManager.instance.getExtractorByName(ppage.board.extractor);
      var causeErr = false;
      var page =
          await ext.next(ppage.board, ppage.offset + 1).catchError((e, st) {
        Logger.error('[Board Next Parser] E: ' +
            ppage.board.extractor +
            ', U: ' +
            ppage.board.url +
            ', X: ' +
            jsonEncode(ppage.board.extrainfo) +
            ', MSG: ' +
            e.toString() +
            '\n' +
            st.toString());
        hasInitError = true;
        causeErr = true;
      });
      if (causeErr) return;
      page.articles.forEach((element) => element.page = page);
      page.articles.sort((x, y) => y.writeTime.compareTo(x.writeTime));
      page.articles.last.isLastArticle = true;
      _queue.addAll(page.articles);
      _tidy();
    } catch (e, st) {
      Logger.error('[Board Next] E: ' +
          ppage.board.extractor +
          ', U: ' +
          ppage.board.url +
          ', X: ' +
          jsonEncode(ppage.board.extrainfo) +
          ', MSG: ' +
          e.toString() +
          '\n' +
          st.toString());
    }
  }

  void tidy() {
    _tidy();
  }

  void _tidy() {
    var ta = List<ArticleInfo>.from(_articles);
    _articles.clear();
    _articles = _distinct(ta);

    var tq = _queue.removeAll().toList();
    _queue.clear();
    _queue.addAll(_distinct(tq));
  }

  List<ArticleInfo> _distinct(List<ArticleInfo> info) {
    var hset = HashSet<String>();
    var ll = List<ArticleInfo>();

    info.forEach((element) {
      if (hset.contains(element.url)) return;
      ll.add(element);
      hset.add(element.url);
    });

    ll.sort((x, y) {
      var cc = y.writeTime.compareTo(x.writeTime);
      if (cc != 0) return cc;
      if (x.info != null &&
          y.info != null &&
          x.page.board == y.page.board &&
          x.page.board.extractor == x.page.board.extractor)
        return int.parse(y.info).compareTo(int.parse(x.info));
      return 0;
    });

    return ll;
  }

  List<ArticleInfo> _filterted() {
    return _articles.where((element) => element.page.board.isEnabled).toList();
  }
}
