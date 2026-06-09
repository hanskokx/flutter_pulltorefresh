/*
 * Author: Jpeng
 * Email: peng8350@gmail.com
 * Time: 2019/5/3 下午6:13
 */

import "package:flutter/material.dart";

import "example/example_page.dart";
import "indicator/indicator_page.dart";
import "test/test_page.dart";

class MainActivity extends StatefulWidget {
  final String? title;

  const MainActivity({super.key, this.title});

  @override
  State<StatefulWidget> createState() {
    return _MainActivityState();
  }
}

class _MainActivityState extends State<MainActivity>
    with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late List<Widget> views;
  late TabController _tabController;
  int _tabIndex = 1;
  late PageController _pageController;

  Widget buildItem(String msg, Widget icon, VoidCallback onTap) {
    return ListTile(
      leading: icon,
      title: Text(msg),
      trailing: const Icon(Icons.arrow_forward, color: Colors.grey),
      onTap: onTap,
      iconColor: Colors.grey,
      textColor: Colors.white,
    );
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _pageController = PageController(initialPage: 1);
    views = [
      const IndicatorPage(title: "指示器界面"),
      const ExamplePage(),
      const TestPage(title: "测试界面"),
    ];
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(
          _tabIndex == 0
              ? "指示器界面"
              : _tabIndex == 1
              ? "例子界面"
              : _tabIndex == 2
              ? "测试界面"
              : _tabIndex == 3
              ? "样例界面"
              : "App界面",
        ),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
        backgroundColor: Colors.greenAccent,
        bottom: _tabIndex == 3
            ? TabBar(
                isScrollable: true,
                tabs: const [
                  Tab(child: Text("超大数据量性能测试")),
                  Tab(child: Text("SliverAppbar+Sliverheader")),
                  Tab(child: Text("嵌套滚动视图")),
                  Tab(child: Text("动态变化指示器+Navigator")),
                  Tab(child: Text("主动刷新")),
                  Tab(child: Text("四个方向不同风格测试绘制")),
                ],
                controller: _tabController,
              )
            : null,
      ),
      drawer: Drawer(
        backgroundColor: Colors.purple,
        child: SafeArea(
          child: Column(
            children: <Widget>[
              ConstrainedBox(
                constraints: const BoxConstraints(
                  maxHeight: 80.0,
                  maxWidth: 80.0,
                ),
                child: const CircleAvatar(
                  backgroundImage: NetworkImage(
                    "https://avatars1.githubusercontent.com/u/19425362?s=400&u=1a30f9fdf71cc9a51e20729b2fa1410c710d0f2f&v=4",
                  ),
                  radius: 40.0,
                ),
              ),
              const SizedBox(height: 12),
              buildItem("各种指示器", const Icon(Icons.apps, size: 18), () {
                setState(() {
                  _tabIndex = 0;
                });
                _pageController.jumpToPage(0);
                Navigator.of(context).pop();
              }),
              buildItem("例子", const Icon(Icons.insert_emoticon, size: 18), () {
                setState(() {
                  _tabIndex = 1;
                });
                _pageController.jumpToPage(1);
                Navigator.of(context).pop();
              }),
              buildItem(
                "测试",
                const Icon(Icons.airplanemode_active, size: 18),
                () {
                  setState(() {
                    _tabIndex = 2;
                  });
                  _pageController.jumpToPage(2);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        ),
      ),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: views,
      ),
    );
  }
}
