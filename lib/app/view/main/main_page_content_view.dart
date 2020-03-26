import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_tiktok/base/structure/base_view.dart';
import 'package:flutter_tiktok/base/structure/base_view_model.dart';

import 'content/main_content_discovery_page.dart';

typedef OnContentTabChanged(MainPageContentType currentType);

enum MainPageContentType {
  TYPE_DISCOVERY,
  TYPE_FOLLOW,
  TYPE_CAMERA,
  TYPE_MESSAGE,
  TYPE_MINE
}

class MainPageContentView extends BaseStatefulView {
  final OnContentTabChanged _contentTabChangedListener;
  final MainPageContentType contentType;

  MainPageContentView(this._contentTabChangedListener, this.contentType);

  @override
  _MainPageContentViewState createState() =>
      _MainPageContentViewState(contentType);

  @override
  BaseStatefulViewState<BaseStatefulView<BaseViewModel>, BaseViewModel>
      buildState() {
    return _MainPageContentViewState(contentType);
  }
}

class _MainPageContentViewState
    extends BaseStatefulViewState<MainPageContentView, BaseViewModel> {
  final List<MainPageContentType> _tabType = [
    MainPageContentType.TYPE_DISCOVERY,
    MainPageContentType.TYPE_FOLLOW,
    MainPageContentType.TYPE_CAMERA,
    MainPageContentType.TYPE_MESSAGE,
    MainPageContentType.TYPE_MINE
  ];

  List<Widget> _tabWidgets = [];

  MainPageContentType contentType;

  _MainPageContentViewState(this.contentType);

  @override
  Widget buildView(BuildContext context, BaseViewModel viewModel) {
    return Column(
      children: <Widget>[
        Expanded(
          child: IndexedStack(
            index: contentType.index,
            children: <Widget>[
              MainContentDiscoveryPage(),
              Container(
                alignment: Alignment.center,
                color: Colors.white,
                child: StaggeredGridView.countBuilder(
                  primary: false,/// 被这块坑了……注意一下，滑动页面，如果没有特殊要求，把这玩意关了
                  crossAxisCount: 4,
                  itemCount: 28,
                  itemBuilder: (BuildContext context, int index) =>
                      new Container(
                          color: Colors.green,
                          child: new Center(
                            child: new CircleAvatar(
                              backgroundColor: Colors.white,
                              child: new Text('$index'),
                            ),
                          )),
                  staggeredTileBuilder: (int index) =>
                      StaggeredTile.count(2, index.isEven ? 2 : 1),
                  mainAxisSpacing: 4.0,
                  crossAxisSpacing: 4.0,
                ),
              ),
              Container(
                alignment: Alignment.center,
                color: Colors.white,
                child: Text("同城"),
              ),
              Container(
                alignment: Alignment.center,
                color: Colors.white,
                child: Text("相机"),
              ),
              Container(
                alignment: Alignment.center,
                color: Colors.white,
                child: Text("消息"),
              ),
              Container(
                alignment: Alignment.center,
                color: Colors.white,
                child: Text("我的"),
              )
            ],
          ),
        ),
        Container(
          color: Color(0xff0E0F1A),
          width: double.infinity,
          child: Row(
            children: _tabWidgets,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
          ),
        )
      ],
    );
  }

  @override
  BaseViewModel buildViewModel(BuildContext context) {
    return null;
  }

  @override
  void initData() {}

  @override
  void loadData(BuildContext context, BaseViewModel viewModel) {
    _tabWidgets.clear();

    _tabWidgets.addAll(_tabType.map((type) => Container(
          padding: EdgeInsets.only(top: 5, bottom: 5),
          child: InkWell(
            child: Builder(builder: (context) {
              String tabTitle;

              switch (type) {
                case MainPageContentType.TYPE_DISCOVERY:
                  tabTitle = "首页";
                  break;
                case MainPageContentType.TYPE_FOLLOW:
                  tabTitle = "关注";
                  break;
                case MainPageContentType.TYPE_MESSAGE:
                  tabTitle = "消息";
                  break;
                case MainPageContentType.TYPE_MINE:
                  tabTitle = "我的";
                  break;
                default:
                  break;
              }

              return tabTitle != null
                  ? Padding(
                      padding: EdgeInsets.all(10),
                      child: Text(
                        tabTitle,
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: contentType == type
                                ? Colors.white
                                : Colors.grey),
                      ),
                    )
                  : Container(
                      width: 45,
                      height: 30,
                      child: Stack(children: [
                        Container(
                            margin: EdgeInsets.only(left: 3.0),
                            decoration: BoxDecoration(
                                color: Color.fromARGB(255, 250, 45, 108),
                                borderRadius: BorderRadius.circular(9.0))),
                        Container(
                            margin: EdgeInsets.only(right: 3.0),
                            decoration: BoxDecoration(
                                color: Color.fromARGB(255, 32, 211, 234),
                                borderRadius: BorderRadius.circular(9.0))),
                        Center(
                            child: Container(
                          height: double.infinity,
                          width: double.infinity,
                          margin: EdgeInsets.only(left: 3, right: 3),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(9.0)),
                          child: Icon(
                            Icons.add,
                            size: 25.0,
                          ),
                        )),
                      ]),
                    );
            }),
            onTap: () {
              setState(() {
                contentType = type;
                widget._contentTabChangedListener(type);
              });
            },
          ),
        )));
  }
}
