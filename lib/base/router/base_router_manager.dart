import 'package:flutter/material.dart';

abstract class BaseRouterManager {

  const BaseRouterManager();

  @protected
  void jumpToTarget(RouterRequestOption option,Widget targetRouterWidget) {
    Navigator.push(
        option.context,
        option.customRouter == null
            ? MaterialPageRoute(builder: (context) {
                return targetRouterWidget;
              })
            : option.customRouter);
  }

}

class RouterRequestOption {

  BuildContext context;

  Route customRouter;

  RouterRequestOption(this.context, {this.customRouter});
}
