class NetApi{

  Future<List<String>> getVideoList(int type){

    List<String> result=["assets/videos/wodexiaomubiao1.mp4","assets/videos/wodexiaomubiao2.mp4","assets/videos/wodexiaomubiao3.mp4"];

    /// 2秒延迟，模拟网络请求
    return Future.delayed(Duration(seconds: 2),(){
      return result;
    });
  }


}