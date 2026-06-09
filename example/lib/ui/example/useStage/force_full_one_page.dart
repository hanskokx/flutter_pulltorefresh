/*
 * Author: Jpeng
 * Email: peng8350@gmail.com
 * Time:  2019-10-17 20:30
 */

import "package:flutter/material.dart";
import "package:pull_to_refresh/pull_to_refresh.dart";

/// This example demonstrates a one-page list that can still show footer states.
class ForceFullExample extends StatefulWidget {
  const ForceFullExample({super.key});

  @override
  State<ForceFullExample> createState() => _ForceFullExampleState();
}

class _ForceFullExampleState extends State<ForceFullExample> {
  final RefreshController _refreshController = RefreshController();

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SmartRefresher(
      controller: _refreshController,
      enablePullUp: true,
      onRefresh: () async {
        await Future.delayed(const Duration(milliseconds: 500));
        _refreshController.refreshCompleted();
      },
      onLoading: () async {
        await Future.delayed(const Duration(milliseconds: 500));
        _refreshController.loadComplete();
      },
      footer: const ClassicFooter(loadStyle: LoadStyle.showWhenLoading),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          Text("有很多时候,不满一屏时,会出现很多问题。这个示例展示了在内容较少时，依然保持可下拉刷新和上拉加载状态展示。"),
          SizedBox(height: 24),
          Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text("内容未满一屏时也可观察底部加载效果。"),
            ),
          ),
        ],
      ),
    );
  }
}
