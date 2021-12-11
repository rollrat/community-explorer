// This source code is a part of Project Violet.
// Copyright (C) 2020. rollrat. Licensed under the MIT License.

import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:collection/collection.dart';
import 'package:communityexplorer/component/board_manager.dart';
import 'package:communityexplorer/component/component_manager.dart';
import 'package:communityexplorer/component/interface.dart';
import 'package:communityexplorer/network/wrapper.dart';
import 'package:communityexplorer/network/wrapper.dart' as http;
import 'package:communityexplorer/other/dialogs.dart';
import 'package:communityexplorer/settings/settings.dart';
import 'package:flutter/material.dart';

const _supportedCommunity = [
  '개드립',
  '디시인사이드',
  '루리웹',
  '아카라이브',
  // '보배드림',
  '에펨코리아',
  '엠엘비파크',
  '웃긴대학',
  '인스티즈',
  '클리앙',
  // 'MLB Park',
  // 'Nate',
  // '뽐뿌',
  // 'SLR',
];

class CreateSubscribePage extends StatefulWidget {
  final BoardManager boardManager;

  CreateSubscribePage({this.boardManager});

  @override
  _CreateSubscribePageState createState() => _CreateSubscribePageState();
}

class _CreateSubscribePageState extends State<CreateSubscribePage> {
  List<BoardInfo> _supportedBoards = List<BoardInfo>();

  bool supportClass = false;
  bool useClass = false;
  List<String> classes;
  String selectedClass;

