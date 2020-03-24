import 'package:flutter/material.dart';
import 'package:flutter_tiktok/base/util/utils_toast.dart';

class MainContentCommentBottomSheetWidget extends StatefulWidget {
  @override
  _MainContentCommentBottomSheetWidgetState createState() =>
      _MainContentCommentBottomSheetWidgetState();
}

class _MainContentCommentBottomSheetWidgetState
    extends State<MainContentCommentBottomSheetWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 400,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          /// title 头部标题
          Container(
            height: 50,
            child: Stack(
              children: <Widget>[
                Align(
                  alignment: Alignment.center,
                  child: Text("666评论"),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: CloseButton(),
                )
              ],
            ),
          ),

          /// content 内容
          Expanded(
            child: _MainContentCommentBottomSheetContent(),
            flex: 1,
          ),

          /// inputArea 输入区
          _MainContentCommentBottomSheetInputArea(false, null, null),
        ],
      ),
    );
  }
}

class _MainContentCommentBottomSheetContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: ListView.builder(
        itemBuilder: (context, index) {
          return Text("test");
        },
        itemCount: 16,
      ),
    );
  }
}

typedef OnValueChanged<String> = void Function(String value);

class _MainContentCommentBottomSheetInputArea extends StatefulWidget {
  final bool isTextEditEnable;
  final String text;
  final OnValueChanged textChangedListener;

  _MainContentCommentBottomSheetInputArea(
      this.isTextEditEnable, this.textChangedListener, this.text);

  @override
  State<_MainContentCommentBottomSheetInputArea> createState() {
    return __MainContentCommentBottomSheetInputAreaState();
  }
}

class __MainContentCommentBottomSheetInputAreaState
    extends State<_MainContentCommentBottomSheetInputArea> {
  bool isTextEditEnable;
  OnValueChanged textChangedListener;

  String currentText = "";

  @override
  void initState() {
    super.initState();
    this.isTextEditEnable = widget.isTextEditEnable;
    this.textChangedListener = widget.textChangedListener;
    this.currentText = widget.text;
  }

  @override
  void didUpdateWidget(_MainContentCommentBottomSheetInputArea oldWidget) {
    super.didUpdateWidget(oldWidget);
    this.currentText = widget.text;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: <Widget>[
//          ListView(
//            shrinkWrap: true,
//            scrollDirection: Axis.horizontal,
//          ),
          Container(
            height: 50,
            color: Colors.red,
          ),
          Row(
            children: <Widget>[
              CircleAvatar(
                child: Image.asset(
                  "imgs/avatar/avatar.png",
                  width: 40,
                  height: 40,
                ),
              ),
              Expanded(
                child: TextField(
                  controller: TextEditingController.fromValue(TextEditingValue(
                      text: currentText??"",
                      selection: TextSelection.fromPosition(TextPosition(
                          affinity: TextAffinity.downstream,
                          offset: currentText?.length??0)))),
                  autofocus: isTextEditEnable,
                  readOnly: !isTextEditEnable,
                  onTap: isTextEditEnable
                      ? null
                      : () {
                          Navigator.push(
                              context,
                              PageRouteBuilder(
                                  opaque: false,
                                  pageBuilder:
                                      (context, animation, secondaryAnimation) {
                                    return _MainContentCommentBottomSheetInputActivity(
                                        this.currentText, (text) {
                                      setState(() {
                                        currentText = text;
                                      });
                                    });
                                  }));
                        },
                  onChanged: (data) {
                    if (textChangedListener != null) {
                      textChangedListener(data);
                    }
                  },
                  decoration: InputDecoration(
                    border: InputBorder.none,
                  ),
                ),
                flex: 1,
              ),
              IconButton(
                  icon: Icon(Icons.track_changes),
                  onPressed: () {
                    ToastUtils.showToast("假装这里可以@某个人");
                  }),
              IconButton(
                  icon: Icon(Icons.insert_emoticon),
                  onPressed: () {
                    ToastUtils.showToast("弹出表情看");
                  }),
            ],
          )
        ],
      ),
    );
  }
}

class _MainContentCommentBottomSheetInputActivity extends StatefulWidget {
  final String currentText;
  final OnValueChanged changeCallback;

  _MainContentCommentBottomSheetInputActivity(
      this.currentText, this.changeCallback);

  @override
  __MainContentCommentBottomSheetInputActivityState createState() =>
      __MainContentCommentBottomSheetInputActivityState();
}

class __MainContentCommentBottomSheetInputActivityState
    extends State<_MainContentCommentBottomSheetInputActivity> {
  MediaQueryData mediaQueryData;
  bool isInit = false;

  String inputText = "";

  @override
  void initState() {
    super.initState();

    inputText = widget?.currentText;
  }

  @override
  Widget build(BuildContext context) {
    mediaQueryData = MediaQuery.of(context);
    if (isInit && mediaQueryData?.viewInsets?.bottom == 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pop(context, inputText);
      });
    }

    isInit = true;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GestureDetector(
        onTap: () {
          isInit = false;
          Navigator.pop(context, inputText);
        },
        child: Container(
          color: Colors.transparent,
          child: Column(children: <Widget>[
            Spacer(
              flex: 1,
            ),
            _MainContentCommentBottomSheetInputArea(true, (text) {
              inputText = text;
              widget?.changeCallback(inputText);
            }, inputText),
          ]),
        ),
      ),
    );
  }

  @override
  void dispose() {
    isInit = false;
    super.dispose();
  }
}
