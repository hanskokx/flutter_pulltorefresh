/*
 * Author: Jpeng
 * Email: peng8350@gmail.com
 * Time:  2019-07-26 18:22
 */

import "package:flutter/material.dart"
    hide RefreshIndicator, RefreshIndicatorState;
import "package:pull_to_refresh/pull_to_refresh.dart";

/*
  Use an animated GIF asset with a Flutter animation controller for simple
  visual effects without a dedicated gif controller package.
*/
class GifHeader1 extends RefreshIndicator {
  const GifHeader1({super.key})
    : super(height: 80.0, refreshStyle: RefreshStyle.follow);
  @override
  State<StatefulWidget> createState() {
    return GifHeader1State();
  }
}

class GifHeader1State extends RefreshIndicatorState<GifHeader1>
    with SingleTickerProviderStateMixin {
  late AnimationController _gifController;
  late Animation<double> _opacity;

  @override
  void initState() {
    _gifController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
      value: 0.2,
    );
    _opacity = CurvedAnimation(parent: _gifController, curve: Curves.linear);
    super.initState();
  }

  @override
  void onModeChange(RefreshStatus? mode) {
    if (mode == RefreshStatus.refreshing) {
      _gifController.repeat(reverse: true);
    }
    super.onModeChange(mode);
  }

  @override
  Future<void> endRefresh() {
    _gifController.value = 1.0;
    return _gifController.animateTo(
      0.2,
      duration: const Duration(milliseconds: 500),
    );
  }

  @override
  void resetValue() {
    _gifController.value = 0.2;
    super.resetValue();
  }

  @override
  Widget buildContent(BuildContext context, RefreshStatus mode) {
    return FadeTransition(
      opacity: _opacity,
      child: Image.asset(
        "images/gifindicator1.gif",
        height: 80.0,
        width: 537.0,
        fit: BoxFit.cover,
      ),
    );
  }

  @override
  void dispose() {
    _gifController.dispose();
    super.dispose();
  }
}

class GifFooter1 extends StatefulWidget {
  const GifFooter1({super.key});

  @override
  State<StatefulWidget> createState() {
    return _GifFooter1State();
  }
}

class _GifFooter1State extends State<GifFooter1>
    with SingleTickerProviderStateMixin {
  late AnimationController _gifController;
  late Animation<double> _opacity;

  @override
  void initState() {
    _gifController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
      value: 0.2,
    );
    _opacity = CurvedAnimation(parent: _gifController, curve: Curves.linear);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CustomFooter(
      height: 80,
      builder: (context, mode) {
        return FadeTransition(
          opacity: _opacity,
          child: Image.asset(
            "images/gifindicator1.gif",
            height: 80.0,
            width: 537.0,
            fit: BoxFit.cover,
          ),
        );
      },
      loadStyle: LoadStyle.showWhenLoading,
      onModeChange: (mode) {
        if (mode == LoadStatus.loading) {
          _gifController.repeat(reverse: true);
        }
      },
      endLoading: () async {
        _gifController.value = 1.0;
        return _gifController.animateTo(
          0.2,
          duration: const Duration(milliseconds: 500),
        );
      },
    );
  }

  @override
  void dispose() {
    _gifController.dispose();
    super.dispose();
  }
}

class GifIndicatorExample1 extends StatefulWidget {
  const GifIndicatorExample1({super.key});

  @override
  State<StatefulWidget> createState() {
    return GifIndicatorExample1State();
  }
}

class GifIndicatorExample1State extends State<GifIndicatorExample1> {
  final RefreshController _controller = RefreshController();
  @override
  Widget build(BuildContext context) {
    return RefreshConfiguration.copyAncestor(
      context: context,
      // two attrs enable footer implements the effect in header default
      enableBallisticLoad: false,
      footerTriggerDistance: -80,
      child: SmartRefresher(
        controller: _controller,
        enablePullUp: true,
        header: const GifHeader1(),
        footer: const GifFooter1(),
        onRefresh: () async {
          await Future.delayed(const Duration(milliseconds: 2000));
          _controller.refreshCompleted();
        },
        onLoading: () async {
          await Future.delayed(const Duration(milliseconds: 2000));
          _controller.loadFailed();
        },
        child: ListView.builder(
          itemBuilder: (c, q) => const Card(),
          itemCount: 50,
          itemExtent: 100.0,
        ),
      ),
    );
  }
}
