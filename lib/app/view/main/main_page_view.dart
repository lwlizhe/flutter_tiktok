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

  @override
  Widget buildView(BuildContext context, BaseViewModel viewModel) {
    List<Widget> currentWidgetList = buildMenus();

    return Scaffold(
      body: ListView(
        physics: const PageScrollPhysics().applyTo(const ClampingScrollPhysics()),
        scrollDirection: Axis.horizontal,
        children: currentWidgetList,
      ),
    );
  }

  @override
  BaseViewModel buildViewModel(BuildContext context) {
    return null;
  }

  @override
  void loadData(BuildContext context, BaseViewModel viewModel) {}

  @override
  void initData() {}

  List<Widget> buildMenus() {
    List<Widget> result = [];

    result.add(Container(
      width: MediaQuery.of(context).size.width,
      height: double.infinity,
      child: MainPageContentView((type) {
        setState(() {
          _contentType = type;
        });
      }, _contentType),
    ));
    switch (_contentType) {
      case MainPageContentType.TYPE_DISCOVERY:
        result.add(Container(
          width: MediaQuery.of(context).size.width,
          height: double.infinity,
          color: Colors.red,
          alignment: Alignment.center,
          child: Text("放详情页的地方"),
        ));
        break;
      case MainPageContentType.TYPE_MINE:
        result.add(Container(
          height: double.infinity,
          width: 300,
          color: Colors.blue,
          alignment: Alignment.center,
          child: Text("放个人菜单的地方"),
        ));
        break;
      default:
        break;
    }

    return result;
  }
}
