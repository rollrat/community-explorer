// This source code is a part of Project Violet.
// Copyright (C) 2020. rollrat. Licensed under the MIT License.

import 'package:communityexplorer/component/board_manager.dart';
import 'package:communityexplorer/component/interface.dart';
import 'package:communityexplorer/pages/article_widget.dart';
import 'package:communityexplorer/pages/left_page.dart';
import 'package:communityexplorer/pages/right_page.dart';
import 'package:communityexplorer/settings/settings.dart';
import 'package:communityexplorer/widget/inner_drawer.dart';
import 'package:communityexplorer/widget/toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final GlobalKey<InnerDrawerState> _innerDrawerKey =
      GlobalKey<InnerDrawerState>();

  List<ArticleInfo> articles;

  // List<String> items = ["1", "2", "3", "4", "5", "6", "7", "8"];
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    Future.delayed(Duration(milliseconds: 100)).then((value) async {
      try {
        articles = await BoardManager.instance.init();
      } catch (e, st) {
        print(e);
        print(st);
      }
      // articles.forEach((element) {
      // print(element.title);
      // });
      if (BoardManager.instance.hasInitError) {
        FlutterToast(context).showToast(
          child: ToastWrapper(
            isCheck: false,
            isWarning: true,
            msg: '일부항목을 불러오지 못했습니다 :(',
          ),
          gravity: ToastGravity.BOTTOM,
          toastDuration: Duration(seconds: 4),
        );
      }
      setState(() {});
    });
  }

  void _onRefresh() async {
    // monitor network fetch
    // await Future.delayed(Duration(milliseconds: 1000));
    // if failed,use refreshFailed()
    try {
      articles = await BoardManager.instance.refresh();
    } catch (e) {
      print(e);
    }
    _refreshController.refreshCompleted();
    setState(() {});
  }

  void _onLoading() async {
    // monitor network fetch
    // await Future.delayed(Duration(milliseconds: 1000));
    // if failed,use loadFailed(),if no data return,use LoadNodata()
    // items.add((items.length + 1).toString());
    try {
      articles = await BoardManager.instance.next();
    } catch (e) {
      print(e);
    }
    if (mounted) setState(() {});
    _refreshController.loadComplete();
    setState(() {});
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
      // colorTransitionChild: Colors.cyan, // default Color.black54
      colorTransitionScaffold: Colors.black12, // default Color.black54

      //When setting the vertical offset, be sure to use only top or bottom
      offset: IDOffset.only(
        bottom: 0.00,
        left: (width - 160) / width,
        right: (width - 60) / width,
      ),

      scale: IDOffset.horizontal(1.0), // set the offset in both directions
      // leftOff

      proportionalChildArea: false, // default true
      borderRadius: 0, // default 0
      rightAnimationType: InnerDrawerAnimation.static, // default static
      leftAnimationType: InnerDrawerAnimation.static,
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
      rightChild: RightPage(),
      leftChild: LeftPage(),

      //  A Scaffold is generally used but you are free to use other widgets
      // Note: use "automaticallyImplyLeading: false" if you do not personalize "leading" of Bar
      scaffold: Scaffold(
        body: articles == null
            ? Container()
            : Padding(
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
                  child: ListView.separated(
                    physics: BouncingScrollPhysics(),
                    itemBuilder: (c, i) => ArticleWidget(
                      articleInfo: articles[i],
                    ),
                    // itemExtent: 50.0,
                    itemCount: articles.length,
                    separatorBuilder: (context, index) {
                      return Divider(
                        height: 2,
                      );
                    },
                  ),
                ),
              ),
      ),
    );
  }
}
