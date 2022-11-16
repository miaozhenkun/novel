import 'dart:convert';

import 'package:eso/api/api.dart';
import 'package:eso/api/api_js_engine.dart';
import 'package:eso/database/rule.dart';
import 'package:eso/eso_theme.dart';
import 'package:eso/ui/ui_image_item.dart';
import 'package:flutter/services.dart';
import 'package:flutter_qjs/flutter_qjs.dart';
import 'package:oktoast/oktoast.dart';
import '../api/analyze_url.dart';
import '../api/analyzer_manager.dart';
import 'package:eso/utils/decode_body.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../database/chapter_item.dart';

class DebugRuleProvider with ChangeNotifier {
  DateTime _startTime;
  final Rule rule;
  final Color textColor;
  bool disposeFlag;
  ScrollController _controller;
  ScrollController get controller => _controller;

  DebugRuleProvider(this.rule, this.textColor) {
    disposeFlag = false;
    _controller = ScrollController();
    initPrint();
  }

  void initPrint() async {
    await JSEngine.setFunction("__print", IsolateFunction((s, isUrl) {
      _addContent("JS", s, isUrl, true);
    }));
    JSEngine.evaluate("var print = function(...args) {__print(args[0], !!args[1]);};");
  }

  final rows = <Row>[];
  @override
  void dispose() {
    rows.clear();
    disposeFlag = true;
    _controller.dispose();
    searchController.dispose();
    super.dispose();
  }

  Widget _buildText(String s, [bool isUrl = false, bool fromJS = false]) {
    return Flexible(
      child: isUrl
          ? GestureDetector(
              onTap: () => launch(s),
              onLongPress: () async {
                await Clipboard.setData(ClipboardData(text: s));
                showToast("结果已复制: $s");
              },
              child: Text(
                s,
                style: TextStyle(
                  decorationStyle: TextDecorationStyle.solid,
                  decoration: TextDecoration.underline,
                  color: fromJS ? Colors.green : Colors.blue,
                  height: 2,
                ),
              ),
            )
          : SelectableText(s,
              style: TextStyle(height: 2, color: fromJS ? Colors.green : null)),
    );
  }

