import 'package:flutter/material.dart';
import 'package:flutter_tiktok/app/model/user_model.dart';
import 'package:flutter_tiktok/base/structure/base_view_model.dart';

class UserInfoViewModel extends BaseViewModel{

  UserModel _userModel;

  UserInfoViewModel(this._userModel);

  @override
  Widget getProviderContainer() {
    return null;
  }

}