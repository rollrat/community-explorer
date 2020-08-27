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

class FilterPage extends StatefulWidget {
  FilterPage();

  @override
  _FilterPageState createState() => _FilterPageState();
}

class _FilterPageState extends State<FilterPage> {
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
                        _globalArea(),
                        _specificArea(),
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
          '필터링',
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
                title: Text('필터링'),
                content: Text(
                  '보고싶지 않은 글들의 키워드를 등록하세요. 키워드는 띄어쓰기나 쉼표로 구분합니다. 전역필터는 모든 그룹에 적용되는 필터이고, 부분필터는 현재 그룹에만 적용되는 필터입니다.',
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

  TextEditingController _global = TextEditingController(text: '');
  _globalArea() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '전역필터: ',
          style: TextStyle(fontSize: 18),
        ),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: 32),
            child: TextField(
              keyboardType: TextInputType.multiline,
              controller: _global,
              minLines: 2,
              maxLines: 2,
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

  TextEditingController _specific = TextEditingController(text: '');
  _specificArea() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '부분필터: ',
          style: TextStyle(fontSize: 18),
        ),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: 32),
            child: TextField(
              keyboardType: TextInputType.multiline,
              controller: _specific,
              minLines: 2,
              maxLines: 2,
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
                child: Text('적용', style: TextStyle(color: Settings.majorColor)),
                // color: Settings.majorColor,
                focusColor: Settings.majorColor,
                splashColor: Settings.majorColor.withOpacity(0.3),
                highlightColor: Settings.majorColor.withOpacity(0.2),
                onPressed: () async {
                  var x = _global.text.split(RegExp(" |,"));
                  var y = _specific.text.split(RegExp(" |,"));
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
                highlightColor: Settings.majorColor.withOpacity(0.2),
                onPressed: () async {
                  var d = await Dialogs.yesnoDialog(context, '취소할까요?');
                  if (d != null && d == false) return;
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
