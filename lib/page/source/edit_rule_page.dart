import 'dart:convert';

import 'package:eso/api/api_js_engine.dart';
import 'package:eso/database/rule.dart';
import 'package:eso/global.dart';
import 'package:eso/menu/menu.dart';
import 'package:eso/menu/menu_edit_rule.dart';
import 'package:eso/eso_theme.dart';
import 'package:eso/page/source/debug_rule_page.dart';
import 'package:eso/ui/widgets/draggable_scrollbar_sliver.dart';
import 'package:eso/utils.dart';
import 'package:eso/utils/rule_comparess.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../api/api.dart';
import '../../fonticons_icons.dart';
import '../discover_page.dart';
import 'login_rule_page.dart';
import 'editor/highlight_code_editor.dart';

class EditRulePage extends StatefulWidget {
  final Rule rule;
  const EditRulePage({
    this.rule,
    Key key,
  }) : super(key: key);
  @override
  _EditRulePageState createState() => _EditRulePageState();
}

class _EditRulePageState extends State<EditRulePage> with WidgetsBindingObserver {
  var isLoading = false;
  Color primaryColor;
  Rule rule;
  bool _infoExpanded = true;
  bool _discoverExpanded = true;
  bool _searchExpanded = true;
  bool _chapterExpanded = true;
  bool _contentExpanded = true;
  ScrollController _controller;

