import "package:flutter/material.dart" hide RefreshIndicator;
import "package:pull_to_refresh/pull_to_refresh.dart";

typedef ReorderCallback = void Function(int oldIndex, int newIndex);

class RefreshReorderableListView extends StatefulWidget {
  RefreshReorderableListView({
    required this.children, required this.onReorder, required this.refreshController, super.key,
    this.header,
    this.scrollDirection = Axis.vertical,
    this.padding,
    this.reverse = false,
    this.refreshHeader,
    this.refreshFooter,
    this.enablePullDown = true,
    this.enablePullUp = false,
    this.onRefresh,
    this.onLoading,
  }) : assert(
         children.isEmpty || children.every((Widget w) => w.key != null),
         "All children of this widget must have a key.",
       );

  final RefreshIndicator? refreshHeader;
  final LoadIndicator? refreshFooter;
  final bool enablePullUp;
  final bool enablePullDown;
  final VoidCallback? onRefresh;
  final VoidCallback? onLoading;
  final RefreshController refreshController;
  final Widget? header;
  final List<Widget> children;
  final Axis scrollDirection;
  final EdgeInsets? padding;
  final bool reverse;
  final ReorderCallback onReorder;

  @override
  State<RefreshReorderableListView> createState() =>
      _RefreshReorderableListViewState();
}

class _RefreshReorderableListViewState
    extends State<RefreshReorderableListView> {
  @override
  Widget build(BuildContext context) {
    final List<Widget> items = <Widget>[];
    if (widget.header != null) {
      items.add(
        KeyedSubtree(
          key: const ValueKey<String>("refresh-reorderable-header"),
          child: widget.header!,
        ),
      );
    }
    items.addAll(widget.children);

    return SmartRefresher(
      controller: widget.refreshController,
      enablePullDown: widget.enablePullDown,
      enablePullUp: widget.enablePullUp,
      header: widget.refreshHeader,
      footer: widget.refreshFooter,
      onRefresh: widget.onRefresh,
      onLoading: widget.onLoading,
      child: ReorderableListView(
        reverse: widget.reverse,
        scrollDirection: widget.scrollDirection,
        padding: widget.padding,
        onReorderItem: (int oldIndex, int newIndex) {
          final int headerOffset = widget.header == null ? 0 : 1;

          // Keep the optional header fixed and map list indices back to children.
          if (headerOffset == 1) {
            if (oldIndex == 0 || newIndex == 0) {
              return;
            }
            widget.onReorder(oldIndex - 1, newIndex - 1);
            return;
          }
          widget.onReorder(oldIndex, newIndex);
        },
        children: items,
      ),
    );
  }
}
