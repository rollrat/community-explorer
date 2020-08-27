// This source code is a part of Project Violet.
// Copyright (C) 2020. rollrat. Licensed under the MIT License.

import 'package:circular_check_box/circular_check_box.dart';
import 'package:communityexplorer/component/board_manager.dart';
import 'package:communityexplorer/component/component_manager.dart';
import 'package:communityexplorer/component/interface.dart';
import 'package:communityexplorer/pages/left/left_create_group_page.dart';
import 'package:communityexplorer/pages/left/left_create_menu.dart';
import 'package:communityexplorer/pages/left/left_create_page.dart';
import 'package:communityexplorer/pages/left/left_item_menu.dart';
import 'package:communityexplorer/pages/main_page.dart';
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
                      boardManager: boardManager,
                    ),
                    itemCount: boardManager.getBoards().length,
                  ),
                  boardManager.getBoards().length != 0 &&
                          boardManager.getSubGroups().length != 0
                      ? Divider(
                          color:
                              Settings.themeWhat ? Colors.grey : Colors.black,
                          height: 20,
                          thickness: 0.5,
                          indent: 20,
                          endIndent: 20,
                        )
                      : Container(),
                  ListView.builder(
                    padding: EdgeInsets.zero,
                    physics: BouncingScrollPhysics(),
                    shrinkWrap: true,
                    itemBuilder: (context, index) => _Group(
                      boardManager,
                      boardManager.getSubGroups()[index],
                      updateMain,
                    ),
                    itemCount: boardManager.getSubGroups().length,
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

                        if (v == null) return;

                        if (v == 0) {
                          await showDialog(
                            context: context,
                            child: CreateSubscribePage(
                              boardManager: boardManager,
                            ),
                          );

                          updateMain();
                        } else if (v == 1) {
                          await showDialog(
                            context: context,
                            child: CreateGroupPage(
                              boardManager: boardManager,
                            ),
                          );
                        }
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
  final BoardManager boardManager;

  _Check(this.board, {this.updateMain, this.boardManager});

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

        if (v == null) return;

        if (v == 0) {
          // var gg = await BoardManager.get(widget.subgroup.name);
          var gg = BoardManager.getByGroup(BoardGroup(boards: [widget.board]));
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => MainPage(gg, true)),
          );
        }
        if (v == 2) {
          await widget.boardManager.deleteBoard(widget.board);
          widget.updateMain();
        }
      },
    );
  }
}

class _Group extends StatefulWidget {
  final BoardManager boardManager;
  final SubGroupInfo subgroup;
  final VoidCallback updateMain;

  _Group(this.boardManager, this.subgroup, this.updateMain);

  @override
  __GroupState createState() => __GroupState();
}

class __GroupState extends State<_Group> with TickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var s = widget.subgroup.name.split('|');
    s.removeLast();

    return InkWell(
      customBorder: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10.0),
              topRight: Radius.circular(10.0),
              bottomLeft: Radius.circular(10.0),
              bottomRight: Radius.circular(10.0))),
      hoverColor: widget.subgroup.color,
      highlightColor: widget.subgroup.color.withOpacity(0.2),
      focusColor: widget.subgroup.color,
      splashColor: widget.subgroup.color.withOpacity(0.3),
      child: Row(
        children: [
          CircularCheckBox(
            inactiveColor: widget.subgroup.color,
            activeColor: widget.subgroup.color,
            checkColor: widget.subgroup.color,
            value: true,
            materialTapTargetSize: MaterialTapTargetSize.padded,
            onChanged: (bool value) {},
          ),
          Expanded(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                s.join('|'),
                style: TextStyle(fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                widget.subgroup.subname,
                style: TextStyle(color: Colors.grey.shade600),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ))
        ],
      ),
      onTap: () async {
        print(widget.subgroup.name);
        var gg = await BoardManager.get(widget.subgroup.name);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MainPage(gg)),
        );
      },
      onLongPress: () async {
        var v = await showDialog(
          context: context,
          child: LeftItemSelector(true),
        );

        if (v == null) return;

        if (v == 2) {
          await widget.boardManager.deleteSubGroup(widget.subgroup);
          widget.updateMain();
        }
      },
    );
  }
}
