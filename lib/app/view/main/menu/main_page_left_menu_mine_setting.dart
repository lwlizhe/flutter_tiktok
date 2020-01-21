import 'package:flutter/material.dart';
import 'package:flutter_tiktok/app/viewmodel/main/menu/main_page_user_setting_view_model.dart';
import 'package:flutter_tiktok/app/viewmodel/user_info_view_model.dart';
import 'package:flutter_tiktok/base/structure/base_view.dart';
import 'package:provider/provider.dart';

class MainPageLeftMenuUserSettingPage extends BaseStatelessView<UserInfoViewModel>{
  @override
  Widget buildView(BuildContext context, UserInfoViewModel viewModel) {
    return Container(
      height: double.infinity,
      width: 300,
      color: Colors.blue,
      alignment: Alignment.center,
      child: Text("放个人菜单的地方"),
    );
  }

  @override
  UserInfoViewModel buildViewModel(BuildContext context) {
    return UserInfoViewModel(Provider.of(context));
  }

  @override
  void loadData(BuildContext context, UserInfoViewModel viewModel) {
  }

}