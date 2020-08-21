// This source code is a part of Project Violet.
// Copyright (C) 2020. rollrat. Licensed under the MIT License.

class XPathToQureySelector {
  static XPathToQureySelector instance;

  static XPathToQureySelector getInstance() {
    if (instance == null) {
      instance = XPathToQureySelector();
    }

    return instance;
  }

  RegExp pattern;

  Map<String, String> _cache = Map<String, String>();

  XPathToQureySelector() {
    var tag = r"([a-zA-Z][a-zA-Z0-9]{0,10}|\*)";
    var attribute = r"[.a-zA-Z_:][-\w:.]*(\(\))?)";
    var value = r"\s*[\w/:][-/\w\s,:;.]*";

    pattern = RegExp(
        /**/ "" +
            /**/ "(" +
            /*  */ "^id\\([\"']?(?<idvalue>$value)[\"']?\\)" +
            /**/ "|" +
            /*  */ "(?<nav>//?)(?<tag>$tag)" +
            /*  */ "(\\[(" +
            /*    */ "(?<matched>(?<mattr>@?$attribute=[\"'](?<mvalue>$value))[\"']" +
            /*  */ "|" +
            /*    */ "(?<contained>contains\\((?<cattr>@?$attribute,\\s*[\"'](?<cvalue>$value)[\"']\\))" +
            /*  */ ")\\])?" +
            /*  */ "(\\[(?<nth>\\d+)\\])?" +
            /**/ ")" +
            "");
  }

  String toSelector(String xpath) {
    if (_cache.containsKey(xpath)) return _cache[xpath];

    var query = '';
    var pos = 0;

    while (pos < xpath.length) {
      var node = pattern.firstMatch(xpath.substring(pos));

      var nav = '';
      if (pos != 0) {
        nav = " ";
        if (node.namedGroup('nav') != "//") nav = " > ";
      }

      var tag = "";
      if (node.namedGroup('tag') != '*') tag = node.namedGroup('tag');

      var attr = '';
      if (node.namedGroup('idvalue') != null) {
        attr = "#" + node.namedGroup('idvalue').replaceAll(' ', '#');
      } else if (node.namedGroup('matched') != null) {
        if (node.namedGroup('mattr') == '@id') {
          attr = '#' + node.namedGroup('mvalue').replaceAll(' ', '#');
        } else if (node.namedGroup('mattr') == '@class') {
          attr = '.' + node.namedGroup('mvalue').replaceAll(' ', '.');
        } else if (node.namedGroup('mattr').contains('text()') &&
            node.namedGroup('mattr').contains('.')) {
          attr = ':contains(' + node.namedGroup('mvalue') + ')';
        } else if (node.namedGroup('mattr') != null) {
          if (node.namedGroup('mvalue').contains(' ')) {
            attr = "[" +
                node.namedGroup('mattr').replaceAll('@', '') +
                '=' +
                '"' +
                node.namedGroup('mvalue') +
                '"' +
                ']';
          } else {
            attr = "[" +
                node.namedGroup('mattr').replaceAll('@', '') +
                '=' +
                node.namedGroup('mvalue') +
                ']';
          }
        }
      } else if (node.namedGroup('contained') != null) {
        if (node.namedGroup('cattr').startsWith('@')) {
          attr = "[" +
              node.namedGroup('cattr').replaceAll('@', '') +
              '*=' +
              node.namedGroup('cvalue') +
              ']';
        } else if (node.namedGroup('cattr') == 'text()') {
          attr = ':contains(' + node.namedGroup('cvalue') + ')';
        }
      }

      var nth = '';
      if (node.namedGroup('nth') != null) {
        nth = ':nth-of-type(' + node.namedGroup('nth') + ')';
      }

      query += nav + tag + attr + nth;
      pos += node.end;
    }

    _cache[xpath] = query.trim();

    return query.trim();
  }
}

extension XPathParsing on String {
  String toQureySelector() {
    return XPathToQureySelector.getInstance().toSelector(this);
  }
}
