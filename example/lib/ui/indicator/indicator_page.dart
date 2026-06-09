/*
 * Author: Jpeng
 * Email: peng8350@gmail.com
 * Time: 2019/5/5 下午6:07
 */

import "package:flutter/material.dart";
import "package:pull_to_refresh/pull_to_refresh.dart";

import "base/indicator_activity.dart";

class IndicatorPage extends StatefulWidget {
  const IndicatorPage({super.key, this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String? title;

  @override
  _IndicatorPageState createState() => _IndicatorPageState();
}

class _IndicatorPageState extends State<IndicatorPage> {
  List<Widget> items = <Widget>[];

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.5,
      ),
      itemCount: items.length,
      itemBuilder: (BuildContext context, int index) => items[index],
    );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    items = [
      IndicatorItem(
        title: "经典指示器(跟随)",
        onClick: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (BuildContext context) => const IndicatorActivity(
                title: "经典指示器(跟随)",
                header: ClassicHeader(refreshStyle: RefreshStyle.follow),
              ),
            ),
          );
        },
        imgRes: "images/classical_follow.gif",
      ),
      IndicatorItem(
        title: "经典指示器(不跟随)",
        onClick: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (BuildContext context) => const IndicatorActivity(
                title: "经典指示器(不跟随)",
                header: ClassicHeader(refreshStyle: RefreshStyle.unFollow),
              ),
            ),
          );
        },
        imgRes: "images/classical_unfollow.gif",
      ),
      IndicatorItem(
        title: "QQ头部指示器",
        onClick: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (BuildContext context) => const IndicatorActivity(
                reverse: false,
                title: "QQ头部指示器",
                header: WaterDropHeader(),
              ),
            ),
          );
        },
        imgRes: "images/warterdrop.gif",
      ),
      IndicatorItem(
        title: "经典Material指示器",
        onClick: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (BuildContext context) => const IndicatorActivity(
                title: "官方Material指示器",
                header: MaterialClassicHeader(distance: 40),
              ),
            ),
          );
        },
        imgRes: "images/material_classic.gif",
      ),
      IndicatorItem(
        title: "bezier+circle",
        onClick: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (BuildContext context) => const IndicatorActivity(
                reverse: false,
                title: "bezier+circle",
                header: BezierCircleHeader(
                  dismissType: BezierDismissType.scaleToCenter,
                ),
              ),
            ),
          );
        },
        imgRes: "images/bezier.gif",
      ),
      IndicatorItem(
        title: "水滴坠落Material指示器",
        onClick: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (BuildContext context) => const IndicatorActivity(
                reverse: false,
                title: "水滴坠落Material指示器",
                header: WaterDropMaterialHeader(color: Colors.red),
              ),
            ),
          );
        },
        imgRes: "images/material_waterdrop.gif",
      ),
      IndicatorItem(
        title: "底部指示器(经常显示)",
        onClick: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (BuildContext context) => const IndicatorActivity(
                title: "底部指示器(经常显示)",
                footer: ClassicFooter(
                  height: 80.0,
                  loadStyle: LoadStyle.showAlways,
                ),
              ),
            ),
          );
        },
        imgRes: "images/loadstyle1.gif",
      ),
      IndicatorItem(
        title: "底部指示器(经常隐藏)",
        onClick: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (BuildContext context) =>
                  RefreshConfiguration.copyAncestor(
                    context: context,
                    footerTriggerDistance: -30.0,
                    enableLoadingWhenFailed: true,
                    maxUnderScrollExtent: 100.0,
                    child: const IndicatorActivity(
                      reverse: false,
                      title: "底部指示器(经常隐藏)",
                      footer: ClassicFooter(loadStyle: LoadStyle.hideAlways),
                    ),
                  ),
            ),
          );
        },
        imgRes: "images/loadstyle2.gif",
      ),
      IndicatorItem(
        title: "底部指示器(只有加载中才显示)",
        onClick: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (BuildContext context) =>
                  RefreshConfiguration.copyAncestor(
                    context: context,
                    enableLoadingWhenFailed: true,
                    footerTriggerDistance: -60.0,
                    child: RefreshConfiguration.copyAncestor(
                      context: context,
                      enableLoadingWhenFailed: true,
                      maxUnderScrollExtent: 100.0,
                      footerTriggerDistance: -45.0,
                      child: const IndicatorActivity(
                        reverse: false,
                        title: "底部指示器(只有加载中才显示)",
                        footer: ClassicFooter(
                          loadStyle: LoadStyle.showWhenLoading,
                        ),
                      ),
                    ),
                  ),
            ),
          );
        },
        imgRes: "images/loadstyle3.gif",
      ),
    ];
    super.didChangeDependencies();
  }
}

class IndicatorItem extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _IndicatorItemState();
  }

  final VoidCallback onClick;

  final String imgRes;

  final String title;

  const IndicatorItem({
    required this.title,
    required this.imgRes,
    required this.onClick,
    super.key,
  });
}

class _IndicatorItemState extends State<IndicatorItem> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onClick,
      child: Card(
        child: Column(
          children: <Widget>[
            Center(
              child: Image.asset(
                widget.imgRes,
                fit: BoxFit.cover,
                width: 180.0,
              ),
            ),
            Center(child: Text(widget.title)),
          ],
        ),
      ),
    );
  }
}
