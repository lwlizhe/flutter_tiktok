import 'package:flutter/material.dart';
import 'package:flutter_tiktok/app/viewmodel/user_info_view_model.dart';
import 'package:flutter_tiktok/base/structure/base_view.dart';
import 'package:flutter_tiktok/base/util/utils_toast.dart';
import 'package:flutter_tiktok/widget/primary_tab_view.dart';
import 'package:provider/provider.dart';

class MainPageLeftMenuUserDetailPage
    extends BaseStatelessView<UserInfoViewModel> {
  @override
  Widget buildView(BuildContext context, UserInfoViewModel viewModel) {
    return LayoutBuilder(
      builder: (context, boxConstrain) {
        return Stack(
          children: <Widget>[
            Container(
              width: boxConstrain.maxWidth,
              height: boxConstrain.maxHeight,
              color: Colors.black,
              child: _MainPageLeftMenuUserDetailPageContent(),
            ),
            SafeArea(
                child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                IconButton(
                    icon: Icon(
                      Icons.arrow_back,
                      color: Colors.grey[600],
                      size: 28,
                    ),
                    onPressed: () {
                      ToastUtils.showToast("返回中间");
                    }),
                IconButton(
                    icon: Icon(
                      Icons.menu,
                      color: Colors.grey[600],
                      size: 28,
                    ),
                    onPressed: () {
                      ToastUtils.showToast("打开底部菜单");
                    }),
              ],
            )),
          ],
        );
      },
    );
  }

  @override
  UserInfoViewModel buildViewModel(BuildContext context) {
    return UserInfoViewModel(Provider.of(context));
  }

  @override
  void loadData(BuildContext context, UserInfoViewModel viewModel) {}
}

class _MainPageLeftMenuUserDetailPageContent extends StatefulWidget {
  @override
  __MainPageLeftMenuUserDetailPageContentState createState() =>
      __MainPageLeftMenuUserDetailPageContentState();
}

class __MainPageLeftMenuUserDetailPageContentState
    extends State<_MainPageLeftMenuUserDetailPageContent> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        /// 头部背景
        Image(
          image: AssetImage("imgs/avatar/avatar.png"),
          width: double.infinity,
          height: 130,
          fit: BoxFit.fill,
        ),

        /// 主体
        Container(
          child: Padding(
            padding: EdgeInsets.only(top: 115, left: 20, right: 20, bottom: 0),
            child: Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  /// -------------------中间头像和关注按钮---------------------
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Container(
                        width: 100,
                        height: 100,
                        child: CircleAvatar(
                          backgroundImage: AssetImage("imgs/avatar/avatar.png"),
                        ),
                      ),
                      RawMaterialButton(
                        fillColor: Colors.pink,
                        onPressed: () {
                          ToastUtils.showToast("关注");
                        },
                        child: Container(
                          alignment: Alignment.center,
                          width: 200,
                          height: 40,
                          child: Text(
                            "+关注",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      )
                    ],
                  ),

                  /// ----------------------个人信息----------------------------
                  Padding(
                    padding: EdgeInsets.only(top: 10),
                    child: Text(
                      "lwlizhe",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  Text(
                    "抖音号：31415926",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  Text(
                    "官方认证：蝉联10届花式摸鱼偷懒大赛冠军",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 8, bottom: 8),
                    child: Divider(
                      height: 1,
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    "蝉联10届花式摸鱼偷懒大赛冠军\n曾任睡觉国家队主教练\n论偷懒，我是认真且专业的\n \n顺便加一点私货：异度入侵无敌，洞哥nb",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 10),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          "0",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 5),
                          child: Text(
                            "获赞",
                            style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 15),
                          child: Text(
                            "0",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 5),
                          child: Text(
                            "关注",
                            style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 15),
                          child: Text(
                            "0",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 5),
                          child: Text(
                            "粉丝",
                            style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),

                  /// -----------------------相关作品---------------------------
                  Expanded(
                    child: _MainPageLeftMenuUserDetailPageWorksContent(),
                    flex: 1,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _MainPageLeftMenuUserDetailPageWorksContent extends StatefulWidget {
  @override
  __MainPageLeftMenuUserDetailPageWorksContentState createState() =>
      __MainPageLeftMenuUserDetailPageWorksContentState();
}

class __MainPageLeftMenuUserDetailPageWorksContentState
    extends State<_MainPageLeftMenuUserDetailPageWorksContent>
    with SingleTickerProviderStateMixin {
  List<Tab> tabs;
  TabController _primaryTC;

  @override
  void initState() {
    super.initState();
    tabs = [
      Tab(
        text: "作品",
      ),
      Tab(
        text: "动态",
      ),
      Tab(
        text: "喜欢",
      )
    ];
    _primaryTC = TabController(length: tabs.length, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          TabBar(
            tabs: tabs,
            labelColor: Colors.white,
            labelStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            unselectedLabelColor: Colors.grey[400],
            unselectedLabelStyle:
                TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            controller: _primaryTC,
            indicatorColor: Colors.white,
            indicatorSize: TabBarIndicatorSize.label,
            indicatorPadding: EdgeInsets.only(left: 5, right: 5),
            isScrollable: false,
          ),
          Expanded(
            flex: 1,
            child: PrimaryTabBarView(
                controller: _primaryTC,
                children: tabs
                    .map((tab) => GridView.builder(
                          primary: false,
                          padding: EdgeInsets.zero,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                          ),
                          itemBuilder: (context, index) {
                            return Image.asset("imgs/avatar/avatar.png");
                            },
                          itemCount: 10,
                        ))
                    .toList()),
          )
        ],
      ),
    );
  }
}
