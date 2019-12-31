import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

import 'provider/base_provider.dart';

/// 对model的数据进行处理，是跟view逻辑相关的部分
abstract class BaseViewModel extends BaseProvider{

  LoadingStateEnum isLoading=LoadingStateEnum.IDLE;

  bool isDisposed=false;

  @protected
  void refreshRequestState(LoadingStateEnum state){
    isLoading=state;
  }

  @override
  void dispose() {
    super.dispose();
    isDisposed=true;
  }
}

enum LoadingStateEnum { LOADING, IDLE, ERROR }