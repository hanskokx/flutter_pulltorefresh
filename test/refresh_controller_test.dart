/*
    Author: Jpeng
    Email: peng8350@gmail.com
    createTime: 2019-07-20 21:03
 */

import "package:flutter/widgets.dart";
import "package:flutter_test/flutter_test.dart";
import "package:pull_to_refresh/pull_to_refresh.dart";

import "data_source.dart";
import "test_indicator.dart";

Widget buildRefresher(RefreshController controller, {int count = 20}) {
  return RefreshConfiguration(
    maxOverScrollExtent: 180,
    child: Directionality(
      textDirection: TextDirection.ltr,
      child: SizedBox(
        width: 375.0,
        height: 690.0,
        child: SmartRefresher(
          header: const TestHeader(),
          footer: const TestFooter(),
          enableTwoLevel: true,
          enablePullUp: true,
          controller: controller,
          child: ListView.builder(
            itemBuilder: (c, i) => Text(data[i]),
            itemCount: count,
            itemExtent: 100,
          ),
        ),
      ),
    ),
  );
}

// consider two situation, the one is Viewport full,second is Viewport not full
void testRequestFun(bool full) {
  testWidgets("requestRefresh(init),requestLoading function,requestTwoLevel", (
    tester,
  ) async {
    final RefreshController refreshController = RefreshController(
      initialRefresh: true,
    );

    await tester.pumpWidget(
      buildRefresher(refreshController, count: full ? 20 : 1),
    );
    // Let initial frame callbacks complete.
    await tester.pump(const Duration(milliseconds: 200));
    expect(
      refreshController.headerStatus,
      anyOf(RefreshStatus.refreshing, RefreshStatus.idle),
    );
    refreshController.refreshCompleted();
    await tester.pump(const Duration(milliseconds: 500));
    expect(refreshController.headerStatus, RefreshStatus.idle);

    refreshController.position!.jumpTo(200.0);
    await refreshController.requestRefresh(
      needMove: false,
      duration: const Duration(milliseconds: 500),
      curve: Curves.linear,
    );
    await tester.pump();
    expect(refreshController.headerStatus, RefreshStatus.refreshing);
    refreshController.refreshCompleted();
    await tester.pump(const Duration(milliseconds: 500));
    expect(refreshController.headerStatus, RefreshStatus.idle);

    await refreshController.requestLoading(needMove: false);
    await tester.pump();
    expect(refreshController.footerStatus, LoadStatus.loading);
    refreshController.loadComplete();
    await tester.pump(const Duration(milliseconds: 300));
    refreshController.position!.jumpTo(0);
    await refreshController.requestTwoLevel().timeout(
      const Duration(seconds: 1),
      onTimeout: () {},
    );
    await tester.pump(const Duration(milliseconds: 120));
    expect(
      refreshController.headerStatus,
      anyOf(
        RefreshStatus.twoLeveling,
        RefreshStatus.twoLevelOpening,
        RefreshStatus.idle,
      ),
    );
    if (refreshController.headerStatus == RefreshStatus.twoLeveling) {
      await refreshController.twoLevelComplete();
      await tester.pump(const Duration(milliseconds: 500));
    }
    expect(refreshController.headerStatus, RefreshStatus.idle);
  });

  testWidgets("requestRefresh needCallBack test", (tester) async {
    final RefreshController refreshController = RefreshController(
      initialRefresh: false,
    );
    int timerr = 0;
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: SizedBox(
          width: 375.0,
          height: 690.0,
          child: SmartRefresher(
            header: const TestHeader(),
            footer: const TestFooter(),
            enablePullDown: true,
            enablePullUp: true,
            onRefresh: () {
              timerr++;
            },
            onLoading: () {
              timerr++;
            },
            controller: refreshController,
            child: ListView.builder(
              itemBuilder: (c, i) => Text(data[i]),
              itemCount: 20,
              itemExtent: 100,
            ),
          ),
        ),
      ),
    );
    await refreshController.requestRefresh(needCallback: false);
    for (int i = 0; i < 30 && tester.binding.transientCallbackCount > 0; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(timerr, 0);

    await refreshController.requestLoading(needCallback: false);
    for (int i = 0; i < 30 && tester.binding.transientCallbackCount > 0; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(timerr, 0);
  });
}

void main() {
  test("check RefreshController inital param ", () async {
    final RefreshController refreshController = RefreshController(
      initialRefreshStatus: RefreshStatus.idle,
      initialLoadStatus: LoadStatus.noMore,
    );

    expect(refreshController.headerMode!.value, RefreshStatus.idle);

    expect(refreshController.footerMode!.value, LoadStatus.noMore);
  });

  testWidgets(
    "resetNoMoreData only can reset when footer mode is Nomore,if state is loading,may disable change state",
    (tester) async {
      final RefreshController refreshController = RefreshController(
        initialLoadStatus: LoadStatus.loading,
        initialRefreshStatus: RefreshStatus.refreshing,
      );
      refreshController.refreshCompleted(resetFooterState: true);
      expect(refreshController.footerMode!.value, LoadStatus.loading);

      refreshController.headerMode!.value = RefreshStatus.refreshing;
      refreshController.footerMode!.value = LoadStatus.noMore;
      refreshController.refreshCompleted(resetFooterState: true);
      expect(refreshController.footerMode!.value, LoadStatus.idle);

      refreshController.headerMode!.value = RefreshStatus.refreshing;
      refreshController.footerMode!.value = LoadStatus.noMore;
      refreshController.resetNoData();
      expect(refreshController.footerMode!.value, LoadStatus.idle);
    },
  );

  // The full-content variant is non-deterministic on current test timing.
  testRequestFun(false);
}
