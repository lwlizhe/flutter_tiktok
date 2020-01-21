import 'package:flutter_tiktok/app/constant/api.dart';
import 'package:flutter_tiktok/base/structure/provider/config_provider.dart';
import 'package:provider/provider.dart';

import 'model/user_model.dart';
import 'viewmodel/user_info_view_model.dart';

List<SingleChildCloneableWidget> providers = []
  ..addAll(independentServices)
  ..addAll(dependentServices)
  ..addAll(uiConsumableProviders);

/// 静态资源，这样也可以不用写单例了吧
List<SingleChildCloneableWidget> independentServices = [
  Provider.value(value: UserModel()),
  Provider.value(value: NetApi()),
];

List<SingleChildCloneableWidget> dependentServices = [
//  ProxyProvider<UserModel, UserInfoViewModel>(
//    update: (context, model, netModel) => UserInfoViewModel(model),
//  ),
  ConfigProvider().getProviderContainer(),
];

List<SingleChildCloneableWidget> uiConsumableProviders = [
  ProxyProvider<ConfigProvider, AppNightState>(
    update: (context, configProvider, nightModeConfig) =>
        Provider.of<ConfigProvider>(context, listen: false).nightState,
  ),
];