  var isLargeScreen = false;
  Widget detailPage;
  void invokeTap(Widget detailPage) {
    if (isLargeScreen) {
      this.detailPage = detailPage;
      setState(() {});
    } else {
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => detailPage,
          ));
    }
  }

  GlobalKey<HighLightCodeEditorState> codeKey = GlobalKey();
  String s = "";
  bool isNotCollapsed = false;
  String code = "";
  FocusNode codeFocusNode;
  Widget editView;

  @override
  void initState() {
    _controller = ScrollController();
    codeFocusNode = FocusNode()
      ..addListener(() {
        currentController = codeKey.currentState?.codeTextController;
        currentOnChanged = onchangeCode;
      });
    super.initState();
  }

  onchangeCode(String s) {
    code = s;
    codeKey.currentState?.codeTextController?.text = s;
  }

  @override
  void dispose() {
    _controller.dispose();
    codeFocusNode.dispose();
    super.dispose();
  }

  /// ??????????????????List
  final inputList = [
    {
      'encoding': '"encoding":"gbk"',
      'async': r'''
(async() => {
    
    return '';
})();''',
      'http': r'''var html = await http('');''',
      'xpath': r'''var x = await xpath(html, '//*[@class="xx"]');''',
      'xpath_class': '//*[@class="xx"]',
      'xpath_id': '//*[@id="xx"]',
      'match': "result.match(/xx/)[0];",
      'stringify': "JSON.stringify({});",
      'parse': "JSON.parse(xx);",
      'get-gbk': r'''{
    "url": "/modules/article/search.php?searchkey=$keyword&searchtype=articlename&page=$page",
    "encoding": "gbk"
}''',
      'get-headers': r'''{
    "url": "/modules/article/search.php?searchkey=$keyword&searchtype=articlename&page=$page",
    "headers":{
        "Accept-Language": "zh-CN,zh;q=0.9,en;q=0.8,en-GB;q=0.7,en-US;q=0.6",
        "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/84.0.4147.89 Safari/537.36 Edg/84.0.522.40"
    }
}''',
      'post-form1': r'''{
    "url": "/modules/article/search.php",
    "method": "POST",
    "body": "searchkey=$keyword&searchtype=articlename",
    "headers": {
        "Content-Type": "application/x-www-form-urlencoded"
    }
}''',
      'post-form2': r'''{
    "url": "/modules/article/search.php",
    "method": "POST",
    "body": {
        "searchkey": "$keyword",
        "searchtype": "articlename"
    }
}''',
      'post-json': r'''{
    "url": "/modules/article/search.php",
    "method": "POST",
    "body": "{\"searchkey\": \"$keyword\",\"searchtype\": \"articlename\"}",
    "headers":{
        "Content-Type": "application/json"
    }
}''',
      'post-headers': r'''{
    "url": "/modules/article/search.php",
    "method": "POST",
    "body": "searchkey=$keyword&searchtype=articlename",
    "headers": {
        "Content-Type": "application/x-www-form-urlencoded",
        "Accept-Language": "zh-CN,zh;q=0.9,en;q=0.8,en-GB;q=0.7,en-US;q=0.6",
        "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/84.0.4147.89 Safari/537.36 Edg/84.0.522.40"
    }
}''',
      'Macintosh-UA':
          'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/81.0.4044.113 Safari/537.36',
      'Android-UA':
          'Mozilla/5.0 (Linux; Android 9; MIX 2 Build/PKQ1.190118.001; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/80.0.3987.99 Mobile Safari/537.36',
    },
    {
      '`': '`',
      '"': '"',
      '\'': '\'',
      '@': '@',
      ':': ':',
      '&': '&',
      '|': '|',
      '%': '%',
      '/': '/',
      '\\': '\\',
      '[': '[',
      ']': ']',
      '{': '{',
      '}': '}',
      '<': '<',
      '>': '>',
      '\$': '\$',
      '.': '.',
      '#': '#',
      'keyword': 'keyword',
      'page': 'page',
      'pageSize': 'pageSize',
      'host': 'host',
      'result': 'result',
      'lastResult': 'lastResult',
      'text': 'text',
      'href': 'href',
      'src': 'src',
      'headers': 'headers',
      'User-Agent': 'User-Agent',
    }
  ];

  rebuildEditView() {
    editView = DraggableScrollbar.semicircle(
      controller: _controller,
      child: ListView(
        controller: _controller,
        children: [
          _buildInfo(context),
          _buildDiscover(context),
          _buildSearch(context),
          _buildChapter(context),
          _buildContent(context),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    primaryColor = Theme.of(context).primaryColor;
    if (null == rule) {
      rule = widget.rule ?? Rule.newRule();
      _discoverExpanded = rule.enableDiscover;
      _searchExpanded = rule.enableSearch;
    }

    if (editView == null) {
      rebuildEditView();
    }

    final size = MediaQuery.of(context).size;
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    final child = Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Text(widget.rule == null ? '????????????' : '????????????'),
        actions: [
          IconButton(
            icon: Icon(FIcons.share_2),
            tooltip: "??????",
            onPressed: () {
              Share.share(RuleCompress.compass(rule));
              // FlutterShare.share(
              //   title: '?????? eso',
              //   text: RuleCompress.compass(rule), //jsonEncode(rule.toJson()),
              //   //linkUrl: '${searchItem.url}',
              //   chooserTitle: '?????????????????????',
              // );
            },
          ),
          IconButton(
            icon: Icon(FIcons.save),
            iconSize: 21,
            tooltip: "??????",
            onPressed: () => _saveRule(context),
          ),
          IconButton(
            icon: Icon(Icons.bug_report),
            tooltip: "??????",
            onPressed: () async {
              if (isLoading) return;
              isLoading = true;
              rule.modifiedTime = DateTime.now().microsecondsSinceEpoch;
              await Global.ruleDao.insertOrUpdateRule(rule);
              isLoading = false;
              // Navigator.of(context).push(
              //     MaterialPageRoute(builder: (context) => DebugRulePage(rule: rule)));
              invokeTap(DebugRulePage(rule: rule));
            },
          ),
          _buildpopupMenu(context),
        ],
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: Stack(
              children: [
                editView,
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: isNotCollapsed ? size.width - 10 : null,
                    constraints: isNotCollapsed
                        ? BoxConstraints(maxHeight: size.height - 150 - bottom)
                        : null,
                    child: Card(
                      child: isNotCollapsed
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: HighLightCodeEditor(
                                    codeKey,
                                    code,
                                    focusNode: codeFocusNode,
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: SingleChildScrollView(child: SelectableText(s)),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    InkWell(
                                      onTap: () async {
                                        await Clipboard.setData(ClipboardData(text: s));
                                        Utils.toast("???????????????");
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text("????????????"),
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () async {
                                        await Clipboard.setData(ClipboardData(
                                            text: codeKey.currentState?.code ?? code));
                                        Utils.toast("???????????????");
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text("????????????"),
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () => codeKey.currentState?.format(),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text("?????????"),
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () async {
                                        try {
                                          await JSEngine.setEnvironment(
                                              1, rule, "", rule.host, "", "");
                                          final x = await JSEngine.evaluate(
                                              codeKey.currentState?.code ?? code);
                                          setState(() {
                                            s = "$x";
                                          });
                                        } catch (e, st) {
                                          setState(() {
                                            s = "$e\n$st";
                                          });
                                        }
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text("??????"),
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () {
                                        code = codeKey.currentState?.code ?? code;
                                        setState(() => isNotCollapsed = !isNotCollapsed);
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text("??????"),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            )
                          : InkWell(
                              onTap: () {
                                code = codeKey.currentState?.code ?? code;
                                setState(() => isNotCollapsed = !isNotCollapsed);
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                child: Text("JS??????"),
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          ...inputList.map((list) => _buildInputHelp(list)).toList()
        ],
      ),
    );
    return OrientationBuilder(builder: (context, orientation) {
      if (MediaQuery.of(context).size.width > 600) {
        isLargeScreen = true;
      } else {
        isLargeScreen = false;
      }

      return Row(children: <Widget>[
        Expanded(
          child: child,
        ),
        SizedBox(
          height: double.infinity,
          width: 2,
          child: Material(
            color: Colors.grey.withAlpha(123),
          ),
        ),
        isLargeScreen ? Expanded(child: detailPage ?? Scaffold()) : Container(),
      ]);
    });
  }

  Widget _buildInputHelp(Map<String, String> inputList) {
    final inputKeys = inputList.keys.toList();
    final inputValues = inputList.values.toList();
    return Container(
      height: 32,
      alignment: Alignment.center,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: inputKeys.length,
        physics: BouncingScrollPhysics(),
        itemBuilder: (BuildContext context, int index) {
          return InkWell(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                inputKeys[index],
                style: TextStyle(fontSize: 16, height: 2),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            onTap: () {
              final fastText = inputValues[index];
              final textSelection = currentController.selection;
              currentController.text = currentController.text.replaceRange(
                textSelection.start,
                textSelection.end,
                fastText,
              );
              currentOnChanged(currentController.text);
              currentController.selection = textSelection.copyWith(
                baseOffset: textSelection.end + fastText.length,
                extentOffset: textSelection.end + fastText.length,
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildDetailsText(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          fontFamily: ESOTheme.staticFontFamily,
        ),
      ),
    );
  }

  TextEditingController currentController;
  void Function(String text) currentOnChanged;

  Widget _buildEditText(
    String text,
    String labelText,
    void Function(String text) onChanged, {
    int minLines = 1,
    int maxLines,
  }) {
    final controller = TextEditingController(text: text);
    return Padding(
      padding: const EdgeInsets.all(12),
      child: TextField(
        focusNode: FocusNode()
          ..addListener(() {
            currentController = controller;
            currentOnChanged = onChanged;
          }),
        minLines: minLines,
        maxLines: maxLines,
        controller: controller,
        decoration: InputDecoration(
          labelText: labelText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildTitle(String text) {
    return Text(
      text,
      style: TextStyle(color: primaryColor),
    );
  }

  Widget _buildInfo(BuildContext context) {
    return ExpansionTile(
      title: _buildTitle("????????????"),
      initiallyExpanded: _infoExpanded,
      onExpansionChanged: (value) => _infoExpanded = value,
      children: [
        _buildDetailsText('???????????????${DateTime.fromMicrosecondsSinceEpoch(rule.createTime)}'),
        _buildDetailsText(
            '???????????????${DateTime.fromMicrosecondsSinceEpoch(rule.modifiedTime)}'),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              _buildDetailsText('??????(contentType)???'),
              DropdownButton<int>(
                isDense: true,
                value: rule.contentType,
                onChanged: (value) {
                  rule.contentType = value;
                  rebuildEditView();
                  setState(() {});
                },
                items: List.generate(
                  6,
                  (index) => DropdownMenuItem<int>(
                    child: Text(API.getRuleContentTypeName(index)),
                    value: index,
                  ),
                ),
              ),
            ],
          ),
        ),
        SwitchListTile(
          title: Text('??????????????????'),
          value: rule.enableUpload,
          onChanged: (value) {
            rule.enableUpload = value;
            rebuildEditView();
            setState(() {});
          },
        ),
        _buildEditText(
          rule.name,
          '??????(name)',
          (text) => rule.name = text,
          maxLines: 1,
        ),
        _buildEditText(
          rule.host,
          '??????(host)',
          (text) => rule.host = text,
          maxLines: 1,
        ),
        _buildEditText(
          rule.group,
          '??????(group)',
          (text) => rule.group = text,
          maxLines: 1,
        ),
        _buildEditText(
          rule.author,
          '??????(author)',
          (text) => rule.author = text,
          maxLines: 1,
        ),
        _buildEditText(
          rule.postScript,
          '?????????(post script, p.s.)',
          (text) => rule.postScript = text,
        ),
        _buildEditText(
          rule.userAgent,
          '?????????????????????(userAgent)',
          (text) => rule.userAgent = text,
        ),
        _buildEditText(
          rule.loadJs,
          '??????js??????(loadJs)',
          (text) => rule.loadJs = text,
        ),
        _buildEditText(
          rule.loginUrl,
          '????????????(loginUrl)',
          (text) => rule.loginUrl = text,
        ),
        _buildEditText(
          rule.cookies,
          '?????????(cookies)',
          (text) => rule.cookies = text,
        ),
      ],
    );
  }

  Widget _buildDiscover(BuildContext context) {
    return ExpansionTile(
      title: _buildTitle("????????????"),
      initiallyExpanded: _discoverExpanded,
      onExpansionChanged: (value) => _discoverExpanded = value,
      children: [
        SwitchListTile(
          title: Text('??????'),
          value: rule.enableDiscover,
          onChanged: (value) {
            rule.enableDiscover = value;
            rebuildEditView();
            setState(() {});
          },
        ),
        _buildEditText(
          rule.discoverUrl,
          '??????(discoverUrl)',
          (text) => rule.discoverUrl = text,
        ),
        _buildEditText(
          rule.discoverNextUrl,
          '?????????(discoverNextUrl)',
          (text) => rule.discoverNextUrl = text,
        ),
        _buildEditText(
          rule.discoverList,
          '??????(discoverList)',
          (text) => rule.discoverList = text,
        ),
        _buildEditText(
          rule.discoverName,
          '??????(discoverName)',
          (text) => rule.discoverName = text,
        ),
        _buildEditText(
          rule.discoverAuthor,
          '??????(discoverAuthor)',
          (text) => rule.discoverAuthor = text,
        ),
        _buildEditText(
          rule.discoverCover,
          '??????(discoverCover)',
          (text) => rule.discoverCover = text,
        ),
        _buildEditText(
          rule.discoverChapter,
          '????????????(discoverChapter)',
          (text) => rule.discoverChapter = text,
        ),
        _buildEditText(
          rule.discoverDescription,
          '??????(discoverDescription)',
          (text) => rule.discoverDescription = text,
        ),
        _buildEditText(
          rule.discoverTags,
          '??????(discoverTags)',
          (text) => rule.discoverTags = text,
        ),
        _buildEditText(
          rule.discoverResult,
          '??????(discoverResult)',
          (text) => rule.discoverResult = text,
        ),
      ],
    );
  }

  Widget _buildSearch(BuildContext context) {
    return ExpansionTile(
      title: _buildTitle("????????????"),
      initiallyExpanded: _searchExpanded,
      onExpansionChanged: (value) => _searchExpanded = value,
      children: [
        SwitchListTile(
          title: Text('??????'),
          value: rule.enableSearch,
          onChanged: (value) {
            rule.enableSearch = value;
            rebuildEditView();
            setState(() {});
          },
        ),
        _buildEditText(
          rule.searchUrl,
          '??????(searchUrl)',
          (text) => rule.searchUrl = text,
        ),
        _buildEditText(
          rule.searchNextUrl,
          '?????????(searchNextUrl)',
          (text) => rule.searchNextUrl = text,
        ),
        _buildEditText(
          rule.searchList,
          '??????(searchList)',
          (text) => rule.searchList = text,
        ),
        _buildEditText(
          rule.searchName,
          '??????(searchName)',
          (text) => rule.searchName = text,
        ),
        _buildEditText(
          rule.searchAuthor,
          '??????(searchAuthor)',
          (text) => rule.searchAuthor = text,
        ),
        _buildEditText(
          rule.searchCover,
          '??????(searchCover)',
          (text) => rule.searchCover = text,
        ),
        _buildEditText(
          rule.searchChapter,
          '????????????(searchChapter)',
          (text) => rule.searchChapter = text,
        ),
        _buildEditText(
          rule.searchDescription,
          '??????(searchDescription)',
          (text) => rule.searchDescription = text,
        ),
        _buildEditText(
          rule.searchTags,
          '??????(searchTags)',
          (text) => rule.searchTags = text,
        ),
        _buildEditText(
          rule.searchResult,
          '??????(searchResult)',
          (text) => rule.searchResult = text,
        ),
      ],
    );
  }

  Widget _buildChapter(BuildContext context) {
    return ExpansionTile(
      title: _buildTitle("????????????"),
      initiallyExpanded: _chapterExpanded,
      onExpansionChanged: (value) => _chapterExpanded = value,
      children: [
        SwitchListTile(
          title: Text('???????????????'),
          value: rule.enableMultiRoads,
          onChanged: (value) {
            rule.enableMultiRoads = value;
            rebuildEditView();
            setState(() {});
          },
        ),
        _buildEditText(
          rule.chapterUrl,
          '??????(chapterUrl)',
          (text) => rule.chapterUrl = text,
        ),
        _buildEditText(
          rule.chapterNextUrl,
          '?????????(chapterNextUrl)',
          (text) => rule.chapterNextUrl = text,
        ),
        _buildEditText(
          rule.chapterRoads,
          '??????(chapterRoads)',
          (text) => rule.chapterRoads = text,
        ),
        _buildEditText(
          rule.chapterRoadName,
          '????????????(chapterRoadName)',
          (text) => rule.chapterRoadName = text,
        ),
        _buildEditText(
          rule.chapterList,
          '????????????(chapterList)',
          (text) => rule.chapterList = text,
        ),
        _buildEditText(
          rule.chapterName,
          '????????????(chapterName)',
          (text) => rule.chapterName = text,
        ),
        _buildEditText(
          rule.chapterTime,
          '????????????(chapterTime)',
          (text) => rule.chapterTime = text,
        ),
        _buildEditText(
          rule.chapterCover,
          '????????????(chapterCover)',
          (text) => rule.chapterCover = text,
        ),
        _buildEditText(
          rule.chapterLock,
          '????????????(chapterLock)',
          (text) => rule.chapterLock = text,
        ),
        _buildEditText(
          rule.chapterResult,
          '??????(chapterResult)',
          (text) => rule.chapterResult = text,
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context) {
    return ExpansionTile(
      title: _buildTitle("????????????"),
      initiallyExpanded: _contentExpanded,
      onExpansionChanged: (value) => _contentExpanded = value,
      children: [
        // SwitchListTile(
        //   title: Text('??????CryptoJS'),
        //   value: rule.useCryptoJS,
        //   onChanged: (value) {
        //     setState(() {
        //       rule.useCryptoJS = value;
        //     });
        //   },
        // ),
        _buildEditText(
          rule.contentUrl,
          '??????(contentUrl)',
          (text) => rule.contentUrl = text,
        ),
        _buildEditText(
          rule.contentNextUrl,
          '?????????(contentNextUrl)',
          (text) => rule.contentNextUrl = text,
        ),
        _buildEditText(
          rule.contentItems,
          '??????(contentItems)',
          (text) => rule.contentItems = text,
        ),
      ],
    );
  }

  Future<bool> _saveRule(BuildContext context) async {
    Utils.toast("????????????");
    if (isLoading) return false;
    isLoading = true;
    final count = await Global.ruleDao.insertOrUpdateRule(rule);
    isLoading = false;
    if (count > 0) {
      Utils.toast("????????????");
      return true;
    } else {
      Utils.toast("????????????");
      return false;
    }
  }

  Future<bool> _loadFromClipBoard(BuildContext context, bool isYICIYUAN) async {
    if (isLoading) return false;
    isLoading = true;
    final text = (await Clipboard.getData(Clipboard.kTextPlain)).text;
    isLoading = false;
    try {
      rule = isYICIYUAN
          ? Rule.fromYiCiYuan(jsonDecode(text), rule)
          : text.startsWith(RuleCompress.tag)
              ? RuleCompress.decompass(text, rule)
              : Rule.fromJson(jsonDecode(text), rule);
      rebuildEditView();
      setState(() {});
      Utils.toast("?????????????????????");
      return true;
    } catch (e) {
      Utils.toast("???????????????" + e.toString(), duration: Duration(seconds: 2));
      return false;
    }
  }

  Menu _buildpopupMenu(BuildContext context) {
    return Menu<MenuEditRule>(
      items: editRuleMenus,
      onSelect: (value) {
        switch (value) {
          case MenuEditRule.login:
            // Navigator.of(context)
            //     .push(MaterialPageRoute(builder: (context) => LoginRulePage(rule: rule)))
            //     .whenComplete(() => setState(() {}));
            invokeTap(LoginRulePage(rule: rule));
            break;
          case MenuEditRule.import:
            _loadFromClipBoard(context, false);
            break;
          case MenuEditRule.yiciyuan:
            _loadFromClipBoard(context, true);
            break;
          case MenuEditRule.copy:
            Clipboard.setData(ClipboardData(text: RuleCompress.compass(rule)));
            Utils.toast("?????????????????????");
            break;
          case MenuEditRule.copy_origin:
            Clipboard.setData(ClipboardData(text: jsonEncode(rule.toJson())));
            Utils.toast("?????????????????????");
            break;
          case MenuEditRule.share_origin:
            Share.share(jsonEncode(rule.toJson()));
            // FlutterShare.share(
            //   title: '?????? eso',
            //   text: jsonEncode(rule.toJson()),
            //   //linkUrl: '${searchItem.url}',
            //   chooserTitle: '?????????????????????',
            // );
            break;
          case MenuEditRule.preview:
            // Navigator.of(context).push(
            //   MaterialPageRoute(
            //     builder: (context) => FutureBuilder<List<DiscoverMap>>(
            //       future: APIFromRUle(rule).discoverMap(),
            //       initialData: null,
            //       builder: (BuildContext context, AsyncSnapshot snapshot) {
            //         if (snapshot.hasError) {
            //           return Scaffold(
            //             body: Text("error: ${snapshot.error}"),
            //           );
            //         }
            //         if (!snapshot.hasData) {
            //           return LandingPage();
            //         }
            //         return DiscoverSearchPage(
            //           rule: rule,
            //           originTag: rule.id,
            //           origin: rule.name,
            //           discoverMap: snapshot.data,
            //         );
            //       },
            //     ),
            //   ),
            // );
            invokeTap(DiscoverFuture(rule: rule));
            break;
          case MenuEditRule.delete:
            final _context = context;
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: Text("??????(????????????)"),
                  content: Text("?????? ${rule.name}"),
                  actions: [
                    TextButton(
                      child: Text(
                        "??????",
                        style: TextStyle(color: Theme.of(context).hintColor),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    TextButton(
                      child: Text(
                        "??????",
                        style: TextStyle(color: Colors.red),
                      ),
                      onPressed: () {
                        Global.ruleDao.deleteRule(rule);
                        Navigator.of(context).pop();
                        Navigator.of(_context).pop();
                      },
                    ),
                  ],
                );
              },
            );
            break;
          case MenuEditRule.help:
            launch('https://github.com/mabDc/eso_source/blob/master/README.md');
            break;
          default:
        }
      },
    );
  }
}
