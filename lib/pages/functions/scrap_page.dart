// This source code is a part of Project Violet.
// Copyright (C) 2020. rollrat. Licensed under the MIT License.

import 'package:communityexplorer/component/board_manager.dart';
import 'package:communityexplorer/component/interface.dart';
import 'package:communityexplorer/pages/article/article_widget.dart';
import 'package:communityexplorer/pages/left/left_page.dart';
import 'package:communityexplorer/pages/right/right_page.dart';
import 'package:communityexplorer/settings/settings.dart';
import 'package:communityexplorer/widget/inner_drawer.dart';
import 'package:communityexplorer/widget/toast.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class ScrapPage extends StatefulWidget {
  final BoardManager boardManager;

  ScrapPage(this.boardManager);

  @override
  _ScrapPageState createState() => _ScrapPageState();
}

class _ScrapPageState extends State<ScrapPage> {
  // static MobileAdTargetingInfo targetingInfo = MobileAdTargetingInfo(
  //   keywords: <String>['flutterio', 'beautiful apps'],
  //   contentUrl: 'https://flutter.dev',
  //   childDirected: false,
  //   testDevices: <String>[],
  // );

  // BannerAd banner = BannerAd(
  //   adUnitId: BannerAd.testAdUnitId,
  //   size: AdSize.fullBanner,
  //   targetingInfo: targetingInfo,
  //   // listener: (MobileAdEvent event) {
  //   //   print("$event");
  //   // },
  // );

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // banner
    //   ..load()
    //   ..show(
    //     anchorType: AnchorType.bottom,
    //   );
  }

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;

    var scraps = widget.boardManager.getFixed().getScraps();

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.only(top: statusBarHeight + 16),
        child: Column(
          children: [
            Text(
              '스크랩',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Container(
              height: 16,
            ),
            Expanded(
              child: ListView.separated(
                padding: EdgeInsets.zero,
                addAutomaticKeepAlives: false,
                itemBuilder: (c, i) => ArticleWidget(
                  key: ValueKey(scraps[scraps.length - i - 1].url),
                  articleInfo: scraps[scraps.length - i - 1],
                  viewType: Settings.viewType,
                  boardManager: widget.boardManager,
                ),
                itemCount: scraps.length,
                separatorBuilder: (context, index) {
                  return Divider(
                    height: 2,
                  );
                },
              ),
            ),
          ],
        ),
      ),
      // ),
    );
  }
}
