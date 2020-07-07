import 'package:flutter/material.dart';
import 'package:flutter_tiktok/base/structure/base_view.dart';
import 'package:flutter_tiktok/base/structure/base_view_model.dart';

class CameraPreviewActivity extends BaseStatefulView {
  @override
  BaseStatefulViewState<BaseStatefulView<BaseViewModel>, BaseViewModel>
      buildState() {
    return _CameraPreviewActivityState();
  }
}

class _CameraPreviewActivityState
    extends BaseStatefulViewState<CameraPreviewActivity, BaseViewModel> {
  @override
  Widget buildView(BuildContext context, BaseViewModel viewModel) {
    return Scaffold(
      body: Container(),
    );
  }

  @override
  BaseViewModel buildViewModel(BuildContext context) {
    return null;
  }

  @override
  void initData() {}

  @override
  void loadData(BuildContext context, BaseViewModel viewModel) {}
}
