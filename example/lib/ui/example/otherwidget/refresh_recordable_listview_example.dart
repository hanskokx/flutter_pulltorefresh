/*
 * Author: Jpeng
 * Email: peng8350@gmail.com
 * Time:  2019-07-01 22:44
 */

import "package:example/other/refresh_recordable_listview.dart";
import "package:flutter/material.dart";
import "package:pull_to_refresh/pull_to_refresh.dart";

class ReorderableListDemo extends StatefulWidget {
  const ReorderableListDemo({super.key});

  static const String routeName = "/material/reorderable-list";

  @override
  State<ReorderableListDemo> createState() => _ListDemoState();
}

class _ListDemoState extends State<ReorderableListDemo> {
  final RefreshController _refreshController = RefreshController();
  bool _reverse = false;
  bool _reverseSort = false;
  final List<String> _items = <String>[
    "A",
    "B",
    "C",
    "D",
    "E",
    "F",
    "G",
    "H",
    "I",
    "J",
    "K",
    "L",
    "M",
    "N",
  ];

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final String item = _items.removeAt(oldIndex);
      _items.insert(newIndex, item);
    });
  }

  List<Widget> _buildChildren() {
    return _items
        .map(
          (String item) => ListTile(
            key: ValueKey<String>(item),
            title: Text("This item represents $item."),
            subtitle: const Text("Drag to reorder"),
            leading: const Icon(Icons.drag_handle),
          ),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Reorderable list"),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.sort_by_alpha),
            tooltip: "Sort",
            onPressed: () {
              setState(() {
                _reverseSort = !_reverseSort;
                _items.sort(
                  (String a, String b) =>
                      _reverseSort ? b.compareTo(a) : a.compareTo(b),
                );
              });
            },
          ),
          IconButton(
            icon: Icon(_reverse ? Icons.arrow_upward : Icons.arrow_downward),
            tooltip: "Reverse",
            onPressed: () {
              setState(() {
                _reverse = !_reverse;
              });
            },
          ),
        ],
      ),
      body: RefreshReorderableListView(
        header: const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text("Header of the list"),
        ),
        onReorder: _onReorder,
        reverse: _reverse,
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        refreshController: _refreshController,
        children: _buildChildren(),
      ),
    );
  }
}
