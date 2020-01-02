import 'package:flutter/material.dart';

typedef OnContentTabChanged(MainPageContentType currentType);

enum MainPageContentType {
  TYPE_DISCOVERY,
  TYPE_FOLLOW,
  TYPE_CAMERA,
  TYPE_MESSAGE,
  TYPE_MINE
}

class MainPageContentView extends StatefulWidget {

  final OnContentTabChanged _contentTabChangedListener;
  final MainPageContentType contentType;

  MainPageContentView(this._contentTabChangedListener, this.contentType);

  @override
  _MainPageContentViewState createState() => _MainPageContentViewState(contentType);
}

class _MainPageContentViewState extends State<MainPageContentView> with AutomaticKeepAliveClientMixin{

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
  Widget build(BuildContext context) {
    super.build(context);

    loadData(context);

    return SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              child: IndexedStack(
                index: contentType.index,
                children: <Widget>[
                  Container(
                    color: Colors.white,
                    child: Text("发现"),
                  ),
                  Container(
                    color: Colors.white,
                    child: Text("关注"),
                  ),
                  Container(
                    color: Colors.white,
                    child: Text("相机"),
                  ),
                  Container(
                    color: Colors.white,
                    child: Text("消息"),
                  ),
                  Container(
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
        ));
  }

  void loadData(BuildContext context) {
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
                  margin: EdgeInsets.only(left: 10.0),
                  decoration: BoxDecoration(
                      color: Color.fromARGB(255, 250, 45, 108),
                      borderRadius: BorderRadius.circular(9.0))),
              Container(
                  margin: EdgeInsets.only(right: 10.0),
                  decoration: BoxDecoration(
                      color: Color.fromARGB(255, 32, 211, 234),
                      borderRadius: BorderRadius.circular(9.0))),
              Center(
                  child: Container(
                    height: double.infinity,
                    width: 40,
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

  @override
  bool get wantKeepAlive => true;

}
