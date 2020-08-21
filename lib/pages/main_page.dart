// This source code is a part of Project Violet.
// Copyright (C) 2020. rollrat. Licensed under the MIT License.

import 'package:communityexplorer/component/interface.dart';
import 'package:communityexplorer/pages/left_page.dart';
import 'package:communityexplorer/pages/right_page.dart';
import 'package:communityexplorer/settings/settings.dart';
import 'package:communityexplorer/widget/inner_drawer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final GlobalKey<InnerDrawerState> _innerDrawerKey =
      GlobalKey<InnerDrawerState>();

  List<ArticleInfo> articles;

  List<String> items = ["1", "2", "3", "4", "5", "6", "7", "8"];
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  void _onRefresh() async {
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    // if failed,use refreshFailed()
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    // if failed,use loadFailed(),if no data return,use LoadNodata()
    items.add((items.length + 1).toString());
    if (mounted) setState(() {});
    _refreshController.loadComplete();
  }

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final width = MediaQuery.of(context).size.width;
    final height =
        MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top;
    return InnerDrawer(
      key: _innerDrawerKey,
      onTapClose: true, // default false
      swipe: true, // default true
      colorTransitionChild: Colors.cyan, // default Color.black54
      colorTransitionScaffold: Colors.black12, // default Color.black54

      //When setting the vertical offset, be sure to use only top or bottom
      offset: IDOffset.only(
        bottom: 0.00,
        left: (width - 130) / width,
        right: (width - 60) / width,
      ),

      scale: IDOffset.horizontal(1.0), // set the offset in both directions
      // leftOff

      proportionalChildArea: false, // default true
      borderRadius: 0, // default 0
      rightAnimationType: InnerDrawerAnimation.linear, // default static
      leftAnimationType: InnerDrawerAnimation.linear,
      backgroundDecoration: BoxDecoration(
          color: Settings.themeWhat
              ? Colors.grey.shade900.withOpacity(0.4)
              : Colors.grey.shade200.withOpacity(
                  0.4)), // default  Theme.of(context).backgroundColor

      //when a pointer that is in contact with the screen and moves to the right or left
      onDragUpdate: (double val, InnerDrawerDirection direction) {
        // return values between 1 and 0
        // print(val);
        // check if the swipe is to the right or to the left
        // print(direction == InnerDrawerDirection.start);
        // return direction == InnerDrawerDirection.end;
      },

      // innerDrawerCallback: (a) =>
      //     print(a), // return  true (open) or false (close)
      // leftChild: Container(
      //   width: 10,
      // ), // required if rightChild is not set
      rightChild: LeftPage(),
      leftChild: RightPage(),

      //  A Scaffold is generally used but you are free to use other widgets
      // Note: use "automaticallyImplyLeading: false" if you do not personalize "leading" of Bar
      scaffold: Scaffold(
        body: Padding(
          padding: EdgeInsets.only(top: statusBarHeight),
          child: SmartRefresher(
            enablePullDown: true,
            enablePullUp: true,
            header: ClassicHeader(
              // decoration: BoxDecoration(color: Colors.white),
              refreshingText: '가져오는 중...',
              completeText: '',
              idleText: '새로고침하려면 당기세요',
              releaseText: '놓아서 새로고침',
              completeDuration: Duration(milliseconds: 0),
              completeIcon: null,
              // refreshStyle: RefreshStyle,
            ),
            footer: ClassicFooter(
              loadingText: '가져오는 중...',
              idleText: '더보기',
              noDataText: '데이터가 없습니다 :(',
              canLoadingText: '',
              failedText: '실패 :(',
            ),
            controller: _refreshController,
            onRefresh: _onRefresh,
            onLoading: _onLoading,
            child: ListView.builder(
              itemBuilder: (c, i) => Card(child: Center(child: Text(items[i]))),
              itemExtent: 100.0,
              itemCount: items.length,
            ),
          ),
        ),
        // Container(
        //   padding: EdgeInsets.only(top: statusBarHeight),
        //   child: SingleChildScrollView(
        //     physics: BouncingScrollPhysics(),
        //     // child: ListView(),
        //   ),
        // ),
      ),
    );
  }
}
