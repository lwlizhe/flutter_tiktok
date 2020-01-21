import 'package:flutter/material.dart';
import 'package:flutter_tiktok/app/view/main/content/widget/widget_main_content_discovery_video.dart';
import 'package:flutter_tiktok/app/viewmodel/main/content/main_content_discovery_view_model.dart';
import 'package:flutter_tiktok/base/structure/base_view.dart';
import 'package:provider/provider.dart';

class MainContentDiscoveryRecommendPageView
    extends BaseStatefulView<MainContentDiscoveryViewModel> {
  @override
  BaseStatefulViewState<MainContentDiscoveryRecommendPageView,
      MainContentDiscoveryViewModel> buildState() {
    return _MainContentDiscoveryRecommendPageViewState();
  }
}

class _MainContentDiscoveryRecommendPageViewState extends BaseStatefulViewState<
    MainContentDiscoveryRecommendPageView, MainContentDiscoveryViewModel> {
  @override
  Widget buildView(BuildContext context, viewModel) {

    List<String> videoList=["assets/videos/wodexiaomubiao1.mp4","assets/videos/wodexiaomubiao2.mp4","assets/videos/wodexiaomubiao3.mp4"];

    return LayoutBuilder(builder: (context,constrains){
      return ListView.builder(
          scrollDirection: Axis.vertical,
          physics: PageScrollPhysics().applyTo(ClampingScrollPhysics()),
          itemCount: videoList.length,
          primary: false,
          itemBuilder: (context, int index) {
            return MainContentDiscoveryVideoListWidget(
                videoList[index],constrains);
          });
    },);
  }

  @override
  buildViewModel(BuildContext context) {
    return MainContentDiscoveryViewModel(Provider.of(context));
  }

  @override
  void initData() {}

  @override
  void loadData(BuildContext context, viewModel) {}
}
