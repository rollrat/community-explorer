// This source code is a part of Project Violet.
// Copyright (C) 2020. rollrat. Licensed under the MIT License.

import 'dart:collection';
import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:communityexplorer/component/component_manager.dart';
import 'package:communityexplorer/component/interface.dart';
import 'package:communityexplorer/log/log.dart';

class BoardManager {
  static BoardManager instance = BoardManager();

  List<Subscriable> _dl = List<Subscriable>();
  List<ArticleInfo> _articles = List<ArticleInfo>();
  PriorityQueue<ArticleInfo> _queue =
      PriorityQueue<ArticleInfo>((a, b) => b.writeTime.compareTo(a.writeTime));

  bool hasInitError = false;

  static void test() {
    instance.registerBoard(BoardInfo(
      url: 'https://gall.dcinside.com/board/lists',
      name: '국내야구 갤러리',
      extrainfo: {'id': 'baseball_new9', 'exception_mode': 'recommend'},
      extractor: 'dcinside',
    ));
    instance.registerBoard(BoardInfo(
      url: 'https://gall.dcinside.com/mgallery/board/lists',
      name: '중세게임 마이너 갤러리',
      extrainfo: {'id': 'aoegame', 'exception_mode': 'recommend'},
      extractor: 'dcinside',
    ));
    instance.registerBoard(BoardInfo(
      url: 'https://gall.dcinside.com/board/lists',
      name: '초개념 갤러리',
      extrainfo: {'id': 'superidea'},
      extractor: 'dcinside',
    ));
    instance.registerBoard(BoardInfo(
      url: 'http://web.humoruniv.com/board/humor/list.html',
      name: '웃긴자료',
      extrainfo: {'table': 'pds'},
      extractor: 'huvkr',
    ));
    instance.registerBoard(BoardInfo(
      url: 'https://arca.live/b/hk3rd',
      name: '붕괴3rd 채널',
      extrainfo: {'mode': 'best'},
      extractor: 'arcalive',
    ));
    instance.registerBoard(BoardInfo(
      url: 'https://arca.live/b/nymphet',
      name: '님페트 채널',
      extrainfo: {},
      extractor: 'arcalive',
    ));
    instance.registerBoard(BoardInfo(
      url: 'https://bbs.ruliweb.com/best/humor/hit',
      name: '유머 힛갤',
      extrainfo: {},
      extractor: 'ruliweb',
    ));
    instance.registerBoard(BoardInfo(
      url: 'https://bbs.ruliweb.com/community/board/300148',
      name: '정치유머 게시판',
      extrainfo: {'view_best': '1'},
      extractor: 'ruliweb',
    ));

    instance.registerBoard(BoardInfo(
      url: 'https://www.clien.net/service/group/clien_all',
      // url: 'https://www.clien.net/service/board/park',
      name: '톺아보기',
      extrainfo: {'od': 'T33'},
      // extrainfo: {},
      extractor: 'clien',
    ));
  }

  void registerBoard(Subscriable info) {
    _dl.add(info);
  }

  void registerBoards(List<Subscriable> info) {
    _dl.addAll(info);
  }

  List<Subscriable> getBoards() {
    return _dl;
  }

  Future<List<ArticleInfo>> init() async {
    _articles = List<ArticleInfo>();
    _queue = PriorityQueue<ArticleInfo>(
        (a, b) => b.writeTime.compareTo(a.writeTime));

    // Donot use catchError.
    // catchError method block all async tasks.
    await Future.wait(_dl.map((sub) async {
      if (sub is BoardInfo) {
        var board = sub;
        try {
          var ext =
              ComponentManager.instance.getExtractorByName(board.extractor);
          var page = await ext.next(board, 0);
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
      }
    }));

    _tidy();

    return await next();
  }

  Future<List<ArticleInfo>> refresh() async {
    await Future.wait(_dl.map((sub) async {
      if (sub is BoardInfo) {
        var board = sub;
        try {
          var ext =
              ComponentManager.instance.getExtractorByName(board.extractor);
          var page = await ext.next(board, 0);
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
      }
    }));

    _tidy();

    var nn = List<ArticleInfo>();

    while (_articles.first.writeTime.compareTo(_queue.first.writeTime) < 0) {
      nn.add(_queue.removeFirst());
    }

    _articles.insertAll(0, nn);

    _tidy();

    return _articles;
  }

  Future<List<ArticleInfo>> next() async {
    _tidy();

    for (int i = 0; i < 16; i++) {
      var e = _queue.removeFirst();
      _articles.add(e);

      if (e.isLastArticle) await _innerNext(e.page);
    }
    return _articles;
  }

  Future<void> _innerNext(PageInfo ppage) async {
    try {
      var ext =
          ComponentManager.instance.getExtractorByName(ppage.board.extractor);
      var page = await ext.next(ppage.board, ppage.offset + 1);
      page.articles.forEach((element) => element.page = page);
      page.articles.sort((x, y) => y.writeTime.compareTo(x.writeTime));
      page.articles.last.isLastArticle = true;
      _queue.addAll(page.articles);
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
}
