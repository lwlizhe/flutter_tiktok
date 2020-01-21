import 'package:flutter/material.dart';
import 'package:flutter_tiktok/app/viewmodel/user_info_view_model.dart';
import 'package:flutter_tiktok/base/structure/base_view.dart';
import 'package:provider/provider.dart';

class MainPageLeftMenuUserDetailPage extends BaseStatelessView<UserInfoViewModel>{
  @override
  Widget buildView(BuildContext context, UserInfoViewModel viewModel) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: double.infinity,
      color: Colors.red,
      alignment: Alignment.center,
      child: Text("放详情页的地方"),
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