/*
 * Author: Jpeng
 * Email: peng8350@gmail.com
 * Time:  2019-07-08 10:51
 */
import "package:flutter/material.dart"
    hide RefreshIndicator, RefreshIndicatorState;
import "package:pull_to_refresh/pull_to_refresh.dart";
import "package:skeletonizer/skeletonizer.dart";
/*
   use to implements indicaotr
   https://github.com/hnvn/flutter_shimmer
   how to use?
   in ui/example/customindicator/shimmer_indicaotr.dart,
   it will show you how to use
 */

class ShimmerHeader extends RefreshIndicator {
  final Color baseColor;
  final Color highlightColor;
  final Widget text;
  final Duration period;
  final Widget Function(Widget)? outerBuilder;

  const ShimmerHeader({
    required this.text,
    super.key,
    this.baseColor = Colors.grey,
    this.highlightColor = Colors.white,
    this.outerBuilder,
    super.height = 80.0,
    this.period = const Duration(milliseconds: 1000),
  }) : super(refreshStyle: RefreshStyle.behind);

  @override
  State<StatefulWidget> createState() {
    return _ShimmerHeaderState();
  }
}

class _ShimmerHeaderState extends RefreshIndicatorState<ShimmerHeader>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _fadeController;

  @override
  void initState() {
    _scaleController = AnimationController(vsync: this);
    _fadeController = AnimationController(vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  void onOffsetChange(double offset) {
    if (!floating) {
      _scaleController.value = offset / configuration!.headerTriggerDistance;
      _fadeController.value = offset / configuration!.footerTriggerDistance;
    }
  }

  @override
  Widget buildContent(BuildContext context, RefreshStatus mode) {
    final Widget body = ScaleTransition(
      scale: _scaleController,
      child: FadeTransition(
        opacity: _fadeController,
        child: Skeletonizer(
          enabled: mode == RefreshStatus.refreshing,
          effect: ShimmerEffect(
            baseColor: widget.baseColor,
            highlightColor: widget.highlightColor,
            duration: widget.period,
          ),
          child: Center(child: widget.text),
        ),
      ),
    );
    return (widget.outerBuilder ??
        (Widget child) => Container(
          alignment: Alignment.center,
          decoration: const BoxDecoration(color: Colors.black12),
          child: child,
        ))(body);
  }
}

class ShimmerFooter extends LoadIndicator {
  final Color baseColor;
  final Color highlightColor;
  final Widget text;
  final Widget? failed;
  final Widget? noMore;
  final Duration period;
  final Widget Function(Widget)? outerBuilder;

  const ShimmerFooter({
    required this.text,
    super.key,
    this.baseColor = Colors.grey,
    this.highlightColor = Colors.white,
    this.outerBuilder,
    super.height = 80.0,
    this.failed,
    this.noMore,
    this.period = const Duration(milliseconds: 1000),
    super.loadStyle,
  });

  @override
  State<StatefulWidget> createState() {
    return _ShimmerFooterState();
  }
}

class _ShimmerFooterState extends LoadIndicatorState<ShimmerFooter> {
  @override
  Widget buildContent(BuildContext context, LoadStatus mode) {
    final Widget body = mode == LoadStatus.failed
        ? (widget.failed ?? Center(child: widget.text))
        : mode == LoadStatus.noMore
        ? (widget.noMore ?? Center(child: widget.text))
        : mode == LoadStatus.idle
        ? Center(child: widget.text)
        : Skeletonizer(
            enabled: true,
            effect: ShimmerEffect(
              baseColor: widget.baseColor,
              highlightColor: widget.highlightColor,
              duration: widget.period,
            ),
            child: Center(child: widget.text),
          );
    return (widget.outerBuilder ??
        (Widget child) => Container(
          height: widget.height,
          decoration: const BoxDecoration(color: Colors.black12),
          child: child,
        ))(body);
  }
}
