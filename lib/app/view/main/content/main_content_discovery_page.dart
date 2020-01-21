import 'package:flutter/material.dart';
import 'package:flutter_tiktok/base/structure/base_view.dart';
import 'package:flutter_tiktok/base/structure/base_view_model.dart';
import 'package:flutter_tiktok/base/util/utils_toast.dart';
import 'package:flutter_tiktok/widget/nested_tab_view.dart';

import 'recommend/main_content_discovery_recommend_page.dart';

class MainContentDiscoveryPage extends BaseStatefulView {
  @override
  BaseStatefulViewState<BaseStatefulView<BaseViewModel>, BaseViewModel>
      buildState() {
    return _MainContentDiscoveryPageState();
  }
}

class _MainContentDiscoveryPageState
    extends BaseStatefulViewState<MainContentDiscoveryPage, BaseViewModel>
    with SingleTickerProviderStateMixin {
  TabController _primaryTC;

  final List<Tab> tabs = [
    Tab(
      text: "关注",
    ),
    Tab(
      text: "推荐",
    )
  ];

  @override
  Widget buildView(BuildContext context, BaseViewModel viewModel) {
    return LayoutBuilder(builder: (context,boxConstrain){
      return SafeArea(child: Container(
        width: boxConstrain.maxWidth,
        height: boxConstrain.maxHeight,
        child: Stack(
          children: <Widget>[
            NestedTabBarView(
                controller: _primaryTC,
                children: tabs
                    .map((tab) => Container(
                  color: const Color(0xff181824),
                  child:MainContentDiscoveryRecommendPageView(),
                  width: double.infinity,
                  height: double.infinity,
                  alignment: Alignment.center,
                ))
                    .toList()),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                IconButton(
                    icon: Icon(
                      Icons.live_tv,
                      color: Colors.grey[400],
                      size: 28,
                    ),
                    onPressed: () {
                      ToastUtils.showToast("跳转一个直播页面好像");
                    }),
                TabBar(
                  tabs: tabs,
                  labelColor: Colors.white,
                  labelStyle:
                  TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  unselectedLabelColor: Colors.grey[400],
                  unselectedLabelStyle:
                  TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  controller: _primaryTC,
                  indicatorColor: Colors.white,
                  indicatorSize: TabBarIndicatorSize.label,
                  indicatorPadding: EdgeInsets.only(left: 5, right: 5),
                  isScrollable: true,
                ),
                IconButton(
                    icon: Icon(
                      Icons.search,
                      color: Colors.grey[400],
                      size: 28,
                    ),
                    onPressed: () {
                      ToastUtils.showToast("跳转一个搜索页面好像");
                    })
              ],
            )
          ],
        ),
      ));
    },);
  }

  @override
  BaseViewModel buildViewModel(BuildContext context) {
    return null;
  }

  @override
  void initData() {
    _primaryTC = TabController(length: tabs.length, vsync: this);
    _primaryTC.index = tabs.length - 1;
  }

  @override
  void loadData(BuildContext context, BaseViewModel viewModel) {}
}
