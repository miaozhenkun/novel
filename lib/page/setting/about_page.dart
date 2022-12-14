import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:eso/page/add_local_item_page.dart';
import 'package:eso/page/history_page.dart';
import 'package:eso/page/setting/font_family_page.dart';
import 'package:eso/page/setting/ui_setting.dart';
import 'package:eso/page/source/edit_source_page.dart';
import 'package:eso/qing/const.dart' as qing;
import 'package:eso/utils.dart';
import 'package:eso/utils/cache_util.dart';
import 'package:filesystem_picker/filesystem_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:text_composition/text_composition_config.dart';
import 'package:text_composition/text_composition_const.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../database/text_config_manager.dart';
import '../../global.dart';
import '../../eso_theme.dart';
import '../../qing/main.dart';
import 'auto_backup_page.dart';
import 'package:about/about.dart';

import 'theme_page.dart';

class AboutPage extends StatefulWidget {
  @override
  _AboutPageState createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  var isLargeScreen = false;
  Widget detailPage;

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(builder: (context, orientation) {
      if (MediaQuery.of(context).size.width > 600) {
        isLargeScreen = true;
      } else {
        isLargeScreen = false;
      }

      return Row(children: <Widget>[
        Expanded(
          child: AboutPage2(invokeTap: (Widget detailPage) {
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
          }),
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
}

class AboutPage2 extends StatelessWidget {
  final void Function(Widget) invokeTap;
  const AboutPage2({Key key, this.invokeTap}) : super(key: key);

  joinGroup([String group]) {
    final key =
        "7588a53508787a254b910d39476959823e3f36a7c894a6fc72504ac92e782ec2"; //1???key
    if (Global.isDesktop) {
      final s = "https://shang.qq.com/wpa/qunwpa?idkey=$key&source_id=1_40001";
      launchUrl(Uri.parse(s));
    } else {
      //Flutter ??????(??????)QQ???????????????QQ??????
      //https://www.jianshu.com/p/8dc54ef6329c
      final s =
          'mqqapi://card/show_pslcard?src_type=internal&version=1&uin=${group ?? 1106156709}&card_type=group&source=qrcode';
      launchUrl(Uri.parse(s));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(Global.appName)),
      body: () {
        final profile = ESOTheme();
        return ListView(
          children: <Widget>[
            Card(
              child: Column(
                children: <Widget>[
                  ListTile(
                    title: Text(
                      '??????',
                      style: TextStyle(color: Theme.of(context).primaryColor),
                    ),
                  ),
                  Divider(),
                  ListTile(
                    title: Text('????????????'),
                    subtitle: Text('??????txt??????epub'),
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddLocalItemPage(),
                        )),
                  ),
                  if (ESOTheme().showHistoryOnAbout)
                    ListTile(
                      title: Text('????????????'),
                      subtitle: Text('????????????????????????????????????'),
                      onTap: () => invokeTap(HistoryPage(
                          // invokeTap: invokeTap,
                          )),
                    ),
                  ListTile(
                    title: Text('????????????'),
                    subtitle: Text('???????????????????????????????????????'),
                    onTap: () => invokeTap(EditSourcePage()),
                  ),
                  ListTile(
                    title: Text('QING'),
                    subtitle: Text('?????????????????????????????????'),
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RequestAndParserTestTool(),
                        )),
                  ),
                  ListTile(
                    title: Text('???????????????webdav'),
                    subtitle: Text('????????????????????????webdav???????????????'),
                    onTap: () => invokeTap(AutoBackupPage()),
                  ),
                  ListTile(
                    title: Text('????????????'),
                    subtitle: Text('??????????????????????????????'),
                    onTap: () async {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) => AlertDialog(
                          backgroundColor: Theme.of(context).canvasColor,
                          title: Text("????????????"),
                          content: Text("????????????????????????????????????????????????????????????"),
                          actions: <Widget>[
                            TextButton(
                                child: Text('??????',
                                    style: TextStyle(color: Theme.of(context).hintColor)),
                                onPressed: () => Navigator.pop(context)),
                            TextButton(
                                child: Text('????????????'),
                                onPressed: () async {
                                  Navigator.pop(context);
                                  await CacheUtil().clear(allCache: true);
                                  Utils.toast("??????????????????");
                                }),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: 4),
            Card(
              child: Column(
                children: <Widget>[
                  ListTile(
                    title: Text(
                      '??????',
                      style: TextStyle(color: Theme.of(context).primaryColor),
                    ),
                  ),
                  Divider(),
                  ListTile(
                    title: Text('????????????'),
                    subtitle: Text('???????????????????????????'),
                    onTap: () => invokeTap(ConfigSettingPage()),
                  ),
                  ListTile(
                    title: Text('???????????????'),
                    subtitle: Text('???????????????????????????????????????'),
                    onTap: () => invokeTap(UISetting()),
                  ),
                  ListTile(
                    title: Text('????????????'),
                    subtitle: Text('??????????????????'),
                    onTap: () => invokeTap(ThemePage()),
                  ),
                  ListTile(
                    title: Text('????????????'),
                    subtitle: Text('?????????????????????????????????'),
                    onTap: () => invokeTap(FontFamilyPage()),
                  ),
                ],
              ),
            ),
            SizedBox(height: 4),
            Card(
              child: Column(
                children: <Widget>[
                  ListTile(
                    title: Text(
                      '??????&??????',
                      style: TextStyle(color: Theme.of(context).primaryColor),
                    ),
                  ),
                  Divider(),
                  ListTile(
                    title: Text('????????????'),
                    subtitle: Text('1106156709'),
                    onTap: () => joinGroup(),
                  ),
                  ListTile(
                    title: Text('????????????'),
                    subtitle: Text('1148443231'),
                    onTap: () => joinGroup('1148443231'),
                  ),
                  ListTile(
                    title: Text(qing.joinPindao),
                    subtitle: Image.memory(
                      base64Decode(qing.esoPindao.base64.split(',')[1]),
                      fit: BoxFit.contain,
                      height: 150,
                      width: 150,
                      alignment: Alignment.topLeft,
                    ),
                    onTap: () => launch(qing.esoPindao.url),
                  ),
                  ListTile(
                    title: Text('????????????'),
                    subtitle: Text('https://github.com/mabDc/eso_source/'),
                    onTap: () => launch('https://github.com/mabDc/eso_source/'),
                  ),
                  ListTile(
                    title: Text('????????????'),
                    subtitle: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                          'https://github.com/mabDc/eso_source/blob/master/README.md'),
                    ),
                    onTap: () => launch(
                        'https://github.com/mabDc/eso_source/blob/master/README.md'),
                  ),
                ],
              ),
            ),
            SizedBox(height: 4),
            Card(
              child: Column(
                children: <Widget>[
                  ListTile(
                    title: Text(
                      '???????????????',
                      style: TextStyle(color: Theme.of(context).primaryColor),
                    ),
                  ),
                  Divider(),
                  ListTile(
                    title: Text('mabdc'),
                    subtitle: Text('https://github.com/mabDc'),
                    onTap: () => launch('https://github.com/mabDc'),
                  ),
                  ListTile(
                    title: Text('DaguDuiyuan'),
                    subtitle: Text('https://github.com/DaguDuiyuan'),
                    onTap: () => launch('https://github.com/DaguDuiyuan'),
                  ),
                  ListTile(
                    title: Text('yangyxd'),
                    subtitle: Text('https://github.com/yangyxd'),
                    onTap: () => launch('https://github.com/yangyxd'),
                  ),
                ],
              ),
            ),
            SizedBox(height: 4),
            Card(
              child: Column(
                children: <Widget>[
                  ListTile(
                    title: Text(
                      '??????',
                      style: TextStyle(color: Theme.of(context).primaryColor),
                    ),
                  ),
                  Divider(),
                  MarkdownPageListTile(
                    filename: 'README.md',
                    title: Text('????????????'),
                    // icon: Icon(Icons.info_outline),
                  ),
                  MarkdownPageListTile(
                    filename: 'CHANGELOG.md',
                    title: Text('????????????'),
                    // icon: Icon(FIcons.list),
                  ),
                  MarkdownPageListTile(
                    filename: 'LICENSE',
                    title: Text('???????????????'),
                    // icon: Icon(Icons.description),
                  ),
                  ListTile(
                    title: Text('????????????'),
                    subtitle: Text('https://github.com/mabDc/eso'),
                    onTap: () => launch('https://github.com/mabDc/eso'),
                  ),
                  ListTile(
                    title: Text('????????????'),
                    subtitle: Text('https://github.com/mabDc/eso/issues'),
                    onTap: () => launch('https://github.com/mabDc/eso/issues'),
                  ),
                  ListTile(
                    title: Text('${Global.appName} - ${Global.appVersion}'),
                    subtitle: Text('https://github.com/mabDc/eso/releases'),
                    onTap: () => launch('https://github.com/mabDc/eso/releases'),
                  ),
                ],
              ),
            ),
            Card(
              child: Material(
                color: Theme.of(context).primaryColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
                child: InkWell(
                  onTap: () => showAbout(context),
                  child: SizedBox(
                    height: 260,
                    width: double.infinity,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            'ESO',
                            style: TextStyle(
                              fontSize: 100,
                              fontStyle: FontStyle.italic,
                              color: Theme.of(context).cardColor,
                            ),
                          ),
                          Text(
                            '????????????????????????',
                            style: TextStyle(
                              fontSize: 20,
                              color: Theme.of(context).cardColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      }(),
    );
  }

  static void showAbout(BuildContext context, [bool showClose = false]) =>
      showAboutDialog(
        applicationLegalese:
            '?????? ${Global.appVersion}\n?????? ${Global.appBuildNumber}\n?????? ${Global.appPackageName}',
        applicationIcon: Image.asset(
          Global.logoPath,
          width: 50,
          height: 50,
        ),
        context: context,
        applicationVersion: '????????????????????????',
        children: <Widget>[
          MarkdownPageListTile(
            filename: 'README.md',
            title: Text('????????????'),
            icon: Icon(Icons.info_outline),
          ),
          MarkdownPageListTile(
            filename: 'CHANGELOG.md',
            title: Text('????????????'),
            icon: Icon(Icons.history),
          ),
          MarkdownPageListTile(
            filename: 'LICENSE',
            title: Text('???????????????'),
            icon: Icon(Icons.description),
          ),
          if (Platform.isWindows)
            ListTile(
              title: Text("SQLite ?????????"),
              // subtitle: Text(SQFLiteWinUtil.dllPath()),
              leading: Icon(Icons.link),
            ),
          if (Platform.isLinux)
            ListTile(
              title: Text("libsqlite3-dev"),
              // subtitle: Text(SQFLiteWinUtil.dllPath()),
              leading: Icon(Icons.link),
            ),
          if (showClose)
            InkWell(
              child: ListTile(
                leading: Icon(Icons.close),
                title: Text("????????????"),
              ),
              onTap: () {
                ESOTheme().updateVersion();
                Utils.toast("???????????????????????????");
                Navigator.of(context).pop();
              },
            ),
        ],
      );
}

class ConfigSettingPage extends StatefulWidget {
  const ConfigSettingPage({Key key}) : super(key: key);

  @override
  _ConfigSettingPageState createState() => _ConfigSettingPageState();
}

class _ConfigSettingPageState extends State<ConfigSettingPage> {
  TextCompositionConfig config;
  @override
  void initState() {
    config = TextConfigManager.config;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("????????????")),
      body: myConfigSettingBuilder(context, config),
    );
  }

  @override
  void dispose() {
    TextConfigManager.config = config;
    super.dispose();
  }
}

Widget myConfigSettingBuilder(BuildContext context, TextCompositionConfig config) {
  return configSettingBuilder(
    context,
    config,
    (Color color, void Function(Color color) onChange) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('????????????'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: color,
              onColorChanged: onChange,
              labelTypes: [],
              pickerAreaHeightPercent: 0.8,
              portraitOnly: true,
              hexInputBar: true,
            ),
          ),
        ),
      );
    },
    (String s, void Function(String s) onChange) async {
      print("????????????");
      final _cacheUtil = CacheUtil(backup: true, basePath: "background");
      final dir = await _cacheUtil.cacheDir();
      String path = await FilesystemPicker.open(
        title: '????????????',
        context: context,
        rootDirectory: Directory(dir),
        rootName: dir,
        fsType: FilesystemType.file,
        folderIconColor: Colors.teal,
        allowedExtensions: ['.jpg', '.png', '.webp'],
        fileTileSelectMode: FileTileSelectMode.wholeTile,
        requestPermission: CacheUtil.requestPermission,
      );
      if (path == null) {
        Utils.toast("???????????????");
        // onChange('');
      } else {
        final file = File(path);
        final name = Utils.getFileNameAndExt(path);
        await _cacheUtil.putFile(name, file);
        Utils.toast('?????? $name ???????????? $dir');
        onChange(dir + name);
      }
    },
    (String s, void Function(String s) onChange) async {
      print("????????????");
      final _cacheUtil = CacheUtil(backup: true, basePath: "font");
      final dir = await _cacheUtil.cacheDir();
      String ttf = await FilesystemPicker.open(
        title: '????????????',
        context: context,
        rootName: dir,
        rootDirectory: Directory(dir),
        fsType: FilesystemType.file,
        folderIconColor: Colors.teal,
        allowedExtensions: ['.ttf', '.ttc', '.otf'],
        fileTileSelectMode: FileTileSelectMode.wholeTile,
        requestPermission: CacheUtil.requestPermission,
      );
      if (ttf == null) {
        Utils.toast('?????????????????????');
        // onChange('');
        return;
      }
      final file = File(ttf);
      final name = Utils.getFileNameAndExt(ttf);
      await _cacheUtil.putFile(name, file);
      await loadFontFromList(file.readAsBytesSync(), fontFamily: name);
      Utils.toast('?????? $name ???????????? $dir');
      onChange(name);
    },
  );
}
