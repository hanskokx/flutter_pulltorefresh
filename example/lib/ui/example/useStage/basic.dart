/*
 * Author: Jpeng
 * Email: peng8350@gmail.com
 * Time:  2019-06-26 11:36
 */

/*
  the basic usage
*/

import "package:flutter/material.dart";
import "package:flutter_card_swiper/flutter_card_swiper.dart";
import "package:pull_to_refresh/pull_to_refresh.dart";

import "../../item.dart";

/*
   the most common usage,
   child wrap ListView,GridView,CustomView,Widget,
   RefreshConfiguration is a global setting,just  like theme,All refreshers under the RefreshConfiguration subtree will refer to its properties,
   in this example,I gave RefreshConfiguration a property headerBuilder,The default header indicator for the four refreshers is it.
   If you use almost the same page indicator, using Refresh Configuration can greatly reduce the complexity of your work.

*/

class BasicExample extends StatefulWidget {
  const BasicExample({super.key});

  @override
  State<StatefulWidget> createState() {
    return _BasicExampleState();
  }
}

class _BasicExampleState extends State<BasicExample>
    with SingleTickerProviderStateMixin {
  //  int pageIndex = 0;
  List<String> data1 = [], data2 = [], data3 = [];
  late TabController _tabController;

  @override
  void initState() {
    _tabController = TabController(length: 6, vsync: this);
    _tabController.addListener(() {});
    for (int i = 0; i < 10; i++) {
      data1.add("Item $i");
    }
    for (int i = 0; i < 10; i++) {
      data2.add("Item $i");
    }
    for (int i = 0; i < 10; i++) {
      data3.add("Item $i");
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshConfiguration.copyAncestor(
      enableLoadingWhenFailed: true,
      context: context,
      headerBuilder: () => WaterDropMaterialHeader(
        backgroundColor: Theme.of(context).primaryColor,
      ),
      footerTriggerDistance: 30.0,
      child: Scaffold(
        appBar: AppBar(
          bottom: TabBar(
            isScrollable: true,
            controller: _tabController,
            tabs: const <Widget>[
              Tab(text: "ListView"),
              Tab(text: "GridView"),
              Tab(text: "非滚动组件"),
              Tab(text: "SliverAppBar+list"),
              Tab(text: "GridView+ListView"),
              Tab(text: "水平组件+listView"),
            ],
          ),
        ),
        body: TabBarView(
          physics: const NeverScrollableScrollPhysics(),
          controller: _tabController,
          children: const <Widget>[
            Scrollbar(interactive: false, child: OnlyListView()),
            Scrollbar(interactive: false, child: OnlyGridView()),
            Scrollbar(interactive: false, child: NoScrollable()),
            Scrollbar(interactive: false, child: SliverAppBarWithList()),
            Scrollbar(interactive: false, child: GridAndList()),
            Scrollbar(interactive: false, child: SwiperAndList()),
          ],
        ),
      ),
    );
  }
}

//only ListView
class OnlyListView extends StatefulWidget {
  const OnlyListView({super.key});

  @override
  State<StatefulWidget> createState() {
    return _OnlyListViewState();
  }
}

class _OnlyListViewState extends State<OnlyListView> {
  final RefreshController _refreshController = RefreshController(
    initialRefresh: false,
  );
  List<String> data = ["1", "2", "3", "4", "5", "6", "7", "8", "9"];
  final GlobalKey _contentKey = GlobalKey();
  final GlobalKey _refresherKey = GlobalKey();

  Widget buildCtn() {
    return ListView.separated(
      key: _contentKey,
      reverse: true,
      padding: const EdgeInsets.only(left: 5, right: 5),
      itemBuilder: (c, i) => Item(title: data[i]),
      separatorBuilder: (context, index) {
        return Container(height: 0.5, color: Colors.greenAccent);
      },
      itemCount: data.length,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SmartRefresher(
      key: _refresherKey,
      controller: _refreshController,
      enablePullUp: true,
      physics: const BouncingScrollPhysics(),
      footer: const ClassicFooter(
        loadStyle: LoadStyle.showWhenLoading,
        completeDuration: Duration(milliseconds: 500),
      ),
      onRefresh: () async {
        //monitor fetch data from network
        await Future.delayed(const Duration(milliseconds: 1000));

        for (int i = 0; i < 10; i++) {
          data.add("Item $i");
        }

        if (mounted) setState(() {});
        _refreshController.refreshCompleted();

        /*
        if(failed){
         _refreshController.refreshFailed();
        }
      */
      },
      onLoading: () async {
        //monitor fetch data from network
        await Future.delayed(const Duration(milliseconds: 180));
        //        for (int i = 0; i < 10; i++) {
        //          data.add("Item $i");
        //        }
        if (mounted) setState(() {});
        _refreshController.loadFailed();
      },
      child: buildCtn(),
    );
  }
}

//only GridView
class OnlyGridView extends StatefulWidget {
  const OnlyGridView({super.key});

  @override
  State<StatefulWidget> createState() {
    return _OnlyGridViewState();
  }
}

class _OnlyGridViewState extends State<OnlyGridView> {
  final RefreshController _refreshController = RefreshController(
    initialRefresh: false,
  );
  List<String> data = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10"];

  Widget buildCtn() {
    return GridView.builder(
      physics: const ClampingScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
      ),
      itemBuilder: (c, i) => Item(title: data[i]),
      itemCount: data.length,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SmartRefresher(
      controller: _refreshController,
      enablePullUp: true,
      header: const ClassicHeader(),
      onRefresh: () async {
        //monitor fetch data from network
        await Future.delayed(const Duration(milliseconds: 1000));

        if (data.isEmpty) {
          for (int i = 0; i < 10; i++) {
            data.add("Item $i");
          }
        }
        if (mounted) setState(() {});
        _refreshController.refreshCompleted();

        /*
        if(failed){
         _refreshController.refreshFailed();
        }
      */
      },
      onLoading: () async {
        //monitor fetch data from network
        await Future.delayed(const Duration(milliseconds: 1000));
        for (int i = 0; i < 10; i++) {
          data.add("Item $i");
        }
        //    pageIndex++;
        if (mounted) setState(() {});
        _refreshController.loadComplete();
      },
      child: buildCtn(),
    );
  }
}

// No vertical Scrollable (like SingleChildScrollView)
// if child is not extends CustomScrollView,this will add it to SliverToBoxAdapter
// mostly for emptyView
class NoScrollable extends StatefulWidget {
  const NoScrollable({super.key});

  @override
  State<StatefulWidget> createState() {
    return _NoScrollableState();
  }
}

class _NoScrollableState extends State<NoScrollable> {
  final RefreshController _refreshController = RefreshController(
    initialRefresh: false,
  );
  List<String> data = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10"];

  Widget buildCtn() {
    return SizedBox(
      height: 1000.0,
      child: Column(
        children: <Widget>[
          Container(color: Colors.redAccent, height: 200.0),
          const Text("标题"),
          Container(color: Colors.redAccent, height: 200.0),
          const Text("标题"),
          Container(color: Colors.redAccent, height: 200.0),
          const Text("标题"),
          Container(color: Colors.redAccent, height: 200.0),
          const Text("标题"),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SmartRefresher(
      controller: _refreshController,
      enablePullUp: true,
      header: const WaterDropHeader(),
      onRefresh: () async {
        //monitor fetch data from network
        await Future.delayed(const Duration(milliseconds: 1000));

        if (data.isEmpty) {
          for (int i = 0; i < 10; i++) {
            data.add("Item $i");
          }
        }
        if (mounted) setState(() {});
        _refreshController.refreshCompleted();

        /*
        if(failed){
         _refreshController.refreshFailed();
        }
      */
      },
      onLoading: () async {
        //monitor fetch data from network
        await Future.delayed(const Duration(milliseconds: 1000));
        for (int i = 0; i < 10; i++) {
          data.add("Item $i");
        }
        //    pageIndex++;
        if (mounted) setState(() {});
        _refreshController.loadComplete();
      },
      child: buildCtn(),
    );
  }
}

//SliverAppBar + ListView
class SliverAppBarWithList extends StatefulWidget {
  const SliverAppBarWithList({super.key});

  @override
  State<StatefulWidget> createState() {
    return _SliverAppBarWithListState();
  }
}

class _SliverAppBarWithListState extends State<SliverAppBarWithList> {
  final RefreshController _refreshController = RefreshController(
    initialRefresh: false,
  );
  List<String> data = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10"];

  Widget buildCtn() {
    return CustomScrollView(
      slivers: <Widget>[
        const SliverToBoxAdapter(),
        const SliverAppBar(title: Text("SliverAppBar"), expandedHeight: 100.0),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (c, i) => Item(title: data[i]),
            childCount: data.length,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SmartRefresher(
      controller: _refreshController,
      enablePullUp: true,
      header: const WaterDropHeader(),
      onRefresh: () async {
        //monitor fetch data from network
        await Future.delayed(const Duration(milliseconds: 1000));

        if (data.isEmpty) {
          for (int i = 0; i < 10; i++) {
            data.add("Item $i");
          }
        }
        if (mounted) setState(() {});
        _refreshController.refreshCompleted();

        /*
        if(failed){
         _refreshController.refreshFailed();
        }
      */
      },
      onLoading: () async {
        //monitor fetch data from network
        await Future.delayed(const Duration(milliseconds: 1000));
        for (int i = 0; i < 10; i++) {
          data.add("Item $i");
        }
        //    pageIndex++;
        if (mounted) setState(() {});
        _refreshController.loadComplete();
      },
      child: buildCtn(),
    );
  }
}

// GridView + ListView
class GridAndList extends StatefulWidget {
  const GridAndList({super.key});

  @override
  State<StatefulWidget> createState() {
    return _GridAndListState();
  }
}

class _GridAndListState extends State<GridAndList> {
  final RefreshController _refreshController = RefreshController(
    initialRefresh: false,
  );
  List<String> data = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10"];

  Widget buildCtn() {
    return CustomScrollView(
      slivers: <Widget>[
        SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
          ),
          delegate: SliverChildBuilderDelegate(
            (c, i) => const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[Icon(Icons.storage), Text("菜单标题")],
            ),
            childCount: 6,
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (c, i) => Item(title: data[i]),
            childCount: data.length,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SmartRefresher(
      controller: _refreshController,
      enablePullUp: true,
      header: const WaterDropHeader(),
      onRefresh: () async {
        //monitor fetch data from network
        await Future.delayed(const Duration(milliseconds: 1000));

        if (data.isEmpty) {
          for (int i = 0; i < 10; i++) {
            data.add("Item $i");
          }
        }
        if (mounted) setState(() {});
        _refreshController.refreshCompleted();

        /*
        if(failed){
         _refreshController.refreshFailed();
        }
      */
      },
      onLoading: () async {
        //monitor fetch data from network
        await Future.delayed(const Duration(milliseconds: 1000));
        for (int i = 0; i < 10; i++) {
          data.add("Item $i");
        }
        //    pageIndex++;
        if (mounted) setState(() {});
        _refreshController.loadComplete();
      },
      child: buildCtn(),
    );
  }
}

// 水平组件(例子:轮播图)+List
class SwiperAndList extends StatefulWidget {
  const SwiperAndList({super.key});

  @override
  State<StatefulWidget> createState() {
    return _SwiperAndListState();
  }
}

class _SwiperAndListState extends State<SwiperAndList> {
  final RefreshController _refreshController = RefreshController(
    initialRefresh: false,
  );
  List<String> data = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10"];

  Widget buildCtn() {
    return CustomScrollView(
      slivers: <Widget>[
        SliverToBoxAdapter(
          child: SizedBox(
            height: 200,
            child: CardSwiper(
              cardsCount: 10,
              numberOfCardsDisplayed: 3,
              padding: EdgeInsets.zero,
              scale: 0.92,
              cardBuilder:
                  (context, index, percentThresholdX, percentThresholdY) {
                    return Image.asset("images/empty.png", fit: BoxFit.cover);
                  },
            ),
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (c, i) => Item(title: data[i]),
            childCount: data.length,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SmartRefresher(
      controller: _refreshController,
      enablePullUp: true,
      header: const WaterDropHeader(),
      onRefresh: () async {
        //monitor fetch data from network
        await Future.delayed(const Duration(milliseconds: 1000));

        if (data.isEmpty) {
          for (int i = 0; i < 10; i++) {
            data.add("Item $i");
          }
        }
        if (mounted) setState(() {});
        _refreshController.refreshCompleted();

        /*
        if(failed){
         _refreshController.refreshFailed();
        }
      */
      },
      onLoading: () async {
        //monitor fetch data from network
        await Future.delayed(const Duration(milliseconds: 1000));
        for (int i = 0; i < 10; i++) {
          data.add("Item $i");
        }
        //    pageIndex++;
        if (mounted) setState(() {});
        _refreshController.loadComplete();
      },
      child: buildCtn(),
    );
  }
}
