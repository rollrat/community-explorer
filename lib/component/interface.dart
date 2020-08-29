// This source code is a part of Project Violet.
// Copyright (C) 2020. rollrat. Licensed under the MIT License.

import 'dart:convert';
import 'dart:ui';

import 'package:communityexplorer/download/download_task.dart';

abstract class BoardExtractor {
  bool acceptURL(String url);
  Future<String> tidyURL(String url);
  String fav();
  String extractor();
  String name();
  String shortName();
  Color color();
  Future<PageInfo> next(BoardInfo board, int offset);
  List<BoardInfo> best();
  String toMobile(String url);
  // 게시글에서 모든 영상파일 추출
  Future<List<DownloadTask>> extractMedia(String url);
}

class BoardInfo {
  final String url; // base url
  final String name;
  final Map<String, dynamic> extrainfo;
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
      url: map['url'],
      name: map['name'],
      extractor: map['extractor'],
      extrainfo: map['extrainfo'] as Map<String, dynamic>,
    );
    board.isEnabled = map['isenabled'];
    return board;
  }
}

class SubGroupInfo {
  final String name;
  final String subname;
  final Color color;

  SubGroupInfo({this.name, this.subname, this.color});

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'subname': subname,
      'color': color.value,
    };
  }

  factory SubGroupInfo.fromMap(Map<String, dynamic> map) {
    return SubGroupInfo(
      name: map['name'],
      subname: map['subname'],
      color: Color(
        map['color'],
      ),
    );
  }
}

class BoardGroup {
  final List<BoardInfo> boards;
  final String name;
  final String subname;
  final Color color;
  final List<SubGroupInfo> subGroups;

  BoardGroup({
    this.boards,
    this.name,
    this.subname,
    this.color,
    this.subGroups,
  });

  Map<String, dynamic> toMap() {
    return {
      'boards': boards.map((e) => e.toMap()).toList(),
      'name': name,
      'subname': subname,
      'color': color.value,
      'subgroups': subGroups.map((e) => e.toMap()).toList(),
    };
  }

  factory BoardGroup.fromMap(Map<String, dynamic> map) {
    return BoardGroup(
      boards: (map['boards'] as List<dynamic>)
          .map((e) => BoardInfo.fromMap(e as Map<String, dynamic>))
          .toList(),
      name: map['name'],
      subname: map['subname'],
      color: Color(
        map['color'],
      ),
      subGroups: (map['subgroups'] as List<dynamic>)
          .map((e) => SubGroupInfo.fromMap(e as Map<String, dynamic>))
          .toList(),
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
  String url;
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
  String extractor;
  String name;

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
    // nrq
    this.extractor,
    this.name,
  });

  Map<String, dynamic> toMap() {
    return {
      'comment': comment,
      'downvote': downvote,
      'nickname': nickname,
      'preface': preface,
      'thumbnail': thumbnail,
      'title': title,
      'upvote': upvote,
      'url': url,
      'views': views,
      'writetime': writeTime.toString(),
      'hasimage': hasImage,
      'hasvideo': hasVideo,
      'extractor': page != null ? page.board.extractor : extractor,
      'name': page != null ? page.board.name : name,
    };
  }

  factory ArticleInfo.fromMap(Map<String, dynamic> map) {
    return ArticleInfo(
      comment: map['comment'],
      downvote: map['downvote'],
      nickname: map['nickname'],
      preface: map['preface'],
      thumbnail: map['thumbnail'],
      title: map['title'],
      upvote: map['upvote'],
      url: map['url'],
      views: map['views'],
      writeTime: DateTime.parse(map['writetime']),
      info: map['info'],
      hasImage: map['hasimage'],
      hasVideo: map['hasvideo'],
      extractor: map['extractor'],
      name: map['name'],
    );
  }
}

abstract class BoardData {
  bool accept(String name);
  List<BoardInfo> getLists();
  List<String> searchs();
  BoardInfo getBoardFromName(String name);
  // URL 쿼리 부가옵션 정보들을 가져옵니다.
  List<String> extraOptions();
  // 클래스/말머리/카테고리를 사용할 수 있는 게시판인지 확인합니다.
  Future<bool> supportClass(String html);
  Future<List<String>> getClasses(String html);
}
