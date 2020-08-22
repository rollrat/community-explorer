// This source code is a part of Project Violet.
// Copyright (C) 2020. rollrat. Licensed under the MIT License.

import 'dart:collection';

import 'package:collection/collection.dart';
import 'package:communityexplorer/component/component_manager.dart';
import 'package:communityexplorer/component/interface.dart';

class BoardManager1 {
  static BoardManager1 instance = BoardManager1();

  List<BoardInfo> _dl = List<BoardInfo>();
  List<PageInfo> _pages = List<PageInfo>();
  List<ArticleInfo> _articles = List<ArticleInfo>();

  void registerBoard(BoardInfo info) {
    _dl.add(info);
  }

  void registerBoards(List<BoardInfo> info) {
    _dl.addAll(info);
  }

  Future<List<ArticleInfo>> init() async {
    _articles = List<ArticleInfo>();
    _pages = List<PageInfo>();

    await Future.wait(_dl.map((board) async {
      var ext = ComponentManager.instance.getExtractorByName(board.extractor);
      var page = await ext.next(board, 0);
      _pages.add(page);
      page.articles.forEach((element) => element.page = page);
      _articles.addAll(page.articles);
    }));

    _tidy();
    return _articles.toList();
  }

  Future<List<ArticleInfo>> refresh() async {
    await Future.wait(_dl.map((board) async {
      var ext = ComponentManager.instance.getExtractorByName(board.extractor);
      var page = await ext.next(board, 0);
      page.articles.forEach((element) => element.page = page);
      _articles.addAll(page.articles);
    }));

    _tidy();
    return _articles.toList();
  }

  Future<List<ArticleInfo>> next() async {
    await _innerNext();
    return _articles.toList();
  }

  Future<void> _innerNext() async {
    var tpages = List.from(_pages);
    _pages.clear();

    await Future.wait(tpages.map((page) async {
      var ext =
          ComponentManager.instance.getExtractorByName(page.board.extractor);
      var np = await ext.next(page.board, page.offset + 1);

      _pages.add(np);
      np.articles.forEach((element) => element.page = np);
      _articles.addAll(np.articles);
    }));

    _tidy();
  }

  void _tidy() {
    var hset = HashSet<String>();
    var ll = List<ArticleInfo>();

    _articles.forEach((element) {
      if (hset.contains(element.url)) return;
      ll.add(element);
      hset.add(element.url);
    });

    _articles = ll;
    _articles.sort((x, y) => y.writeTime.compareTo(x.writeTime));
  }
}

class BoardManager {
  static BoardManager instance = BoardManager();

  List<BoardInfo> _dl = List<BoardInfo>();
  List<ArticleInfo> _articles = List<ArticleInfo>();
  PriorityQueue<ArticleInfo> _queue =
      PriorityQueue<ArticleInfo>((a, b) => b.writeTime.compareTo(a.writeTime));

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
    // instance.registerBoard(BoardInfo(
    //   url: 'https://gall.dcinside.com/board/lists',
    //   name: '초개념 갤러리',
    //   extrainfo: {'id': 'superidea'},
    //   extractor: 'dcinside',
    // ));
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
  }

  void registerBoard(BoardInfo info) {
    _dl.add(info);
  }

  void registerBoards(List<BoardInfo> info) {
    _dl.addAll(info);
  }

  Future<List<ArticleInfo>> init() async {
    _articles = List<ArticleInfo>();
    _queue = PriorityQueue<ArticleInfo>(
        (a, b) => b.writeTime.compareTo(a.writeTime));

    await Future.wait(_dl.map((board) async {
      var ext = ComponentManager.instance.getExtractorByName(board.extractor);
      var page = await ext.next(board, 0);
      page.articles.forEach((element) => element.page = page);
      page.articles.sort((x, y) => y.writeTime.compareTo(x.writeTime));
      page.articles.last.isLastArticle = true;
      _queue.addAll(page.articles);
    }));

    _tidy();

    return await next();
  }

  Future<List<ArticleInfo>> refresh() async {
    await Future.wait(_dl.map((board) async {
      var ext = ComponentManager.instance.getExtractorByName(board.extractor);
      var page = await ext.next(board, 0);
      page.articles.forEach((element) => element.page = page);
      page.articles.sort((x, y) => y.writeTime.compareTo(x.writeTime));
      page.articles.last.isLastArticle = true;
      _queue.addAll(page.articles);
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
    var ext =
        ComponentManager.instance.getExtractorByName(ppage.board.extractor);
    var page = await ext.next(ppage.board, ppage.offset + 1);
    page.articles.forEach((element) => element.page = page);
    page.articles.sort((x, y) => y.writeTime.compareTo(x.writeTime));
    page.articles.last.isLastArticle = true;
    _queue.addAll(page.articles);
  }

  void _tidy() {
    var ta = List.from(_articles);
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
