// This source code is a part of Project Violet.
// Copyright (C) 2020. rollrat. Licensed under the MIT License.

import 'dart:ui';

abstract class BoardExtractor {
  bool acceptURL(String url);
  Future<String> tidyURL(String url);
  String fav();
  String extractor();
  String name();
  Color color();
  Future<PageInfo> next(BoardInfo board, int offset);
  List<BoardInfo> best();
  String toMobile(String url);
}

class BoardInfo {
  final String url; // base url
  final String name;
  final Map<String, String> extrainfo;
  final String extractor;
  bool isEnabled = true;

  BoardInfo({
    this.url,
    this.extractor,
    this.name,
    this.extrainfo,
  });

  Map<String, dynamic> toMap() {
    return {
      'url': url,
      'name': name,
      'extrainfo': extrainfo,
      'extractor': extractor,
      'isenabled': isEnabled
    };
  }

  factory BoardInfo.fromMap(Map<String, dynamic> map) {
    var board = BoardInfo(
        url: map['url'], name: map['name'], extractor: map['extractor']);
    board.isEnabled = map['isenabled'];
    return board;
  }
}

class BoardGroup {
  final List<BoardInfo> boards;
  final String name;
  final String subname;
  final Color color;

  BoardGroup({
    this.boards,
    this.name,
    this.subname,
    this.color,
  });

  Map<String, dynamic> toMap() {
    return {
      'boards': boards.map((e) => e.toMap()),
      'name': name,
      'subname': subname,
      'color': color.value,
    };
  }

  factory BoardGroup.fromMap(Map<String, dynamic> map) {
    return BoardGroup(
      boards: map['boards'].map((e) => BoardInfo.fromMap(e)).toList(),
      name: map['name'],
      subname: map['subname'],
      color: Color(
        map['color'],
      ),
    );
  }
}

class PageInfo {
  final BoardInfo board;
  final List<ArticleInfo> articles;
  final int offset;

  PageInfo({
    this.articles,
    this.board,
    this.offset,
  });
}

class ArticleInfo {
  final String url;
  final String title;
  final int comment;
  final String thumbnail;
  final int upvote;
  final int downvote;
  final int views;
  final DateTime writeTime;
  final String nickname;
  final String preface;
  final String info; // Id, No etc...
  final bool hasImage;
  final bool hasVideo;
  bool isLastArticle = false; // on page
  PageInfo page;

  ArticleInfo({
    this.comment,
    this.downvote,
    this.nickname,
    this.preface,
    this.thumbnail,
    this.title,
    this.upvote,
    this.url,
    this.views,
    this.writeTime,
    this.info,
    this.hasImage,
    this.hasVideo,
  });
}
