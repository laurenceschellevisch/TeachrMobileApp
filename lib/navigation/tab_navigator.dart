import 'package:flutter/material.dart';
import 'bottom_navigation.dart';
import 'content_container.dart';

class TabNavigatorRoutes {
  static const String profile = '/';
  static const String offers = '/offers';
  static const String chat = '/chat';
}

class TabNavigator extends StatelessWidget {
  TabNavigator({this.navigatorKey, this.tabItem});
  final GlobalKey<NavigatorState> navigatorKey;
  final TabItem tabItem;

  Map<String, WidgetBuilder> _routeBuilders(BuildContext context) {
    return {
      //profile
      TabNavigatorRoutes.profile: (context) => ContentPage(
            title: TabHelper.description(tabItem, context),
            index: tabItem.index,
            // onPush: (materialIndex) =>
            //     _push(context, materialIndex: materialIndex),
          ),
      //offers
      TabNavigatorRoutes.offers: (context) => ContentPage(
            title: TabHelper.description(tabItem, context),
            index: tabItem.index,
          ),
      //chat
      TabNavigatorRoutes.chat: (context) => ContentPage(
            title: TabHelper.description(tabItem, context),
            index: tabItem.index,
          ),
    };
  }

  @override
  Widget build(BuildContext context) {
    Map routeBuilders = _routeBuilders(context);

    return Navigator(
        key: navigatorKey,
        initialRoute: TabNavigatorRoutes.offers,
        onGenerateRoute: (routeSettings) {
          return MaterialPageRoute(
            builder: (context) => routeBuilders[routeSettings.name](context),
          );
        });
  }
}
