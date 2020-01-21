import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_tiktok/app/constant/api.dart';
import 'package:flutter_tiktok/base/structure/base_view_model.dart';

class MainContentDiscoveryViewModel extends BaseViewModel{

  NetApi api;

  MainContentDiscoveryViewModel(this.api);

  MainContentDiscoveryEntity dataEntity=MainContentDiscoveryEntity();

  void getRecommendVideo(int type,bool isRefresh) async{

    List<String> videoList= await api.getVideoList(type);

    if(isRefresh){
      dataEntity.videoList.clear();
    }

    dataEntity.videoList.addAll(videoList);

    notifyListeners();

  }

  @override
  Widget getProviderContainer() {
    return null;
  }

}

class MainContentDiscoveryEntity{

  List<String> videoList=[];

}