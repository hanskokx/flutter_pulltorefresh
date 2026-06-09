import "package:flutter/material.dart";
import "package:pull_to_refresh/pull_to_refresh.dart";

class AnimatedListExample extends StatefulWidget {
  const AnimatedListExample({super.key});

  @override
  State<AnimatedListExample> createState() => _AnimatedListExampleState();
}

class _AnimatedListExampleState extends State<AnimatedListExample> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  final RefreshController _refreshController = RefreshController();
  final List<int> _items = <int>[0, 1, 2];
  int _nextItem = 3;

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  void _insertAtTop() {
    final int value = _nextItem++;
    _items.insert(0, value);
    _listKey.currentState?.insertItem(
      0,
      duration: const Duration(milliseconds: 250),
    );
  }

  void _removeTop() {
    if (_items.isEmpty) return;
    final int removed = _items.removeAt(0);
    _listKey.currentState?.removeItem(
      0,
      (BuildContext context, Animation<double> animation) =>
          _buildTile(removed, animation),
      duration: const Duration(milliseconds: 250),
    );
  }

  Widget _buildTile(int item, Animation<double> animation) {
    return SizeTransition(
      sizeFactor: animation,
      child: Card(
        color: Colors.primaries[item % Colors.primaries.length],
        child: SizedBox(height: 72, child: Center(child: Text("Item $item"))),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("AnimatedList + Refresher"),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.add_circle),
            onPressed: _insertAtTop,
          ),
          IconButton(
            icon: const Icon(Icons.remove_circle),
            onPressed: _removeTop,
          ),
        ],
      ),
      body: SmartRefresher(
        controller: _refreshController,
        enablePullUp: true,
        onRefresh: () async {
          await Future.delayed(const Duration(milliseconds: 400));
          _insertAtTop();
          _refreshController.refreshCompleted();
        },
        onLoading: () async {
          await Future.delayed(const Duration(milliseconds: 400));
          _items.add(_nextItem++);
          _listKey.currentState?.insertItem(_items.length - 1);
          _refreshController.loadComplete();
        },
        child: AnimatedList(
          key: _listKey,
          initialItemCount: _items.length,
          itemBuilder:
              (BuildContext context, int index, Animation<double> animation) {
                return _buildTile(_items[index], animation);
              },
        ),
      ),
    );
  }
}