  @override
  Widget build(BuildContext context) {
    var windowWidth = MediaQuery.of(context).size.width;
    var windowheight = MediaQuery.of(context).size.height;
    var bottom = MediaQuery.of(context).viewInsets.bottom;

    var column = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        GestureDetector(
          onTap: () {},
          child: Card(
            color:
                Settings.themeWhat ? Color(0xFF353535) : Colors.grey.shade100,
            elevation: 100,
            child: Column(
              children: [
                SizedBox(
                  width: windowWidth - 80,
                  // height: (56 * 6 + 16).toDouble(),
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: Column(
                      children: [
                        _head(),
                        Container(
                          height: 4,
                        ),
                        SizedBox(height: 40, child: _communityArea()),
                        SizedBox(
                          height: 40,
                          child: _supportedBoards != null
                              ? _boardArea()
                              : _boardSearchArea(),
                        ),
                        _options != null
                            ? SizedBox(
                                height: 40,
                                child: _optionsArea(),
                              )
                            : Container(),
                        useClass ? _classArea() : Container(),
                        supportClass ? _classEnableArea() : Container(),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  width: 300,
                  child: _buttonArea(),
                ),
              ],
            ),
          ),
        ),
      ],
    );

    if (windowWidth > windowheight) {
      return GestureDetector(
        onTap: () {
          Navigator.pop(context);
        },
        child: Container(
          padding: EdgeInsets.only(bottom: bottom),
          child: SingleChildScrollView(child: column),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(1)),
            boxShadow: [
              BoxShadow(
                color: Settings.themeWhat
                    ? Colors.black.withOpacity(0.4)
                    : Colors.grey.withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 1,
                offset: Offset(0, 3), // changes position of shadow
              ),
            ],
          ),
        ),
      );
    }
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
      },
      child: Container(
        padding: EdgeInsets.only(bottom: bottom),
        child: column,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(1)),
          boxShadow: [
            BoxShadow(
              color: Settings.themeWhat
                  ? Colors.black.withOpacity(0.4)
                  : Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 1,
              offset: Offset(0, 3), // changes position of shadow
            ),
          ],
        ),
      ),
    );
  }

  _head() {
    return Row(
      children: [
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '새로운 구독 추가',
                maxLines: 1,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _selectedCommunity;
  BoardData _selectedData;
  List<String> _searchs;
  _communityArea() {
    return Row(
      children: [
        Text(
          '커뮤니티: ',
          style: TextStyle(fontSize: 18),
        ),
        DropdownButton(
          hint: Text('커뮤니티를 선택하세요'),
          value: _selectedCommunity,
          items: _supportedCommunity
              .map(
                (e) => DropdownMenuItem(
                  child: Text(e.split('|').first.trim()),
                  value: e,
                ),
              )
              .toList(),
          onChanged: (value) {
            _selectedData = ComponentManager.instance.getDataFromName(value);
            _searchs = _selectedData.searchs();
            if (_searchs == null)
              _supportedBoards = _selectedData.getLists();
            else
              _supportedBoards = null;
            if (_selectedData.extraOptions() != null) {
              _options = _selectedData.extraOptions();
              _optionChecked[0] = _options[0].split('|')[1] == '1';
            } else
              _options = null;
            key = new GlobalKey<AutoCompleteTextFieldState<String>>();
            setState(() {
              _selectedCommunity = value;
            });
          },
        )
      ],
    );
  }

  BoardInfo _selectedBoard;
  _boardArea() {
    return Row(
      children: [
        Text(
          '게시판: ',
          style: TextStyle(fontSize: 18),
        ),
        DropdownButton(
          hint: Text('게시판을 선택하세요'),
          value: _selectedBoard,
          items: _supportedBoards
              .map(
                (e) => DropdownMenuItem(
                  child: Text(e.name),
                  value: e,
                ),
              )
              .toList(),
          onChanged: (value) async {
            _selectedBoard = value;
            await _classCal(_selectedBoard);
            setState(() {});
          },
        )
      ],
    );
  }

  GlobalKey key = new GlobalKey<AutoCompleteTextFieldState<String>>();
  TextEditingController controller = TextEditingController();
  _boardSearchArea() {
    return Row(
      children: [
        Text(
          '게시판: ',
          style: TextStyle(fontSize: 18),
        ),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: 16),
            child: AutoCompleteTextField(
              key: key,
              decoration: new InputDecoration(
                hintText: "검색",
                suffixIcon: new Icon(Icons.search),
              ),
              itemSubmitted: (item) async {
                if (item == null) return;
                _selectedBoard = _selectedData.getBoardFromName(item);
                controller.text = item;
                await _classCal(_selectedBoard);
                setState(() {});
              },
              controller: controller,
              clearOnSubmit: false,
              suggestions: _searchs,
              itemBuilder: (context, suggestion) =>
                  new ListTile(title: new Text(suggestion)),
              itemSorter: (a, b) => a.compareTo(b),
              itemFilter: (suggestion, input) =>
                  suggestion.toLowerCase().startsWith(input.toLowerCase()),
            ),
          ),
        ),
      ],
    );
  }

  List<bool> _optionChecked = List<bool>.from([false]);
  List<String> _options;
  _optionsArea() {
    return Row(
      children: [
        Text(
          '옵션: ',
          style: TextStyle(fontSize: 18),
        ),
        Checkbox(
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          value: _optionChecked[0],
          onChanged: (value) {
            setState(() {
              _optionChecked[0] = value;
            });
          },
          activeColor: Settings.majorColor,
        ),
        Text(_options[0].split('|')[0]),
      ],
    );
  }

  Future<void> _classCal(BoardInfo board) async {
    var query = Map<String, dynamic>.from(board.extrainfo);

    var url = board.url +
        '?' +
        query.entries
            .map((e) =>
                '${e.key}=${Uri.encodeQueryComponent(e.value.toString())}')
            .join('&');

    var html = (await http.get(
      url,
      headers: {
        'Accept': HttpWrapper.accept,
        'User-Agent': HttpWrapper.userAgent,
      },
    ))
        .body;

    if (await _selectedData.supportClass(html)) {
      supportClass = true;
      classes = await _selectedData.getClasses(html);
      selectedClass = classes[0];
      useClass = false;
    } else {
      supportClass = false;
      useClass = false;
    }
  }

  _classEnableArea() {
    return InkWell(
      onTap: () {
        setState(() {
          useClass = !useClass;
        });
      },
      child: Container(
        height: 32,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Checkbox(
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              value: useClass,
              onChanged: (value) {
                setState(() {
                  useClass = value;
                });
              },
              activeColor: Settings.majorColor,
            ),
            Text('클래스/말머리/카테고리 사용'),
            Container(
              width: 10,
            )
          ],
        ),
      ),
    );
  }

  _classArea() {
    return Row(
      children: [
        Text(
          '클래스: ',
          style: TextStyle(fontSize: 18),
        ),
        DropdownButton(
          value: selectedClass,
          items: classes
              .map(
                (e) => DropdownMenuItem(
                  child: Text(e.split('|').first.trim()),
                  value: e,
                ),
              )
              .toList(),
          onChanged: (value) {
            setState(() {
              selectedClass = value;
            });
          },
        )
      ],
    );
  }

  _buttonArea() {
    return Transform.translate(
      offset: Offset(0, -6),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: FlatButton(
                child: Text('추가', style: TextStyle(color: Settings.majorColor)),
                // color: Settings.majorColor,
                focusColor: Settings.majorColor,
                splashColor: Settings.majorColor.withOpacity(0.3),
                onPressed: () async {
                  if (_selectedBoard == null) {
                    await Dialogs.okDialog(context, '커뮤니티 및 게시판을 선택해주세요.');
                    return;
                  }

                  var _board = BoardInfo(
                    extractor: _selectedBoard.extractor,
                    extrainfo: _selectedBoard.extrainfo,
                    url: _selectedBoard.url,
                    name: _selectedBoard.name,
                  );
                  if (_options != null && _optionChecked[0]) {
                    _board.extrainfo[_options[0].split('|')[2]] =
                        _options[0].split('|')[3];
                  }

                  if (useClass) {
                    _board.extrainfo[selectedClass.split('|')[1]] =
                        selectedClass.split('|')[2];
                  }

                  var overlap = false;
                  widget.boardManager.getBoards().forEach((element) {
                    if (element.url != _board.url) return;
                    if (element.name != _board.name) return;
                    if (element.extractor != _board.extractor) return;
                    // if (element.extrainfo != _selectedBoard.extrainfo) return;
                    if ((element.extrainfo != null) !=
                        (_board.extrainfo != null)) return;
                    if (element.extrainfo != null && _board.extrainfo != null) {
                      var aa = element.extrainfo.entries
                          .map((e) => e.key + '=' + e.value)
                          .toList();
                      var bb = _board.extrainfo.entries
                          .map((e) => e.key + '=' + e.value)
                          .toList();

                      aa.sort((x, y) => x.compareTo(y));
                      bb.sort((x, y) => x.compareTo(y));

                      if (aa.join(',') != bb.join(',')) return;
                    }
                    overlap = true;
                  });

                  if (overlap) {
                    await Dialogs.okDialog(
                        context, '이미 추가된 게시판(갤러리)입니다. 다른 게시판(갤러리)를 선택해주세요.');
                    return;
                  }

                  widget.boardManager.getBoards().add(_board);
                  await widget.boardManager.saveGroup();
                  Navigator.pop(context);
                },
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: FlatButton(
                child: Text('취소', style: TextStyle(color: Settings.majorColor)),
                // color: Settings.majorColor,
                focusColor: Settings.majorColor,
                splashColor: Settings.majorColor.withOpacity(0.3),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