  void _addContent(String sInfo, [String s, bool isUrl = false, bool fromJS = false]) {
    final d = DateTime.now().difference(_startTime).inMicroseconds;
    rows.add(Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "• [${DateFormat("mm:ss.SSS").format(DateTime.fromMicrosecondsSinceEpoch(d))}] $sInfo${s == null ? "" : ": "}",
          style: TextStyle(color: textColor.withOpacity(0.5), height: 2),
        ),
        _buildText(s ?? "", isUrl, fromJS),
      ],
    ));
    if (sInfo == "封面") {
      rows.add(Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "• [${DateFormat("mm:ss.SSS").format(DateTime.fromMicrosecondsSinceEpoch(d))}] 预览: ",
            style: TextStyle(color: textColor.withOpacity(0.5), height: 2),
          ),
          Expanded(child: UIImageItem(cover: s)),
        ],
      ));
    }
    notifyListeners();
  }

  void _beginEvent(String s) {
    rows.add(Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          "★ $s测试  ",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: ESOTheme.staticFontFamily,
            height: 2,
          ),
        ),
        SelectableText(
          DateFormat("MM-dd HH:mm:ss").format(DateTime.now()),
          style: TextStyle(height: 2),
        ),
      ],
    ));
    _addContent("$s解析开始");
  }

  void discover() async {
    _startTime = DateTime.now();
    rows.clear();
    _beginEvent("发现");
    try {
      dynamic discoverRule = rule.discoverUrl.trimLeft();
      if (discoverRule.startsWith("@js:")) {
        _addContent("执行发现js规则");
        await JSEngine.setEnvironment(1, rule, "", rule.host, "", "");
        discoverRule = await JSEngine.evaluate(discoverRule.substring(4));
        _addContent("结果", "$discoverRule");
      }
      final discoverFirst = (discoverRule is List
              ? "${discoverRule.first}"
              : discoverRule is String
                  ? discoverRule
                      .split(RegExp(r"\n+\s*|&&"))
                      .firstWhere((s) => s.trim().isNotEmpty, orElse: () => "")
                  : "")
          .split("::")
          .last;
      var body = "";
      var discoverUrl = "";
      if (discoverFirst == 'null') {
        _addContent("地址为null跳过请求");
      } else {
        final discoverResult = await AnalyzeUrl.urlRuleParser(
          discoverFirst,
          rule,
          page: 1,
          pageSize: 20,
        );
        if (discoverResult.contentLength == 0) {
          _addContent("响应内容为空，终止解析！");
          return;
        }
        discoverUrl = discoverResult.request.url.toString();
        body = DecodeBody()
            .decode(discoverResult.bodyBytes, discoverResult.headers["content-type"]);
        _addContent("地址", discoverUrl, true);
      }

      await JSEngine.setEnvironment(1, rule, "", discoverUrl, "", "");
      _addContent("初始化js");
      final analyzer = AnalyzerManager(body);
      String next;
      if (rule.discoverNextUrl != null && rule.discoverNextUrl.isNotEmpty) {
        next = await analyzer.getString(rule.discoverNextUrl);
      } else {
        next = null;
      }
      _addContent("下一页", next);
      final discoverList = await analyzer.getElements(rule.discoverList);
      final resultCount = discoverList.length;
      if (resultCount == 0) {
        _addContent("发现结果列表个数为0，解析结束！");
      } else {
        _addContent("个数", resultCount.toString());
        parseFirstDiscover(discoverList.first);
      }
    } catch (e) {
      rows.add(Row(
        children: [
          Flexible(
            child: SelectableText(
              "$e\n",
              style: TextStyle(color: Colors.red, height: 2),
            ),
          ),
        ],
      ));
      _addContent("解析结束！");
    }
  }

  void parseFirstDiscover(dynamic firstItem) async {
    _addContent("开始解析第一个结果");
    try {
      final analyzer = AnalyzerManager(firstItem);
      _addContent("名称", await analyzer.getString(rule.discoverName));
      _addContent("作者", await analyzer.getString(rule.discoverAuthor));
      _addContent("章节", await analyzer.getString(rule.discoverChapter));
      final coverUrl = await analyzer.getString(rule.discoverCover);
      _addContent("封面", coverUrl, true);
      //_texts.add(WidgetSpan(child: UIImageItem(cover: coverUrl)));
      _addContent("简介", await analyzer.getString(rule.discoverDescription));
      final tags = await analyzer.getString(rule.discoverTags);
      if (tags != null && tags.trim().isNotEmpty) {
        _addContent(
            "标签",
            (tags.split(APIConst.tagsSplitRegExp)..removeWhere((tag) => tag.isEmpty))
                .join(", "));
      } else {
        _addContent("标签", "");
      }
      final result = await analyzer.getString(rule.discoverResult);
      _addContent("结果", result);
      parseChapter(result);
    } catch (e, st) {
      rows.add(Row(
        children: [
          Flexible(
            child: SelectableText(
              "$e\n$st\n",
              style: TextStyle(color: Colors.red, height: 2),
            ),
          )
        ],
      ));
      _addContent("解析结束！");
    }
  }

  final TextEditingController searchController = TextEditingController();

  void search(String value) async {
    _startTime = DateTime.now();
    rows.clear();
    _beginEvent("搜索");
    try {
      String searchUrl = "";
      String body = "";
      if (rule.searchUrl == 'null') {
        _addContent("地址为null跳过请求");
      } else {
        final searchResult = await AnalyzeUrl.urlRuleParser(
          rule.searchUrl,
          rule,
          keyword: value,
          page: 1,
          pageSize: 20,
        );
        if (searchResult.contentLength == 0) {
          _addContent("响应内容为空，终止解析！");
          return;
        }
        searchUrl = searchResult.request.url.toString();
        _addContent("地址", searchUrl, true);
        body = DecodeBody()
            .decode(searchResult.bodyBytes, searchResult.headers["content-type"]);
      }
      await JSEngine.setEnvironment(1, rule, "", searchUrl, value, "");
      _addContent("初始化js");
      final analyzer = AnalyzerManager(body);
      String next;
      if (rule.searchNextUrl != null && rule.searchNextUrl.isNotEmpty) {
        next = await analyzer.getString(rule.searchNextUrl);
      } else {
        next = null;
      }
      _addContent("下一页", next);
      final searchList = await analyzer.getElements(rule.searchList);
      final resultCount = searchList.length;
      if (resultCount == 0) {
        _addContent("搜索结果列表个数为0，解析结束！");
      } else {
        _addContent("搜索结果个数", resultCount.toString());
        parseFirstSearch(searchList.first);
      }
    } catch (e, st) {
      rows.add(Row(
        children: [
          Flexible(
            child: SelectableText(
              "$e\n$st\n",
              style: TextStyle(color: Colors.red, height: 2),
            ),
          ),
        ],
      ));
      _addContent("解析结束！");
    }
  }

  void parseFirstSearch(dynamic firstItem) async {
    _addContent("开始解析第一个结果");
    try {
      final analyzer = AnalyzerManager(firstItem);
      _addContent("名称", await analyzer.getString(rule.searchName));
      _addContent("作者", await analyzer.getString(rule.searchAuthor));
      _addContent("章节", await analyzer.getString(rule.searchChapter));
      final coverUrl = await analyzer.getString(rule.searchCover);
      _addContent("封面", coverUrl, true);
      //_texts.add(WidgetSpan(child: UIImageItem(cover: coverUrl)));
      _addContent("简介", await analyzer.getString(rule.searchDescription));
      final tags = await analyzer.getString(rule.searchTags);
      if (tags != null && tags.trim().isNotEmpty) {
        _addContent(
            "标签",
            (tags.split(APIConst.tagsSplitRegExp)..removeWhere((tag) => tag.isEmpty))
                .join(", "));
      } else {
        _addContent("标签", "");
      }
      final result = await analyzer.getString(rule.searchResult);
      _addContent("结果", result);
      parseChapter(result);
    } catch (e, st) {
      rows.add(Row(
        children: [
          Flexible(
            child: SelectableText(
              "$e\n$st\n",
              style: TextStyle(color: Colors.red, height: 2),
            ),
          ),
        ],
      ));
      _addContent("解析结束！");
    }
  }

  void parseChapter(String result) async {
    if (rule.chapterUrl == "正文") {
      _addContent("章节地址为'正文', 跳过目录, 进入正文");
      praseContent(result);
      return;
    }
    _beginEvent("目录");
    dynamic firstChapter;
    String next;
    String chapterUrlRule;
    final hasNextUrlRule = rule.chapterNextUrl != null && rule.chapterNextUrl.isNotEmpty;
    for (var page = 1;; page++) {
      if (disposeFlag) return;
      chapterUrlRule = null;
      final url = rule.chapterUrl != null && rule.chapterUrl.isNotEmpty
          ? rule.chapterUrl
          : result;
      if (page == 1) {
        chapterUrlRule = url;
      } else if (hasNextUrlRule) {
        if (next != null && next.isNotEmpty) {
          chapterUrlRule = next;
        }
      } else if (url.contains(APIConst.pagePattern)) {
        chapterUrlRule = url;
      }
      _addContent("解析第$page页");
      _addContent("规则", "$chapterUrlRule");
      if (chapterUrlRule == null) {
        _addContent("下一页结束");
        break;
      }
      try {
        String chapterUrl = "";
        String body = "";
        if (rule.chapterUrl == 'null') {
          _addContent("地址为null跳过请求");
        } else {
          final res = await AnalyzeUrl.urlRuleParser(
            chapterUrlRule,
            rule,
            result: result,
            page: page,
          );
          if (res.contentLength == 0) {
            _addContent("响应内容为空，终止解析！");
            break;
          }
          chapterUrl = res.request.url.toString();
          _addContent("地址", chapterUrl, true);
          body = DecodeBody().decode(res.bodyBytes, res.headers["content-type"]);
        }

        if (page == 1) {
          await JSEngine.setEnvironment(page, rule, result, chapterUrl, "", result);
        } else {
          await JSEngine.evaluate(
              "baseUrl = ${jsonEncode(chapterUrl)};page = ${jsonEncode(page)};");
        }
        final analyzer = AnalyzerManager(body);
        if (hasNextUrlRule) {
          next = await analyzer.getString(rule.chapterNextUrl);
        } else {
          next = null;
        }
        _addContent("下一页", await analyzer.getString(rule.chapterNextUrl));
        AnalyzerManager analyzerManager;
        if (rule.enableMultiRoads) {
          final roads = await analyzer.getElements(rule.chapterRoads);
          final count = roads.length;
          if (count == 0) {
            _addContent("线路个数为0，解析结束！");
            break;
          } else {
            _addContent("个数", count.toString());
          }
          final road = roads.first;
          analyzerManager = AnalyzerManager(road);
          _addContent("线路名称", await analyzerManager.getString(rule.chapterRoadName));
        } else {
          analyzerManager = analyzer;
        }
        final reversed = rule.chapterList.startsWith("-");
        if (reversed) {
          _addContent("检测规则以\"-\"开始, 结果将反序");
        }

        final chapterList = await analyzerManager
            .getElements(reversed ? rule.chapterList.substring(1) : rule.chapterList);
        final count = chapterList.length;
        if (count == 0) {
          _addContent("章节列表个数为0，解析结束！");
          break;
        } else {
          _addContent("个数", count.toString());
          if (firstChapter == null) {
            firstChapter = reversed ? chapterList.last : chapterList.first;
          }
        }
      } catch (e, st) {
        rows.add(Row(
          children: [
            Flexible(
              child: SelectableText(
                "$e\n$st\n",
                style: TextStyle(color: Colors.red, height: 2),
              ),
            )
          ],
        ));
        _addContent("解析结束！");
        break;
      }
    }
    if (disposeFlag) return;
    if (firstChapter != null) {
      parseFirstChapter(firstChapter);
    }
  }

  void parseFirstChapter(dynamic firstItem) async {
    _addContent("开始解析第一个结果");
    try {
      final analyzer = AnalyzerManager(firstItem);
      final name = await analyzer.getString(rule.chapterName);
      _addContent("名称", name);
      final lock = await analyzer.getString(rule.chapterLock);
      _addContent("lock", lock);
      if (lock != null &&
          lock.isNotEmpty &&
          lock != "undefined" &&
          lock != "false" &&
          lock != "0") {
        _addContent("名称", "🔒" + name);
      } else {
        _addContent("名称", name);
      }
      _addContent("时间", await analyzer.getString(rule.chapterTime));
      final coverUrl = await analyzer.getString(rule.chapterCover);
      _addContent("封面", coverUrl, true);
      //_texts.add(WidgetSpan(child: UIImageItem(cover: coverUrl)));
      final result = await analyzer.getString(rule.chapterResult);
      _addContent("结果", result);
      praseContent(result);
    } catch (e, st) {
      rows.add(Row(
        children: [
          Flexible(
            child: SelectableText(
              "$e\n$st\n",
              style: TextStyle(color: Colors.red, height: 2),
            ),
          )
        ],
      ));
      _addContent("解析结束！");
    }
  }

  void praseContent(String result) async {
    _beginEvent("正文");
    final hasNextUrlRule = rule.contentNextUrl != null && rule.contentNextUrl.isNotEmpty;
    final url =
        rule.contentUrl != null && rule.contentUrl.isNotEmpty ? rule.contentUrl : result;
    String next;
    String contentUrlRule;
    for (var page = 1;; page++) {
      if (disposeFlag) return;
      contentUrlRule = null;
      if (page == 1) {
        contentUrlRule = url;
      } else if (hasNextUrlRule) {
        if (next != null && next.isNotEmpty) {
          contentUrlRule = next;
        }
      } else if (url.contains(APIConst.pagePattern)) {
        contentUrlRule = url;
      }
      if (contentUrlRule == null) {
        _addContent("下一页结束");
        return;
      }
      _addContent("解析第$page页");
      _addContent("规则", "$contentUrlRule");
      if (contentUrlRule == null) {
        _addContent("下一页结束");
        break;
      }
      try {
        var contentUrl = '';
        var body = '';
        if (contentUrlRule == 'null') {
          _addContent("地址为null跳过请求");
        } else {
          final res = await AnalyzeUrl.urlRuleParser(
            contentUrlRule,
            rule,
            result: result,
            page: page,
          );
          if (res.contentLength == 0) {
            _addContent("响应内容为空，终止解析！");
            return;
          }
          contentUrl = res.request.url.toString();
          _addContent("地址", contentUrl, true);
          body = DecodeBody().decode(res.bodyBytes, res.headers["content-type"]);
        }
        if (page == 1) {
          await JSEngine.setEnvironment(page, rule, result, contentUrl, "", result);
        } else {
          await JSEngine.evaluate(
              "baseUrl = ${jsonEncode(contentUrl)};page = ${jsonEncode(page)};");
        }
        final analyzer = AnalyzerManager(body);
        if (hasNextUrlRule) {
          next = await analyzer.getString(rule.contentNextUrl);
        } else {
          next = null;
        }
        _addContent("下一页", next);
        var contentItems = await analyzer.getStringList(rule.contentItems);
        if (rule.contentType == API.NOVEL) {
          contentItems = contentItems.join("\n").split(RegExp(r"\n\s*|\s{2,}"));
        }
        final count = contentItems.length;
        if (count == 0) {
          _addContent("正文结果个数为0，解析结束！");
          return;
        } else if (contentItems.join().trim().isEmpty) {
          _addContent("正文内容为空，解析结束！");
          return;
        } else {
          _addContent("个数", count.toString());
          final isUrl = rule.contentType == API.MANGA ||
              rule.contentType == API.AUDIO ||
              rule.contentType == API.VIDEO;
          for (int i = 0; i < count; i++) {
            rows.add(Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "• [${'0' * (3 - i.toString().length)}$i]: ",
                  style: TextStyle(color: textColor.withOpacity(0.5), height: 2),
                ),
                _buildText(contentItems[i], isUrl),
              ],
            ));
          }
          notifyListeners();
        }
      } catch (e, st) {
        rows.add(Row(
          children: [
            Flexible(
              child: SelectableText(
                "$e\n$st\n",
                style: TextStyle(color: Colors.red, height: 2),
              ),
            )
          ],
        ));
        _addContent("解析结束！");
        return;
      }
    }
  }
}
