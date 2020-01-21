class NetApi{

  Future<List<String>> getVideoList(int type){

    List<String> result=["assets/videos/wodexiaomubiao1.mp4","assets/videos/wodexiaomubiao1.mp4","assets/videos/wodexiaomubiao1.mp4"];

    return Future.delayed(Duration(seconds: 2),(){
      return result;
    });
  }


}