// This source code is a part of Project Violet.
// Copyright (C) 2020. rollrat. Licensed under the MIT License.

import 'dart:ui';

import 'package:communityexplorer/component/board_manager.dart';
import 'package:communityexplorer/component/component_manager.dart';
import 'package:communityexplorer/component/interface.dart';
import 'package:communityexplorer/settings/settings.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
// import 'package:intl/intl.Dart';

class ArticleWidget extends StatefulWidget {
  final ArticleInfo articleInfo;
  final int viewType;

  ArticleWidget({Key key, this.articleInfo, this.viewType}) : super(key: key);

  @override
  _ArticleWidgetState createState() => _ArticleWidgetState();
}

class _ArticleWidgetState extends State<ArticleWidget> {
  bool viewed;

  @override
  void initState() {
    viewed =
        Hive.box('viewed').get(widget.articleInfo.url, defaultValue: false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // var windowWidth = MediaQuery.of(context).size.width;

    var display = AnimatedContainer(
      duration: Duration(milliseconds: 300),
      height: widget.viewType == 0 ? 80 : 50,
      child: Stack(
        children: <Widget>[
          _body(),
          _inkwell(),
        ],
      ),
    );

    if (viewed) {
      return ColorFiltered(
        colorFilter: ColorFilter.mode(
          Settings.themeWhat ? Colors.grey.shade800 : Colors.grey.shade300,
          BlendMode.saturation,
        ),
        child: display,
      );
    }

    return display;
  }

  String numberWithComma(int param) {
    return new NumberFormat('###,###,###,###')
        .format(param)
        .replaceAll(' ', '');
  }

  _body() {
    return Positioned.fill(
      bottom: 0.0,
      child: Row(
        children: [
          Container(
            width: 4,
          ),
          _thumbnail(),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: 8, vertical: widget.viewType == 0 ? 6 : 3),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _title(),
                  _state(),
                  widget.viewType == 0 ? _info() : Container(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  _thumbnail() {
    return widget.articleInfo.thumbnail != null
        ? AnimatedContainer(
            child: Image.network(
              widget.articleInfo.thumbnail,
              fit: BoxFit.cover,
            ),
            width: widget.viewType == 0 ? 80 : 50,
            height: widget.viewType == 0 ? 80 : 50,
            duration: Duration(milliseconds: 300),
          )
        : Container();
  }

  _title() {
    return Expanded(
      child: Text(
        widget.articleInfo.title,
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
        style: viewed
            ? TextStyle(
                fontSize: widget.viewType == 0 ? 15 : 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey)
            : TextStyle(
                fontSize: widget.viewType == 0 ? 15 : 14,
                fontWeight: FontWeight.bold),
        // style: TextStyle(),
      ),
    );
  }

  _state() {
    return Expanded(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          widget.viewType == 1
              ? Image.network(
                  ComponentManager.instance
                      .getExtractorByName(
                          widget.articleInfo.page.board.extractor)
                      .fav(),
                  width: 16,
                )
              : Container(),
          widget.viewType == 1
              ? Text('·' + widget.articleInfo.page.board.name + '·',
                  style: TextStyle(fontSize: widget.viewType == 0 ? 15 : 12))
              : Container(),
          Container(width: widget.viewType == 1 ? 4 : 0),
          Icon(MdiIcons.thumbUpOutline, size: widget.viewType == 0 ? 15 : 12),
          Container(width: 2),
          Text(numberWithComma(widget.articleInfo.upvote),
              style: TextStyle(fontSize: widget.viewType == 0 ? 15 : 12)),
          Text('·', style: TextStyle(fontSize: widget.viewType == 0 ? 15 : 12)),
          Icon(MdiIcons.commentOutline, size: widget.viewType == 0 ? 15 : 12),
          Container(width: 2),
          Text(numberWithComma(widget.articleInfo.comment),
              style: TextStyle(fontSize: widget.viewType == 0 ? 15 : 12)),
          Text('·', style: TextStyle(fontSize: widget.viewType == 0 ? 15 : 12)),
          Icon(MdiIcons.magnify, size: widget.viewType == 0 ? 15 : 12),
          Container(width: 1),
          Text(numberWithComma(widget.articleInfo.views),
              style: TextStyle(fontSize: widget.viewType == 0 ? 15 : 12)),
          widget.articleInfo.hasImage
              ? Icon(MdiIcons.image, size: widget.viewType == 0 ? 15 : 12)
              : Container(),
          widget.articleInfo.hasVideo
              ? Icon(MdiIcons.video, size: widget.viewType == 0 ? 15 : 12)
              : Container(),
          widget.viewType == 1
              ? Text(
                  '·' +
                      (DateTime.now().difference(widget.articleInfo.writeTime) <
                              Duration(days: 1)
                          ? DateFormat('kk:mm')
                              .format(widget.articleInfo.writeTime)
                          : DateFormat('yyyy-MM-dd kk:mm')
                              .format(widget.articleInfo.writeTime)),
                  style: TextStyle(fontSize: 12))
              : Container(),
        ],
      ),
    );
  }

  _info() {
    return Expanded(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Text(ComponentManager.instance
          //     .getExtractorByName(
          //         widget.articleInfo.page.board.extractor)
          //     .name()),
          Image.network(
            ComponentManager.instance
                .getExtractorByName(widget.articleInfo.page.board.extractor)
                .fav(),
            width: 18,
          ),
          Text('·' +
              widget.articleInfo.page.board.name +
              '·' +
              DateFormat('yyyy-MM-dd kk:mm')
                  .format(widget.articleInfo.writeTime)),
        ],
      ),
    );
  }

  _inkwell() {
    return Positioned.fill(
      child: new Material(
        color: Colors.transparent,
        child: new InkWell(
          onTap: () async {
            var url = ComponentManager.instance
                .getExtractorByName(widget.articleInfo.page.board.extractor)
                .toMobile(widget.articleInfo.url);
            if (await canLaunch(url)) {
              await launch(url);
              Hive.box('viewed').put(widget.articleInfo.url, true);
              Future.delayed(Duration(seconds: 1)).then((value) {
                setState(() {
                  viewed = true;
                });
              });
            }
          },
        ),
      ),
    );
  }
}
