import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'base_provider.dart';

enum AppNightState {
  STATE_NIGHT,
  STATE_DAY,
}

class ConfigProvider extends BaseProvider {

  AppNightState nightState = AppNightState.STATE_NIGHT;

  @override
  Widget getProviderContainer() {
    return ChangeNotifierProvider(create: (BuildContext context) {
      return ConfigProvider();
    });
  }
}
