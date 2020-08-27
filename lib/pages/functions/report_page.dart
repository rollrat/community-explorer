// This source code is a part of Project Violet.
// Copyright (C) 2020. rollrat. Licensed under the MIT License.

import 'dart:convert';

import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:collection/collection.dart';
import 'package:communityexplorer/component/board_manager.dart';
import 'package:communityexplorer/component/component_manager.dart';
import 'package:communityexplorer/component/interface.dart';
import 'package:communityexplorer/network/wrapper.dart';
import 'package:communityexplorer/other/dialogs.dart';
import 'package:communityexplorer/pages/functions/wait_page.dart';
import 'package:communityexplorer/server/violet.dart';
import 'package:communityexplorer/settings/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:hive/hive.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReportPage extends StatefulWidget {
  final ArticleInfo articleInfo;

  ReportPage({this.articleInfo});

  @override
  _ReportPageState createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
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
                        // Container(
                        //   height: 8,
                        // ),
                        _nameArea(),
                        _subnameArea(),
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
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          '게시글 신고',
          maxLines: 1,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(
          height: 34,
          child: RawMaterialButton(
            constraints: BoxConstraints(),
            child: Center(
              child: Icon(MdiIcons.informationOutline,
                  color: Colors.grey.shade600),
            ),
            padding: EdgeInsets.all(4),
            shape: CircleBorder(),
            onPressed: () async {
              Widget okButton = FlatButton(
                child: Text('확인', style: TextStyle(color: Settings.majorColor)),
                focusColor: Settings.majorColor,
                splashColor: Settings.majorColor.withOpacity(0.3),
                onPressed: () {
                  Navigator.pop(context, "OK");
                },
              );
              AlertDialog alert = AlertDialog(
                title: Text('게시글 신고'),
                content: Text(
                  '문제가 되는 게시글을 신고해주세요.',
                  style: TextStyle(fontSize: 16),
                ),
                actions: [
                  okButton,
                ],
              );
              await showDialog(
                context: context,
                builder: (BuildContext context) {
                  return alert;
                },
              );
            },
          ),
        ),
      ],
    );
  }

  TextEditingController _title = TextEditingController(text: '');
  _nameArea() {
    return Row(
      children: [
        Text(
          '신고유형: ',
          style: TextStyle(fontSize: 18),
        ),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: 32),
            child: SizedBox(
              height: 34,
              child: TextField(
                controller: _title,
                cursorColor: Settings.majorColor,
                decoration: new InputDecoration(
                  isDense: true,
                  focusedBorder: UnderlineInputBorder(
                    borderSide:
                        BorderSide(color: Settings.majorColor, width: 2.0),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  TextEditingController _body = TextEditingController(text: '');
  _subnameArea() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '세부사항: ',
          style: TextStyle(fontSize: 18),
        ),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: 32),
            child: TextField(
              keyboardType: TextInputType.multiline,
              controller: _body,
              minLines: 1,
              maxLines: 3,
              cursorColor: Settings.majorColor,
              decoration: new InputDecoration(
                isDense: true,
                focusedBorder: UnderlineInputBorder(
                  borderSide:
                      BorderSide(color: Settings.majorColor, width: 2.0),
                ),
              ),
            ),
          ),
        ),
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
                child: Text('제출', style: TextStyle(color: Settings.majorColor)),
                // color: Settings.majorColor,
                focusColor: Settings.majorColor,
                splashColor: Settings.majorColor.withOpacity(0.3),
                highlightColor: Settings.majorColor.withOpacity(0.2),
                onPressed: () async {
                  if (_title.text == '' || _body.text == '') {
                    await Dialogs.okDialog(context, '신고유형 및 세부사항을 입력해주세요.');
                    return;
                  }
                  if (_title.text.length <= 2 || _body.text.length < 5) {
                    await Dialogs.okDialog(context, '신고유형이나 세부사항이 너무 짧습니다.');
                    return;
                  }

                  var id = int.parse(
                      (await SharedPreferences.getInstance())
                          .getString('fa_userid')
                          .substring(0, 7),
                      radix: 16);

                  var ff = Violet.report(widget.articleInfo.url, id.toString(),
                      _title.text, _body.text);

                  var v = await Navigator.push(
                    context,
                    PageRouteBuilder(
                      opaque: false,
                      pageBuilder: (_, __, ___) => WaitPage(
                        wait: ff,
                        msg: '신고처리중...',
                      ),
                    ),
                  );

                  if (int.tryParse(v) != null) {
                    await Dialogs.okDialog(context,
                        '신고처리가 완료되었습니다.\n아이디: $id\n신고번호: $v\n향후 답변이 필요하다면 위 신고번호를 알려주세요. 감사합니다.');
                    Navigator.pop(context);
                    return;
                  } else {
                    await Dialogs.okDialog(context, '실패! 다시 시도해주세요.');
                    return;
                  }
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
                highlightColor: Settings.majorColor.withOpacity(0.2),
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
