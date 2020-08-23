// This source code is a part of Project Violet.
// Copyright (C) 2020. rollrat. Licensed under the MIT License.

import 'package:circular_check_box/circular_check_box.dart';
import 'package:communityexplorer/component/board_manager.dart';
import 'package:communityexplorer/component/component_manager.dart';
import 'package:communityexplorer/component/interface.dart';
import 'package:communityexplorer/pages/left_create_menu.dart';
import 'package:communityexplorer/pages/left_item_menu.dart';
import 'package:communityexplorer/settings/settings.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class LeftPage extends StatelessWidget {
  final BoardManager boardManager;
  final VoidCallback updateMain;

  LeftPage({this.updateMain, this.boardManager});

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    var windowWidth = MediaQuery.of(context).size.width;
    return Container(
      color: Settings.themeWhat ? Color(0xFF353535) : Colors.grey.shade100,
      child: Padding(
        padding:
            EdgeInsets.only(right: windowWidth - 160, top: statusBarHeight),
        // padding: EdgeInsets.zero,
        child: Material(
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                children: [
                  Container(height: 8),
                  Text(
                    boardManager.getName(),
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  boardManager.getSubName() != ''
                      ? Container(height: 4)
                      : Container(),
                  boardManager.getSubName() != ''
                      ? Text(
                          boardManager.getSubName(),
                          style: TextStyle(fontSize: 15),
                        )
                      : Container(),
                  Container(height: 4),
                  ListView.builder(
                    padding: EdgeInsets.zero,
                    physics: BouncingScrollPhysics(),
                    shrinkWrap: true,
                    itemBuilder: (context, index) => _Check(
                      boardManager.getBoards()[index],
                      updateMain: updateMain,
                    ),
                    itemCount: boardManager.getBoards().length,
                  ),
                  Container(height: 16),
                  SizedBox(
                    width: 50,
                    height: 50,
                    child: InkWell(
                      customBorder: RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(10.0),
                              topRight: Radius.circular(10.0),
                              bottomLeft: Radius.circular(10.0),
                              bottomRight: Radius.circular(10.0))),
                      child: Center(
                        child: Icon(
                          MdiIcons.plus,
                          size: 30,
                        ),
                      ),
                      onTap: () async {
                        var v = await showDialog(
                          context: context,
                          child: LeftCreateSelector(),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        // ),
      ),
    );
  }
}

class _Check extends StatefulWidget {
  final BoardInfo board;
  final VoidCallback updateMain;

  _Check(this.board, {this.updateMain});

  @override
  __CheckState createState() => __CheckState();
}

class __CheckState extends State<_Check> with TickerProviderStateMixin {
  String extractorName;
  String subName;
  Color color;

  @override
  void initState() {
    var s = widget.board;
    var com = ComponentManager.instance.getExtractorByName(s.extractor);
    extractorName = com.name();
    subName = s.name;
    color = com.color();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      customBorder: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10.0),
              topRight: Radius.circular(10.0),
              bottomLeft: Radius.circular(10.0),
              bottomRight: Radius.circular(10.0))),
      hoverColor: color,
      highlightColor: color.withOpacity(0.2),
      focusColor: color,
      splashColor: color.withOpacity(0.3),
      child: Row(
        children: [
          CircularCheckBox(
            inactiveColor: color,
            activeColor: color,
            value: widget.board.isEnabled,
            materialTapTargetSize: MaterialTapTargetSize.padded,
            onChanged: (bool value) {
              // setState(() {
              widget.board.isEnabled = !widget.board.isEnabled;
              // });
              widget.updateMain();
            },
          ),
          Expanded(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                extractorName,
                style: TextStyle(fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                subName,
                style: TextStyle(color: Colors.grey.shade600),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ))
        ],
      ),
      onTap: () {
        // setState(() {
        widget.board.isEnabled = !widget.board.isEnabled;
        // });
        widget.updateMain();
      },
      onLongPress: () async {
        var v = await showDialog(
          context: context,
          child: LeftItemSelector(false),
        );
      },
    );
  }
}
