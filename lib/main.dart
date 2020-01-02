import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'app/provider_setup.dart';
import 'app/view/main/main_page_view.dart';
import 'base/structure/provider/config_provider.dart';

void main() async {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: providers,
        child: Consumer<ConfigProvider>(builder:
            (BuildContext context, ConfigProvider appInfo, Widget child) {
          return MaterialApp(
//              showPerformanceOverlay: true,
//              checkerboardOffscreenLayers: true, // 使用了saveLayer的图形会显示为棋盘格式并随着页面刷新而闪烁
//              checkerboardRasterCacheImages: true, // 做了缓存的静态图片在刷新页面时不会改变棋盘格的颜色；如果棋盘格颜色变了说明被重新缓存了，这是我们要避免的

              title: 'Flutter Novel Reader',
              theme: ThemeData(primaryColor:Colors.white,),
//              home: NovelBookIntroView("592fe687c60e3c4926b040ca"));
              home: MainPageView());
        }));
  }
}
