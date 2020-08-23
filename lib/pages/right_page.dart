// This source code is a part of Project Violet.
// Copyright (C) 2020. rollrat. Licensed under the MIT License.

import 'package:communityexplorer/settings/settings.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class RightPage extends StatefulWidget {
  final VoidCallback updateMain;

  RightPage({this.updateMain});

  @override
  _RightPageState createState() => _RightPageState();
}

class _RightPageState extends State<RightPage> with TickerProviderStateMixin {
  AnimationController _animationController;

  @override
  void initState() {
    _animationController = AnimationController(
        vsync: this,
        value: Settings.viewType == 0 ? 1.0 : 0.0,
        duration: Duration(milliseconds: 300));
    // _animationController.forward();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    var windowWidth = MediaQuery.of(context).size.width;
    return Container(
      color: Settings.themeWhat ? Color(0xFF353535) : Colors.grey.shade100,
      child: Padding(
        padding: EdgeInsets.only(left: windowWidth - 60, top: statusBarHeight),
        // padding: EdgeInsets.zero,
        child: Material(
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                children: [
                  Container(height: 8),
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
                        child: ShaderMask(
                          shaderCallback: (bounds) => RadialGradient(
                            center: Alignment.topLeft,
                            radius: 1.0,
                            colors: [Colors.black, Colors.white],
                            tileMode: TileMode.clamp,
                          ).createShader(bounds),
                          child: Icon(
                            MdiIcons.themeLightDark,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                      ),
                      onTap: () async {
                        Settings.setThemeWhat(!Settings.themeWhat);
                        DynamicTheme.of(context).setBrightness(
                            Theme.of(context).brightness == Brightness.dark
                                ? Brightness.light
                                : Brightness.dark);
                      },
                    ),
                  ),
                  Container(height: 4),
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
                        child: AnimatedIcon(
                          icon: AnimatedIcons.view_list,
                          color: Settings.themeWhat
                              ? Colors.grey.shade400
                              : Colors.grey.shade700,
                          size: 30,
                          progress: _animationController,
                        ),
                      ),
                      onTap: () async {
                        if (Settings.viewType == 0) {
                          Settings.setViewType(1);
                          _animationController.reverse();
                          widget.updateMain();
                        } else if (Settings.viewType == 1) {
                          Settings.setViewType(0);
                          _animationController.forward();
                          widget.updateMain();
                        }
                      },
                    ),
                  ),
                  Container(height: 4),
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
                          MdiIcons.informationOutline,
                          color: Settings.themeWhat
                              ? Colors.grey.shade400
                              : Colors.grey.shade700,
                          size: 30,
                        ),
                      ),
                      onTap: () async {},
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
