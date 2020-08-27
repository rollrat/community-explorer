// This source code is a part of Project Violet.
// Copyright (C) 2020. rollrat. Licensed under the MIT License.

import 'dart:ui';

import 'package:communityexplorer/component/board_manager.dart';
import 'package:communityexplorer/component/component_manager.dart';
import 'package:communityexplorer/component/interface.dart';
import 'package:communityexplorer/pages/article/article_menu.dart';
import 'package:communityexplorer/pages/functions/report_page.dart';
import 'package:communityexplorer/pages/functions/view_page.dart';
import 'package:communityexplorer/settings/settings.dart';
import 'package:communityexplorer/widget/toast.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
// import 'package:intl/intl.Dart';

class ArticleWidget extends StatefulWidget {
  final ArticleInfo articleInfo;
  final BoardManager boardManager;
  final int viewType;

  ArticleWidget({Key key, this.articleInfo, this.viewType, this.boardManager})
      : super(key: key);

  @override
  _ArticleWidgetState createState() => _ArticleWidgetState();
}

class _ArticleWidgetState extends State<ArticleWidget> {
  bool viewed;
  bool scraped;

  @override
  void initState() {
    viewed =
        Hive.box('viewed').get(widget.articleInfo.url, defaultValue: false);
    scraped = widget.boardManager.isScrapred(widget.articleInfo.url);
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
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
          ),
          scraped
              ? Icon(
                  Icons.star,
                  color: Settings.themeWhat
                      ? Colors.yellow
                      : Colors.yellow.shade700,
                )
              : Container(),
        ],
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
                      .getExtractorByName((widget.articleInfo.page != null
                          ? widget.articleInfo.page.board.extractor
                          : widget.articleInfo.extractor))
                      .fav(),
                  width: 16,
                )
              : Container(),
          widget.viewType == 1
              ? Text(
                  '·' +
                      (widget.articleInfo.page != null
                          ? widget.articleInfo.page.board.name
                          : widget.articleInfo.name) +
                      '·',
                  style: TextStyle(fontSize: widget.viewType == 0 ? 15 : 12))
              : Container(),

          //
          Container(width: widget.viewType == 1 ? 4 : 0),
          Icon(MdiIcons.thumbUpOutline, size: widget.viewType == 0 ? 15 : 12),
          Container(width: 2),
          Text(numberWithComma(widget.articleInfo.upvote),
              style: TextStyle(fontSize: widget.viewType == 0 ? 15 : 12)),

          //
          Text('·', style: TextStyle(fontSize: widget.viewType == 0 ? 15 : 12)),
          Icon(MdiIcons.commentOutline, size: widget.viewType == 0 ? 15 : 12),
          Container(width: 2),
          Text(numberWithComma(widget.articleInfo.comment),
              style: TextStyle(fontSize: widget.viewType == 0 ? 15 : 12)),

          //
          widget.articleInfo.views != null
              ? Text('·',
                  style: TextStyle(fontSize: widget.viewType == 0 ? 15 : 12))
              : Container(),
          widget.articleInfo.views != null
              ? Icon(MdiIcons.magnify, size: widget.viewType == 0 ? 15 : 12)
              : Container(),
          widget.articleInfo.views != null ? Container(width: 1) : Container(),
          widget.articleInfo.views != null
              ? Text(numberWithComma(widget.articleInfo.views),
                  style: TextStyle(fontSize: widget.viewType == 0 ? 15 : 12))
              : Container(),

          //
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
                .getExtractorByName((widget.articleInfo.page != null
                    ? widget.articleInfo.page.board.extractor
                    : widget.articleInfo.extractor))
                .fav(),
            width: 18,
          ),
          Text('·' +
              (widget.articleInfo.page != null
                  ? widget.articleInfo.page.board.name
                  : widget.articleInfo.name) +
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
            var extractor = ComponentManager.instance.getExtractorByName(
                (widget.articleInfo.page != null
                    ? widget.articleInfo.page.board.extractor
                    : widget.articleInfo.extractor));

            var url = extractor.toMobile(widget.articleInfo.url);

            Hive.box('viewed').put(widget.articleInfo.url, true);
            await widget.boardManager.addRecord(widget.articleInfo);
            await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ViewPage(
                        url: url,
                        color: extractor.color(),
                        extractor: extractor,
                        boardManager: widget.boardManager,
                        articleInfo: widget.articleInfo,
                      )),
            );
            scraped = widget.boardManager.isScrapred(widget.articleInfo.url);
            setState(() {
              viewed = true;
            });

            // if (await canLaunch(url)) {
            //   await launch(url);
            //   Hive.box('viewed').put(widget.articleInfo.url, true);
            //   await widget.boardManager.addRecord(widget.articleInfo);
            //   Future.delayed(Duration(seconds: 1)).then((value) {
            //     setState(() {
            //       viewed = true;
            //     });
            //   });
            // }
          },
          onLongPress: () async {
            var v = await showDialog(
              context: context,
              child: ArticleSelector(
                  widget.boardManager.isScrapred(widget.articleInfo.url)),
            );

            if (v == 0) {
              if (!widget.boardManager.isScrapred(widget.articleInfo.url)) {
                await widget.boardManager.addScrap(widget.articleInfo);
                scraped = true;
                FlutterToast(context).showToast(
                  child: ToastWrapper(
                    isCheck: true,
                    isWarning: false,
                    msg: '스크랩되었습니다!',
                  ),
                  gravity: ToastGravity.BOTTOM,
                  toastDuration: Duration(seconds: 4),
                );
              } else {
                await widget.boardManager.removeScrap(widget.articleInfo);
                scraped = false;
                FlutterToast(context).showToast(
                  child: ToastWrapper(
                    isCheck: true,
                    isWarning: false,
                    msg: '스크랩이 취소되었습니다!',
                  ),
                  gravity: ToastGravity.BOTTOM,
                  toastDuration: Duration(seconds: 4),
                );
              }
              setState(() {});
            } else if (v == 2) {
              await showDialog(
                context: context,
                child: ReportPage(articleInfo: widget.articleInfo),
              );
            }
          },
        ),
      ),
    );
  }
}
