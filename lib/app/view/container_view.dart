import 'package:flutter/material.dart';
import 'package:flutter_tiktok/base/structure/base_view.dart';
import 'package:flutter_tiktok/base/structure/base_view_model.dart';
import 'package:flutter_tiktok/widget/nested_page_controller.dart';
import 'package:flutter_tiktok/widget/nested_page_view.dart';

import 'main/main_page_content_view.dart';
import 'main/menu/main_page_left_menu_mine_setting.dart';
import 'main/menu/main_page_left_menu_user_detial.dart';

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
      body: NestedPrimaryPageView(
        childController: NestedPageController(initialPage: 1),
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
        result.add(MainPageLeftMenuUserDetailPage());
        break;
      case MainPageContentType.TYPE_MINE:
        result.add(MainPageLeftMenuUserSettingPage());
        break;
      default:
        break;
    }

    return result;
  }
}
