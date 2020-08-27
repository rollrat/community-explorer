// This source code is a part of Project Violet.
// Copyright (C) 2020. rollrat. Licensed under the MIT License.

import 'package:communityexplorer/component/board_manager.dart';
import 'package:communityexplorer/component/interface.dart';
import 'package:communityexplorer/widget/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
// import 'package:webview_flutter/webview_flutter.dart';

class ViewPage extends StatefulWidget {
  final String url;
  final Color color;
  final BoardManager boardManager;
  final String extractor;
  final ArticleInfo articleInfo;

  ViewPage({
    this.url,
    this.color,
    this.boardManager,
    this.extractor,
    this.articleInfo,
  });

  @override
  _ViewPageState createState() => _ViewPageState();
}

class _ViewPageState extends State<ViewPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(50.0),
        child: AppBar(
          backgroundColor: widget.color,
          actions: [
            new IconButton(
              icon: new Icon(MdiIcons.download),
              tooltip: '다운로드',
              onPressed: () => {},
            ),
            new IconButton(
              icon: new Icon(MdiIcons.alert),
              tooltip: '신고',
              onPressed: () => {},
            ),
            new IconButton(
              icon: new Icon(Icons.share),
              tooltip: '공유',
              onPressed: () => {},
            ),
            new IconButton(
              icon: new Icon(widget.boardManager.isScrapred(widget.url)
                  ? Icons.star
                  : Icons.star_border),
              tooltip: '스크랩',
              onPressed: () async {
                if (!widget.boardManager.isScrapred(widget.url)) {
                  await widget.boardManager.addScrap(widget.articleInfo);
                  FlutterToast(context).showToast(
                    child: ToastWrapper(
                      isCheck: true,
                      isWarning: false,
                      msg: '스크랩되었습니다!',
                    ),
                    gravity: ToastGravity.BOTTOM,
                    toastDuration: Duration(seconds: 4),
                  );
                }

                setState(() {});
              },
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: InAppWebView(
          initialUrl: widget.url,
          // clearCache: false,
          // javascriptMode: JavascriptMode.unrestricted,
        ),
      ),
    );
  }
}
