// This source code is a part of Project Violet.
// Copyright (C) 2020. rollrat. Licensed under the MIT License.

import 'package:communityexplorer/component/board_manager.dart';
import 'package:communityexplorer/component/interface.dart';
import 'package:communityexplorer/network/wrapper.dart';
import 'package:communityexplorer/pages/article/article_widget.dart';
import 'package:communityexplorer/pages/left/left_page.dart';
import 'package:communityexplorer/pages/right/right_page.dart';
import 'package:communityexplorer/settings/settings.dart';
import 'package:communityexplorer/widget/inner_drawer.dart';
import 'package:communityexplorer/widget/toast.dart';
// import 'package:firebase_admob/firebase_admob.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hive/hive.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class MainPage extends StatefulWidget {
  final BoardManager boardManager;
  final bool disableLeft;
  final bool isRootPage;

  MainPage(this.boardManager,
      [this.disableLeft = false, this.isRootPage = false]);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final GlobalKey<InnerDrawerState> _innerDrawerKey =
      GlobalKey<InnerDrawerState>();

  List<ArticleInfo> articles;

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // banner
    //   ..load()
    //   ..show(
    //     anchorType: AnchorType.bottom,
    //   );
    Future.delayed(Duration(milliseconds: 100)).then((value) async {
      try {
        articles = await widget.boardManager.init();
      } catch (e, st) {
        print(e);
        print(st);
      }
      if (widget.boardManager.hasInitError) {
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
      setState(() {
        _shouldReload = true;
      });
    });
  }

  void _onRefresh() async {
    try {
      articles = await widget.boardManager.refresh();
    } catch (e) {
      print(e);
    }
    _refreshController.refreshCompleted();
    setState(() {
      _shouldReload = true;
    });
  }

  void _onLoading() async {
    try {
      articles = await widget.boardManager.next();
    } catch (e) {
      print(e);
    }
    if (mounted)
      setState(() {
        _shouldReload = true;
      });
    _refreshController.loadComplete();
    setState(() {
      _shouldReload = true;
    });
  }

  bool _shouldReload = false;
  Widget _cachedList;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (_cachedList == null || _shouldReload) {
      _shouldReload = false;
      final lists = _itemList();
      _cachedList = lists;
    }

    return InnerDrawer(
      key: _innerDrawerKey,
      onTapClose: true,
      swipe: true,
      colorTransitionScaffold: Colors.black12,
      offset: IDOffset.only(
        bottom: 0.00,
        // 160: 왼쪽 drawer 너비
        left: (width - 160) / width,
        // 60: 오른쪽 drawer 너비
        right: (width - 60) / width,
      ),
      scale: IDOffset.horizontal(1.0),
      proportionalChildArea: false,
      borderRadius: 0,
      rightAnimationType: InnerDrawerAnimation.static,
      leftAnimationType: InnerDrawerAnimation.linear,
      backgroundDecoration: BoxDecoration(
          color: Settings.themeWhat
              ? Colors.grey.shade900.withOpacity(0.4)
              : Colors.grey.shade200.withOpacity(0.4)),
      onDragUpdate: (double val, InnerDrawerDirection direction) {},
      rightChild: RightPage(
        boardManager: widget.boardManager,
        updateMain: () => setState(() {
          _shouldReload = true;
        }),
      ),
      leftChild: widget.disableLeft
          ? null
          : LeftPage(
              updateMain: () => setState(() {
                _shouldReload = true;
                widget.boardManager.tidy();
                articles = widget.boardManager.getArticles();
              }),
              boardManager: widget.boardManager,
            ),
      scaffold: Scaffold(
        body: articles == null ? Container() : _cachedList,
      ),
    );
  }

  _itemList() {
    return SafeArea(
      child: SmartRefresher(
        enablePullDown: true,
        enablePullUp: true,
        header: ClassicHeader(
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
          // addAutomaticKeepAlives: false,
          itemBuilder: (c, i) => ArticleWidget(
            key: ValueKey(articles[i].url),
            articleInfo: articles[i],
            viewType: Settings.viewType,
            boardManager: widget.boardManager,
          ),
          // cacheExtent: height * 3,
          // itemExtent: 50.0,
          itemCount: articles.length,
          separatorBuilder: (context, index) {
            return Divider(
              height: 2,
            );
          },
        ),
      ),
    );
  }
}
