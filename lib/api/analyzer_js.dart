import 'dart:convert';

import 'package:eso/api/api_js_engine.dart';
import 'package:html/dom.dart';
import 'analyzer.dart';

class AnalyzerJS implements Analyzer {
  String _content;

  @override
  AnalyzerJS parse(content) {
    if (content is Document) {
      _content = jsonEncode(content.outerHtml);
    } else if (content is Element) {
      _content = jsonEncode(content.outerHtml);
    } else if (content is List<Element>) {
      if (content.length == 1) {
        _content = jsonEncode(content[0].outerHtml);
      } else {
        _content = jsonEncode(content.map((e) => e.outerHtml).toList());
      }
    } else if (content is List && content.length == 1) {
      final temp = content[0];
      if (temp is List || temp is Map) {
        _content = jsonEncode(temp);
      } else {
        _content = jsonEncode('${content[0]}');
      }
    } else {
      try {
        _content = jsonEncode(content);
      } catch (e) {
        print("error AnalyzeByJS jsonEncode: $e");
        _content = jsonEncode('$content');
      }
    }
    return this;
  }

  Future<dynamic> _eval(String rule) {
    return JSEngine.evaluate("result = $_content; $rule;");
  }

  @override
  Future<dynamic> getElements(String rule) async {
    return _eval(rule);
  }

  @override
  Future<dynamic> getString(String rule) async {
    return _eval(rule);
  }

  @override
  Future<dynamic> getStringList(String rule) async {
    return _eval(rule);
  }
}
