import 'package:flutter/material.dart';
import 'package:flutter_tiktok/app/viewmodel/user_info_view_model.dart';
import 'package:flutter_tiktok/base/structure/base_view.dart';
import 'package:provider/provider.dart';

class MainPageLeftMenuUserDetailPage extends BaseStatelessView<UserInfoViewModel>{
  @override
  Widget buildView(BuildContext context, UserInfoViewModel viewModel) {
    return null;
  }

  @override
  UserInfoViewModel buildViewModel(BuildContext context) {
    return Provider.of(context);
  }

  @override
  void loadData(BuildContext context, UserInfoViewModel viewModel) {
  }

  @override
  bool isBindViewModel() {
    return false;
  }
}