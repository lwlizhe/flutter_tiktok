import 'package:flutter_tiktok/base/structure/provider/config_provider.dart';
import 'package:provider/provider.dart';


List<SingleChildCloneableWidget> providers = []
  ..addAll(independentServices)
  ..addAll(dependentServices)
  ..addAll(uiConsumableProviders);

/// 静态资源，这样也可以不用写单例了吧
List<SingleChildCloneableWidget> independentServices = [
//  Provider.value(value: UserModel()),

];

List<SingleChildCloneableWidget> dependentServices = [
//  ProxyProvider<UserModel, UserInfoViewModel>(
//    update: (context, model, netModel) => UserInfoViewModel(api),
//  ),
  ConfigProvider().getProviderContainer(),
];

List<SingleChildCloneableWidget> uiConsumableProviders = [
  ProxyProvider<ConfigProvider, AppNightState>(
    update: (context, configProvider, nightModeConfig) =>
        Provider.of<ConfigProvider>(context, listen: false).nightState,
  ),

];
