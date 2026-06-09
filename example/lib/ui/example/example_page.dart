/*
 * Author: Jpeng
 * Email: peng8350@gmail.com
 * Time:  2019-06-24 17:21
 */
import "package:example/ui/example/customindicator/footer_underscroll.dart";
import "package:example/ui/example/customindicator/link_header_example.dart";
import "package:example/ui/example/customindicator/shimmer_indicator.dart";
import "package:example/ui/example/customindicator/spinkit_header.dart";
import "package:example/ui/example/otherwidget/refesh_expansiopn_panel_list_example.dart";
import "package:example/ui/example/otherwidget/refresh_animatedlist_example.dart";
import "package:example/ui/example/otherwidget/refresh_page_view_example.dart";
import "package:example/ui/example/useStage/basic.dart";
import "package:example/ui/example/useStage/empty_view.dart";
import "package:example/ui/example/useStage/force_full_one_page.dart";
import "package:example/ui/example/useStage/hidefooter_bycontent.dart";
import "package:example/ui/example/useStage/horizontal_reverse.dart";
import "package:example/ui/example/useStage/nested.dart";
import "package:example/ui/example/useStage/twolevel_refresh.dart";
import "package:flutter/material.dart";

import "customindicator/gif_indicator_example1.dart";
import "otherwidget/draggable_bottomsheet_loadmore.dart";
import "otherwidget/refresh_recordable_listview_example.dart";
import "otherwidget/refresh_staggered_and_sticky.dart";
import "useStage/qq_chat_list.dart";
import "useStage/tapbutton_refresh.dart";

class ExamplePage extends StatefulWidget {
  const ExamplePage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _ExamplePageState();
  }
}

class ExampleItem extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ExampleItemState();
  }

  final VoidCallback onClick;

  final String title;

  const ExampleItem({required this.title, required this.onClick, super.key});
}

class _ExampleItemState extends State<ExampleItem> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onClick,
      child: SizedBox(
        height: 100.0,
        child: Card(child: Center(child: Text(widget.title))),
      ),
    );
  }
}

class _ExamplePageState extends State<ExamplePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    _tabController = TabController(initialIndex: 0, length: 3, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final List<ExampleItem> items1 = [
      ExampleItem(
        title: "基础用法",
        onClick: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) {
                return const BasicExample();
              },
            ),
          );
        },
      ),
      ExampleItem(
        title: "手动隐藏footer",
        onClick: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) {
                return Scaffold(body: const HideFooterManual(), appBar: AppBar());
              },
            ),
          );
        },
      ),
      ExampleItem(
        title: "水平刷新",
        onClick: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) {
                return Scaffold(body: const HorizontalRefresh(), appBar: AppBar());
              },
            ),
          );
        },
      ),
      ExampleItem(
        title: "点击按钮触发刷新",
        onClick: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) {
                return const TapButtonRefreshExample();
              },
            ),
          );
        },
      ),
      ExampleItem(
        title: "NestedScrollView下刷新",
        onClick: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) {
                return const NestedRefresh();
              },
            ),
          );
        },
      ),
      ExampleItem(
        title: "模仿qq聊天",
        onClick: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) {
                return const QQChatList();
              },
            ),
          );
        },
      ),
      ExampleItem(
        title: "空白视图+刷新",
        onClick: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) {
                return Scaffold(body: const RefreshWithEmptyView(), appBar: AppBar());
              },
            ),
          );
        },
      ),
      ExampleItem(
        title: "淘宝二楼例子",
        onClick: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) {
                return const TwoLevelExample();
              },
            ),
          );
        },
      ),
      ExampleItem(
        title: "强制填满一屏",
        onClick: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) {
                return Scaffold(body: const ForceFullExample(), appBar: AppBar());
              },
            ),
          );
        },
      ),
    ];
    final List<ExampleItem> items2 = [
      ExampleItem(
        title: "animatedlist结合refresher",
        onClick: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) {
                return Scaffold(body: const AnimatedListExample(), appBar: AppBar());
              },
            ),
          );
        },
      ),
      ExampleItem(
        title: "ExpansionPanelList配合使用",
        onClick: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) {
                return Scaffold(
                  appBar: AppBar(),
                  body: const RefreshExpansionPanelList(),
                );
              },
            ),
          );
        },
      ),
      ExampleItem(
        title: "loadmore+draggablesheet",
        onClick: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) {
                return Scaffold(
                  appBar: AppBar(),
                  body: const DraggableLoadingBottomSheet(),
                );
              },
            ),
          );
        },
      ),
      ExampleItem(
        title: "stickyHeader+StaggeredGridView",
        onClick: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) {
                return Scaffold(
                  appBar: AppBar(),
                  body: const RefreshStaggeredAndSticky(),
                );
              },
            ),
          );
        },
      ),
      ExampleItem(
        title: "pageView共用SmartRefresher",
        onClick: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) {
                return Scaffold(body: const PageViewExample(), appBar: AppBar());
              },
            ),
          );
        },
      ),
      ExampleItem(
        title: "RecordableListView",
        onClick: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) {
                return Scaffold(body: const ReorderableListDemo(), appBar: AppBar());
              },
            ),
          );
        },
      ),
    ];

    final List<ExampleItem> items3 = [
      ExampleItem(
        title: "简单自定义头部指示器",
        onClick: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) {
                return Scaffold(body: const CustomHeaderExample(), appBar: AppBar());
              },
            ),
          );
        },
      ),
      ExampleItem(
        title: "LinkHeader例子",
        onClick: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) {
                return const LinkHeaderExample();
              },
            ),
          );
        },
      ),
      ExampleItem(
        title: "Shimmer指示器例子",
        onClick: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) {
                return Scaffold(
                  appBar: AppBar(),
                  body: const ShimmerIndicatorExample(),
                );
              },
            ),
          );
        },
      ),
      ExampleItem(
        title: "Gif指示器例子1",
        onClick: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) {
                return Scaffold(
                  backgroundColor: Colors.white,
                  appBar: AppBar(),
                  body: const GifIndicatorExample1(),
                );
              },
            ),
          );
        },
      ),
      ExampleItem(
        title: "footer使其于header同样表现",
        onClick: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) {
                return const ConvertFooter();
              },
            ),
          );
        },
      ),
    ];

    return Column(
      children: <Widget>[
        Container(
          height: 50.0,
          color: Colors.greenAccent,
          child: TabBar(
            controller: _tabController,
            tabs: const <Widget>[
              Tab(text: "使用场景"),
              Tab(
                text: "配合特殊组件", //字符串
              ),
              Tab(text: "自定义指示器"),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: <Widget>[
              ListView(children: items1),
              ListView(children: items2),
              ListView(children: items3),
            ],
          ),
        ),
      ],
    );
  }
}
