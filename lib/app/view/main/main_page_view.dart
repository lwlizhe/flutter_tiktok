import 'package:flutter/material.dart';
import 'package:flutter_tiktok/base/structure/base_view.dart';
import 'package:flutter_tiktok/base/structure/base_view_model.dart';

import 'main_page_content_view.dart';

class MainPageView extends BaseStatefulView {
  @override
  BaseStatefulViewState<BaseStatefulView<BaseViewModel>, BaseViewModel>
      buildState() {
    return _MainPageViewState();
  }
}

class _MainPageViewState extends BaseStatefulViewState {

  MainPageContentType _contentType = MainPageContentType.TYPE_DISCOVERY;

  List<Widget> currentWidgetList = [];

  @override
  Widget buildView(BuildContext context, BaseViewModel viewModel) {

    return Scaffold(
      body: PageView.custom(
          childrenDelegate: SliverChildBuilderDelegate((context, index) {
        return currentWidgetList[index];
      }, childCount: currentWidgetList.length)),
    );
  }

  @override
  BaseViewModel buildViewModel(BuildContext context) {
    return null;
  }

  @override
  void loadData(BuildContext context, BaseViewModel viewModel) {
    currentWidgetList.clear();
    currentWidgetList.add(MainPageContentView((type) {
      setState(() {
        _contentType = type;
      });
    }, _contentType));
    switch (_contentType) {
      case MainPageContentType.TYPE_DISCOVERY:
        currentWidgetList.add(Container(
          color: Colors.red,
        ));
        break;
      case MainPageContentType.TYPE_MINE:
        currentWidgetList.add(Container(
          color: Colors.blue,
        ));
        break;
      default:
        break;
    }

  }

  @override
  void initData() {}
}
