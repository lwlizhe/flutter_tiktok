import 'package:flutter/material.dart';
import 'package:flutter_tiktok/base/structure/base_view.dart';
import 'package:flutter_tiktok/base/structure/base_view_model.dart';
import 'package:flutter_tiktok/base/util/utils_toast.dart';

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
      text: "推荐",
    ),
    Tab(
      text: "关注",
    )
  ];

  @override
  Widget buildView(BuildContext context, BaseViewModel viewModel) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Stack(
        children: <Widget>[
          TabBarView(
            controller: _primaryTC,
              children: tabs
                  .map((tab) => Container(
                        child: Text(tab.text),
                        width: double.infinity,
                        height: double.infinity,
                        alignment: Alignment.center,
                      ))
                  .toList()),
          SafeArea(
              child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              IconButton(
                  icon: Icon(Icons.live_tv),
                  onPressed: () {
                    ToastUtils.showToast("跳转一个直播页面好像");
                  }),
              Expanded(
                  child: TabBar(
                tabs: tabs,
                controller: _primaryTC,
              )),
              IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    ToastUtils.showToast("跳转一个搜索页面好像");
                  })
            ],
          ))
        ],
      ),
    );
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
