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
import 'package:communityexplorer/settings/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:hive/hive.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class CreateGroupPage extends StatefulWidget {
  final BoardManager boardManager;

  CreateGroupPage({this.boardManager});

  @override
  _CreateGroupPageState createState() => _CreateGroupPageState();
}

class _CreateGroupPageState extends State<CreateGroupPage> {
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
                        _colorArea(),
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
          '새로운 구독 그룹 추가',
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
                title: Text('작업 필터링'),
                content: Text(
                  '단어기반으로 해당 단어가 제목에 포함되어있는지의 여부로 필터링합니다.\n' +
                      '단어들은 띄어쓰기로 구분합니다.\n' +
                      '단어 앞에 -를 붙이면 해당 단어가 포함되지 않음을 의미합니다.',
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

  TextEditingController _nameTEC = TextEditingController(text: '');
  _nameArea() {
    return Row(
      children: [
        Text(
          '이름: ',
          style: TextStyle(fontSize: 18),
        ),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: 32),
            child: SizedBox(
              height: 34,
              child: TextField(
                controller: _nameTEC,
                cursorColor: _selectedColor,
                decoration: new InputDecoration(
                  isDense: true,
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: _selectedColor, width: 2.0),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  TextEditingController _snameTEC = TextEditingController(text: '');
  _subnameArea() {
    return Row(
      children: [
        Text(
          '설명: ',
          style: TextStyle(fontSize: 18),
        ),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: 32),
            child: SizedBox(
              height: 34,
              child: TextField(
                controller: _snameTEC,
                cursorColor: _selectedColor,
                decoration: new InputDecoration(
                  isDense: true,
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: _selectedColor, width: 2.0),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Color _selectedColor = Colors.purple;
  _colorArea() {
    return Row(
      children: [
        Text(
          '색상: ',
          style: TextStyle(fontSize: 18),
        ),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: 44, top: 4),
            child: SizedBox(
                height: 34,
                child: RaisedButton(
                  child: Text('변경'),
                  color: _selectedColor,
                  onPressed: () {
                    void changeColor(Color color) {
                      setState(() => _selectedColor = color);
                    }

                    showDialog(
                      context: context,
                      child: AlertDialog(
                        // title: const Text('Pick a color!'),
                        titlePadding: const EdgeInsets.all(0.0),
                        contentPadding: const EdgeInsets.all(0.0),
                        content: SingleChildScrollView(
                          // child: ColorPicker(
                          //   pickerColor: _selectedColor,
                          //   onColorChanged: changeColor,
                          //   showLabel: true,
                          //   pickerAreaHeightPercent: 0.8,
                          // ),
                          // Use Material color picker:
                          //
                          child: MaterialPicker(
                            pickerColor: _selectedColor,
                            onColorChanged: changeColor,
                            enableLabel: true,
                            // showLabel: true, // only on portrait mode
                          ),

                          // Use Block color picker:
                          //
                          // child: BlockPicker(
                          //   pickerColor: currentColor,
                          //   onColorChanged: changeColor,
                          // ),
                        ),
                        // actions: <Widget>[
                        //   FlatButton(
                        //     child: const Text('Got it'),
                        //     onPressed: () {
                        //       setState(() => currentColor = pickerColor);
                        //       Navigator.of(context).pop();
                        //     },
                        //   ),
                        // ],
                      ),
                    );
                  },
                )),
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
                child: Text('추가', style: TextStyle(color: _selectedColor)),
                // color: Settings.majorColor,
                focusColor: _selectedColor,
                splashColor: _selectedColor.withOpacity(0.3),
                highlightColor: _selectedColor.withOpacity(0.2),
                onPressed: () async {
                  var sinfo = SubGroupInfo(
                    name: _nameTEC.text +
                        '|' +
                        DateTime.now().microsecondsSinceEpoch.toString(),
                    subname: _snameTEC.text,
                    color: _selectedColor,
                  );

                  var group = BoardGroup(
                    boards: List<BoardInfo>(),
                    name: sinfo.name,
                    subname: _snameTEC.text,
                    color: _selectedColor,
                    subGroups: List<SubGroupInfo>(),
                  );

                  var groupt = jsonEncode(group.toMap());
                  await Hive.box("groups")
                      .put(base64.encode(utf8.encode(group.name)), groupt);

                  widget.boardManager.getSubGroups().add(sinfo);
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
                child: Text('취소', style: TextStyle(color: _selectedColor)),
                // color: Settings.majorColor,
                focusColor: _selectedColor,
                splashColor: _selectedColor.withOpacity(0.3),
                highlightColor: _selectedColor.withOpacity(0.2),
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
