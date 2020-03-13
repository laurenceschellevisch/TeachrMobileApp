import 'package:flutter/material.dart';
import 'package:teachr/language/localizations.dart';
import 'package:teachr/globals.dart' as globals;

enum TabItem { profile, offers, chat }

class TabHelper {
  static TabItem item({int index}) {
    switch (index) {
      case 0:
        return TabItem.profile;
      case 1:
        return TabItem.offers;
      case 2:
        return TabItem.chat;
    }
    return TabItem.profile;
  }

  static String description(TabItem tabItem, BuildContext context) {
    switch (tabItem) {
      case TabItem.profile:
        return LangLocalizations.of(context).trans('profile');
      case TabItem.offers:
        return LangLocalizations.of(context).trans('offers');
      case TabItem.chat:
        return LangLocalizations.of(context).trans('chat');
    }
    return '';
  }

  static IconData icon(TabItem tabItem) {
    switch (tabItem) {
      case TabItem.profile:
        return Icons.account_circle;
      case TabItem.offers:
        return Icons.layers;
      case TabItem.chat:
        return Icons.chat;
    }
    return Icons.crop_square;
  }
}

class BottomNavigation extends StatefulWidget {
  BottomNavigation({this.currentTab, this.onSelectTab});
  final TabItem currentTab;
  final ValueChanged<TabItem> onSelectTab;
  static Function refresh;

  @override
  BottomNavState createState() => new BottomNavState();
}

class BottomNavState extends State<BottomNavigation> {
  bool chatMarble;

  @override
  void initState() {
    super.initState();
    chatMarble = globals.newMessages;
  }

  refreshH() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      items: [
        _buildItem(tabItem: TabItem.profile, context: context),
        _buildItem(tabItem: TabItem.offers, context: context),
        _buildItem(tabItem: TabItem.chat, context: context),
      ],
      onTap: (index) => widget.onSelectTab(
            TabHelper.item(index: index),
          ),
    );
  }

  BottomNavigationBarItem _buildItem({TabItem tabItem, BuildContext context}) {
    String text = TabHelper.description(tabItem, context);
    IconData icon = TabHelper.icon(tabItem);

    return BottomNavigationBarItem(
      icon: chatIconSelector(tabItem, icon),
      title: Text(
        text,
        style: TextStyle(
          color: _colorTabMatching(item: tabItem),
        ),
      ),
    );
  }

  Color _colorTabMatching({TabItem item}) {
    return widget.currentTab == item ? Color(0xFF3051ff) : Colors.grey;
  }

  Widget chatIconSelector(TabItem tabItem, IconData icon) {
    if (tabItem == TabItem.chat && chatMarble) {
      return chatMarbleIcon(tabItem, icon);
    }
    return defaultIcon(tabItem, icon);
  }

  Widget chatMarbleIcon(TabItem tabItem, IconData icon) {
    return Stack(children: <Widget>[
      new Icon(
        icon,
        color: _colorTabMatching(item: tabItem),
      ),
      new Positioned(
        // draw a red marble
        top: 0.0,
        right: 0.0,
        child: new Icon(Icons.brightness_1, size: 8.0, color: Colors.redAccent),
      )
    ]);
  }

  Widget defaultIcon(TabItem tabItem, IconData icon) {
    return Icon(
      icon,
      color: _colorTabMatching(item: tabItem),
    );
  }
}