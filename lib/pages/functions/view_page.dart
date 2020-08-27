// This source code is a part of Project Violet.
// Copyright (C) 2020. rollrat. Licensed under the MIT License.

import 'package:communityexplorer/component/board_manager.dart';
import 'package:communityexplorer/component/interface.dart';
import 'package:communityexplorer/network/wrapper.dart';
import 'package:communityexplorer/pages/functions/report_page.dart';
import 'package:communityexplorer/widget/toast.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_inappwebview/flutter_inappwebview.dart';
// import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:share/share.dart';
import 'package:webview_flutter/webview_flutter.dart';
// import 'package:webview_flutter/webview_flutter.dart';

class ViewPage extends StatefulWidget {
  final String url;
  final Color color;
  final BoardManager boardManager;
  final BoardExtractor extractor;
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
              onPressed: () async {
                await showDialog(
                  context: context,
                  child: ReportPage(articleInfo: widget.articleInfo),
                );
              },
            ),
            new IconButton(
              icon: new Icon(Icons.share),
              tooltip: '공유',
              onPressed: () async {
                Share.share(widget.url);
              },
            ),
            new IconButton(
              icon: new Icon(
                  widget.boardManager.isScrapred(widget.articleInfo.url)
                      ? Icons.star
                      : Icons.star_border),
              tooltip: '스크랩',
              onPressed: () async {
                if (!widget.boardManager.isScrapred(widget.articleInfo.url)) {
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
                } else {
                  await widget.boardManager.removeScrap(widget.articleInfo);
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
              },
            ),
          ],
        ),
      ),
      body: WebView(
        initialUrl: widget.url,
        // url: widget.url,
        // appCacheEnabled: true,
        userAgent: HttpWrapper.mobileUserAgent,
        javascriptMode: JavascriptMode.unrestricted,
        // withOverviewMode: true,
        // useWideViewPort: true,
        // hidden: hidden,

        // body: SafeArea(
        //   // child: InAppWebView(
        //   //   initialUrl: widget.url,
        //   //   // clearCache: false,
        //   //   // javascriptMode: JavascriptMode.unrestricted,
        //   // ),
        //   child: WebviewScaffold(
        //     url: widget.url,
        //     withZoom: true,
        //   ),
        // ),
      ),
    );
  }
}
