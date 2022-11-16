import 'package:flutter/material.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import 'package:eso/menu/menu_item.dart' as ESO;
import '../fonticons_icons.dart';
import '../global.dart';
import 'menu_item.dart';

enum MenuChapter {
  refresh,
  clear_cache,
  edit,
  edit_rule,
  change,
  open_host_url,
  open_item_url,
  open_chapter_url,
  share,
}

List<ESO.MenuItem<MenuChapter>> chapterMenus = [
  ESO.MenuItem<MenuChapter>(
    text: '刷新',
    icon: OMIcons.refresh,
    value: MenuChapter.refresh,
    color: Global.primaryColor,
  ),
  ESO.MenuItem<MenuChapter>(
    text: '清理缓存',
    icon: Icons.cleaning_services_outlined,
    value: MenuChapter.clear_cache,
    color: Global.primaryColor,
  ),
  ESO.MenuItem<MenuChapter>(
    text: '编辑',
    icon: OMIcons.edit,
    value: MenuChapter.edit,
    color: Global.primaryColor,
  ),
  ESO.MenuItem<MenuChapter>(
    text: '编辑规则',
    icon: OMIcons.settingsEthernet,
    value: MenuChapter.edit_rule,
    color: Global.primaryColor,
  ),
  ESO.MenuItem<MenuChapter>(
    text: '换源',
    icon: OMIcons.changeHistory,
    value: MenuChapter.change,
    color: Global.primaryColor,
  ),
  ESO.MenuItem<MenuChapter>(
    text: '分享',
    icon: FIcons.share_2,
    value: MenuChapter.share,
    color: Global.primaryColor,
  ),
  ESO.MenuItem<MenuChapter>(
    text: '规则网址',
    icon: OMIcons.openInBrowser,
    value: MenuChapter.open_host_url,
    color: Global.primaryColor,
  ),
  ESO.MenuItem<MenuChapter>(
    text: '书籍网址',
    icon: OMIcons.openInBrowser,
    value: MenuChapter.open_item_url,
    color: Global.primaryColor,
  ),
  ESO.MenuItem<MenuChapter>(
    text: '目录网址',
    icon: OMIcons.openInBrowser,
    value: MenuChapter.open_chapter_url,
    color: Global.primaryColor,
  ),
];
