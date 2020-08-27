// This source code is a part of Project Violet.
// Copyright (C) 2020. rollrat. Licensed under the MIT License.

import 'package:flutter/material.dart';
import 'package:communityexplorer/settings/settings.dart';

class InfoPage extends StatelessWidget {
  Color getColor(int i) {
    return Settings.themeWhat ? Colors.grey.shade400 : Colors.grey.shade900;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
      },
      child: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Card(
              color:
                  Settings.themeWhat ? Color(0xFF353535) : Colors.grey.shade100,
              child: SizedBox(
                child: Container(
                  padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(''),
                      Text('Violet Community Explorer',
                          style: TextStyle(fontSize: 30)),
                      Text('0.7.0', style: TextStyle(fontSize: 30)),
                      Text(''),
                      // Text('Project-Violet Android App'),
                      // Text(
                      //   Translations.of(context).trans('infomessage'),
                      //   textAlign: TextAlign.center,
                      //   style: TextStyle(fontSize: 10),
                      // ),
                    ],
                  ),
                  width: 250,
                  height: 190,
                ),
              ),
            ),
          ],
        ),
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
}
