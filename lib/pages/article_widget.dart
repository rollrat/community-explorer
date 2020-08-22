// This source code is a part of Project Violet.
// Copyright (C) 2020. rollrat. Licensed under the MIT License.

import 'dart:ui';

import 'package:communityexplorer/component/board_manager.dart';
import 'package:communityexplorer/component/component_manager.dart';
import 'package:communityexplorer/component/interface.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
// import 'package:intl/intl.Dart';

class ArticleWidget extends StatefulWidget {
  final ArticleInfo articleInfo;

  ArticleWidget({this.articleInfo});

  @override
  _ArticleWidgetState createState() => _ArticleWidgetState();
}

class _ArticleWidgetState extends State<ArticleWidget> {
  @override
  Widget build(BuildContext context) {
    var windowWidth = MediaQuery.of(context).size.width;
    return GestureDetector(
      child: SizedBox(
        height: 80,
        child: Row(
          children: [
            Container(
              width: 4,
            ),
            widget.articleInfo.thumbnail != null
                ? SizedBox(
                    width: 70,
                    child: Image.network(
                      widget.articleInfo.thumbnail,
                      // width: 70,
                      fit: BoxFit.cover,
                    ))
                : Container(),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: Text(
                        widget.articleInfo.title,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold),
                        // style: TextStyle(),
                      ),
                    ),
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(MdiIcons.thumbUpOutline, size: 15),
                          Container(width: 2),
                          Text(numberWithComma(widget.articleInfo.upvote)),
                          Text('·'),
                          Icon(MdiIcons.commentOutline, size: 15),
                          Container(width: 2),
                          Text(numberWithComma(widget.articleInfo.comment)),
                          Text('·'),
                          Icon(MdiIcons.magnify, size: 15),
                          Container(width: 1),
                          Text(numberWithComma(widget.articleInfo.views)),
                          widget.articleInfo.hasImage
                              ? Icon(MdiIcons.image, size: 15)
                              : Container(),
                          widget.articleInfo.hasVideo
                              ? Icon(MdiIcons.video, size: 15)
                              : Container(),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Text(ComponentManager.instance
                          //     .getExtractorByName(
                          //         widget.articleInfo.page.board.extractor)
                          //     .name()),
                          Image.network(
                            ComponentManager.instance
                                .getExtractorByName(
                                    widget.articleInfo.page.board.extractor)
                                .fav(),
                            width: 18,
                          ),
                          Text('·'),
                          Text(widget.articleInfo.page.board.name),
                          Text('·'),
                          Text(DateFormat('yyyy-MM-dd kk:mm')
                              .format(widget.articleInfo.writeTime)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      onTap: () async {
        var url = ComponentManager.instance
            .getExtractorByName(widget.articleInfo.page.board.extractor)
            .toMobile(widget.articleInfo.url);
        if (await canLaunch(url)) {
          await launch(url);
        }
      },
    );
  }

  String numberWithComma(int param) {
    return new NumberFormat('###,###,###,###')
        .format(param)
        .replaceAll(' ', '');
  }
}
