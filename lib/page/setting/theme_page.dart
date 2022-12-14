import 'package:eso/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../hive/theme_box.dart';
import '../../hive/theme_mode_box.dart';

class ColorPick extends StatefulWidget {
  final int color;
  final void Function(Color) onColorChanged;
  ColorPick({Key key, this.color, this.onColorChanged}) : super(key: key);

  @override
  State<ColorPick> createState() => _ColorPickState();
}

class _ColorPickState extends State<ColorPick> {
  Color pickerColor;
  @override
  void initState() {
    super.initState();
    pickerColor = Color(widget.color);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Builder(builder: (context) {
        return ColorPicker(
          pickerColor: pickerColor,
          onColorChanged: (color) {
            setState(() {
              pickerColor = color;
            });
            widget.onColorChanged(color);
          },
          labelTypes: [],
          hexInputBar: true,
          portraitOnly: true,
        );
      }),
    );
  }
}

class ThemePage extends StatelessWidget {
  const ThemePage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    pick(String title, String key, int dColor) => ListTile(
          title: Text(title),
          trailing: ValueListenableBuilder<Box>(
            valueListenable: themeBox.listenable(keys: <String>[key]),
            builder: (BuildContext context, Box _, Widget child) {
              return Container(
                color: Color(themeBox.get(key, defaultValue: dColor)),
                width: 20,
                height: 20,
              );
            },
          ),
          onTap: () => showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(title),
              content: ColorPick(
                  color: themeBox.get(key, defaultValue: dColor),
                  onColorChanged: (val) => themeBox.put(key, val.value)),
            ),
          ),
        );

    return ValueListenableBuilder<Box>(
        valueListenable: themeBox.listenable(keys: <String>[decorationImageKey]),
        builder: (BuildContext context, Box _, Widget child) {
          return Container(
            decoration: globalDecoration,
            child: Scaffold(
                appBar: AppBar(title: Text('????????????')),
                body: ListView(
                  children: [
                    Card(
                      child: Column(
                        children: [
                          ListTile(
                            leading: const Icon(Icons.color_lens),
                            title: const Text("?????????"),
                          ),
                          pick('?????????', primaryColorKey, colors["?????????"]),
                          pick('?????????', iconColorKey, colors["????????????"]),
                        ],
                      ),
                    ),
                    Card(
                      child: ValueListenableBuilder<Box<int>>(
                        valueListenable: themeModeBox.listenable(),
                        builder: (BuildContext context, Box<int> box, Widget child) {
                          const done = const Icon(Icons.done, size: 32);
                          return Column(
                            children: [
                              ListTile(
                                leading: const Icon(Icons.auto_mode_outlined),
                                title: Text("????????????"),
                                onTap: () => themeMode = ThemeMode.system.index,
                                trailing:
                                    ThemeMode.system.index == themeMode ? done : null,
                              ),
                              ListTile(
                                leading: const Icon(Icons.light_mode_outlined),
                                title: Text("????????????"),
                                onTap: () => themeMode = ThemeMode.light.index,
                                trailing:
                                    ThemeMode.light.index == themeMode ? done : null,
                              ),
                              pick('???????????????', appBarForegroundColorKey, colors["?????????"]),
                              pick('???????????????', appBarBackgroundColorKey, colors["?????????"]),
                              pick('???????????????', scaffoldBackgroundColorKey, colors["?????????"]),
                              pick('???????????????', cardBackgroundColorKey, colors["?????????"]),
                              ListTile(
                                leading: const Icon(Icons.dark_mode_outlined),
                                title: Text("????????????"),
                                onTap: () => themeMode = ThemeMode.dark.index,
                                trailing: ThemeMode.dark.index == themeMode ? done : null,
                              ),
                              pick('???????????????', appBarForegroundDarkColorKey, colors["?????????"]),
                              pick('???????????????', appBarBackgroundDarkColorKey, colors["?????????"]),
                              pick(
                                  '???????????????', scaffoldBackgroundDarkColorKey, colors["?????????"]),
                              pick('???????????????', cardBackgroundDarkColorKey, colors["?????????"]),
                            ],
                          );
                        },
                      ),
                    ),
                    Card(
                      child: Material(
                        color: Colors.transparent,
                        child: Wrap(
                          alignment: WrapAlignment.center,
                          children: [
                            "??????1",
                            "??????2",
                            "??????3",
                            "??????4",
                            "??????1",
                            "??????2",
                            ...List.generate(13, (index) => "???${index + 1}"),
                          ].map((u) {
                            return InkWell(
                              onTap: () {
                                themeBox.put(decorationImageKey, "assets/ba/$u.jpg");
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Image.asset(
                                  "assets/ba/$u.jpg",
                                  height: 200,
                                  width: 100,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    Card(
                      child: Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        alignment: WrapAlignment.center,
                        children: [
                          for (final color in colors.entries)
                            Chip(
                              backgroundColor: Color(color.value),
                              labelStyle: TextStyle(color: Colors.black),
                              label:
                                  Text(color.key + " #${color.value.toRadixString(16)}"),
                              onDeleted: () {
                                Clipboard.setData(ClipboardData(
                                    text:
                                        "#${color.value.toRadixString(16).substring(2)}"));
                              },
                              deleteButtonTooltipMessage: "??????",
                              deleteIcon: Icon(
                                Icons.copy,
                                size: 16,
                              ),
                            )
                        ],
                      ),
                    ),
                  ],
                )),
          );
        });
  }
}
