import 'package:flutter/material.dart';
import 'package:flutter_tiktok/app/viewmodel/main/menu/main_page_left_menu_view_model.dart';
import 'package:flutter_tiktok/base/structure/base_view.dart';
import 'package:provider/provider.dart';

class MainPageLeftMenuUserDetailPage extends BaseStatelessView<MainPageLeftMenuViewModel>{
  @override
  Widget buildView(BuildContext context, MainPageLeftMenuViewModel viewModel) {
    return null;
  }

  @override
  MainPageLeftMenuViewModel buildViewModel(BuildContext context) {
    return Provider.of(context);
  }

  @override
  void loadData(BuildContext context, MainPageLeftMenuViewModel viewModel) {
  }

  @override
  bool isBindViewModel() {
    return false;
  }
}