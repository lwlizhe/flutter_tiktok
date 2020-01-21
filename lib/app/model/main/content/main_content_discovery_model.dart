import 'package:flutter_tiktok/app/constant/api.dart';
import 'package:flutter_tiktok/base/structure/base_model.dart';

class MainContentDiscoveryModel extends BaseModel{

  NetApi api;

  MainContentDiscoveryModel(this.api);

  Future<List<String>> getRecommendVideo(int type){
    return api.getVideoList(type);
  }


}