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
                    '구독',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Container(height: 4),
                  ListView.builder(
                    padding: EdgeInsets.zero,
                    physics: BouncingScrollPhysics(),
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      // var s = BoardManager.instance.getBoards()[index];
                      // if (s is BoardInfo) {
                      //   var com = ComponentManager.instance
                      //       .getExtractorByName(s.extractor);
                      //   return _Check(com.name(), s.name, com.color());
                      // } else if (s is BoardGroup) {
                      //   return _Check(s.name, s.subname, s.color);
                      // }
                      // return Container();
                      return _Check(BoardManager.instance.getBoards()[index]);
                    },
                    itemCount: BoardManager.instance.getBoards().length,
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
  // final String img;
  // final String extractorName;
  // final String subName;
  // final Color color;
  final Subscriable subscriable;

  // _Check(this.extractorName, this.subName, this.color);
  _Check(this.subscriable);

  @override
  __CheckState createState() => __CheckState();
}

class __CheckState extends State<_Check> with TickerProviderStateMixin {
  String extractorName;
  String subName;
  Color color;

  @override
  void initState() {
    var s = widget.subscriable;
    if (s is BoardInfo) {
      var com = ComponentManager.instance.getExtractorByName(s.extractor);
      extractorName = com.name();
      subName = s.name;
      color = com.color();
    } else if (s is BoardGroup) {
      extractorName = s.name;
      subName = s.subname;
      color = s.color;
    }
  }

  // AnimationController scaleAnimationController;
  // double scale = 1.0;

  // @override
  // void initState() {
  //   // TODO: implement initState
  //   super.initState();

  //   scaleAnimationController = AnimationController(
  //     vsync: this,
  //     lowerBound: 1.0,
  //     upperBound: 1.08,
  //     duration: Duration(milliseconds: 180),
  //   );
  //   scaleAnimationController.addListener(() {
  //     setState(() {
  //       scale = scaleAnimationController.value;
  //     });
  //   });
  // }

  // @override
  // Widget build(BuildContext context) {
  //   return Padding(
  //     padding: EdgeInsets.only(top: 8),
  //     child: GestureDetector(
  //       child: SizedBox(
  //         // width: 50,
  //         // height: 50,
  //         child: AnimatedContainer(
  //           curve: Curves.easeInOut,
  //           duration: Duration(milliseconds: 150),
  //           transform: Matrix4.identity()
  //             ..translate(50 / 2, 50 / 2)
  //             ..scale(scale)
  //             ..translate(-50 / 2, -50 / 2),
  //           child: Image.network(
  //             widget.img,
  //             width: 35,
  //             height: 35,
  //             fit: BoxFit.fill,
  //             // scale: widget.scale,
  //           ),
  //         ),
  //       ),
  //       onTapDown: (details) => setState(() {
  //         scale = 0.90;
  //       }),
  //       onTapUp: (details) => setState(() {
  //         scale = 1.0;
  //       }),
  //       onTapCancel: () => setState(() {
  //         scale = 1.0;
  //       }),
  //     ),
  //   );
  // }

  bool check = false;

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
            value: check,
            materialTapTargetSize: MaterialTapTargetSize.padded,
            onChanged: (bool value) {
              // setState(() {
              //   scale2 = 1.03;
              //   scale1 = 1.0;
              //   if (globalCheck) return;
              //   globalCheck = !globalCheck;
              //   userlangCheck = false;
              // });
              setState(() {
                check = value;
              });
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
        setState(() {
          check = !check;
        });
      },
      onLongPress: () async {
        var v = await showDialog(
          context: context,
          child: LeftItemSelector(widget.subscriable is BoardGroup),
        );
      },
    );
  }
}
