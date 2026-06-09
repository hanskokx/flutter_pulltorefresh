/*
    Author: JPeng
    Email: peng8350@gmail.com
    createTime:2018-05-14 15:39
 */

// ignore_for_file: INVALID_USE_OF_PROTECTED_MEMBER
// ignore_for_file: INVALID_USE_OF_VISIBLE_FOR_TESTING_MEMBER
import "dart:math" as math;

import "package:flutter/rendering.dart";
import "package:flutter/services.dart";
import "package:flutter/widgets.dart";

import "../smart_refresher.dart";
import "slivers.dart";

typedef VoidFutureCallBack = Future<void> Function();

typedef OffsetCallBack = void Function(double offset);

typedef ModeChangeCallBack<T> = void Function(T? mode);

/// a widget  implements ios pull down refresh effect and Android material RefreshIndicator overScroll effect
abstract class RefreshIndicator extends StatefulWidget {
  /// refresh display style
  final RefreshStyle? refreshStyle;

  /// the visual extent indicator
  final double height;

  //layout offset
  final double offset;

  /// the stopped time when refresh complete or fail
  final Duration completeDuration;

  const RefreshIndicator({
    super.key,
    this.height = 60.0,
    this.offset = 0.0,
    this.completeDuration = const Duration(milliseconds: 500),
    this.refreshStyle = RefreshStyle.follow,
  }) : super();
}

/// a widget  implements  pull up load
abstract class LoadIndicator extends StatefulWidget {
  /// load more display style
  final LoadStyle loadStyle;

  /// the visual extent indicator
  final double height;

  /// callback when user click footer
  final VoidCallback? onClick;

  const LoadIndicator({
    super.key,
    this.onClick,
    this.loadStyle = LoadStyle.showAlways,
    this.height = 60.0,
  }) : super();
}

/// Internal Implementation of Head Indicator
///
/// you can extends RefreshIndicatorState for custom header,if you want to active complex animation effect
///
/// here is the most simple example
///
/// ```dart
///
/// class RunningHeaderState extends RefreshIndicatorState<RunningHeader>
///    with TickerProviderStateMixin {
///  AnimationController _scaleAnimation;
///  AnimationController _offsetController;
///  Tween<Offset> offsetTween;
///
///  @override
///  void initState() {
///    _scaleAnimation = AnimationController(vsync: this);
///    _offsetController = AnimationController(
///        vsync: this, duration: Duration(milliseconds: 1000));
///    offsetTween = Tween(end: Offset(0.6, 0.0), begin: Offset(0.0, 0.0));
///    super.initState();
///  }
///
///  @override
///  void onOffsetChange(double offset) {
///    if (!floating) {
///      _scaleAnimation.value = offset / 80.0;
///    }
///    super.onOffsetChange(offset);
///  }
///
///  @override
///  void resetValue() {
///    _scaleAnimation.value = 0.0;
///    _offsetController.value = 0.0;
///  }
///
///  @override
///  void dispose() {
///    _scaleAnimation.dispose();
///    _offsetController.dispose();
///    super.dispose();
///  }
///
///  @override
///  Future<void> endRefresh() {
///    return _offsetController.animateTo(1.0).whenComplete(() {});
///  }
///
///  @override
/// Widget buildContent(BuildContext context, RefreshStatus mode) {
///    return SlideTransition(
///      child: ScaleTransition(
///        child: (mode != RefreshStatus.idle || mode != RefreshStatus.canRefresh)
///            ? Image.asset("images/custom_2.gif")
///            : Image.asset("images/custom_1.jpg"),
///        scale: _scaleAnimation,
///      ),
///      position: offsetTween.animate(_offsetController),
///    );
///  }
/// }
/// ```
abstract class RefreshIndicatorState<T extends RefreshIndicator>
    extends State<T>
    with IndicatorStateMixin<T, RefreshStatus>, RefreshProcessor {
  bool _inVisual() {
    return _requirePosition().pixels < 0.0;
  }

  @override
  double _calculateScrollOffset() {
    final ScrollPosition position = _requirePosition();
    return (floating
            ? (mode == RefreshStatus.twoLeveling ||
                      mode == RefreshStatus.twoLevelOpening ||
                      mode == RefreshStatus.twoLevelClosing
                  ? _requireRefresherState().viewportExtent
                  : widget.height)
            : 0.0) -
        position.pixels;
  }

  @override
  void _handleOffsetChange() {
    super._handleOffsetChange();
    final double overscrollPast = _calculateScrollOffset();
    onOffsetChange(overscrollPast);
  }

  // handle the  state change between canRefresh and idle canRefresh  before refreshing
  @override
  void _dispatchModeByOffset(double offset) {
    final ScrollPosition position = _requirePosition();
    final RefreshConfiguration conf = _requireConfiguration();
    final SmartRefresher currentRefresher = _requireRefresher();
    if (mode == RefreshStatus.twoLeveling) {
      if (position.pixels > conf.closeTwoLevelDistance &&
          activity is BallisticScrollActivity) {
        currentRefresher.controller.twoLevelComplete();
        return;
      }
    }
    if (RefreshStatus.twoLevelOpening == mode ||
        mode == RefreshStatus.twoLevelClosing) {
      return;
    }
    if (floating) return;
    // no matter what activity is done, when offset ==0.0 and !floating,it should be set to idle for setting ifCanDrag
    if (offset == 0.0) {
      mode = RefreshStatus.idle;
    }

    // If FrontStyle overScroll,it shouldn't disable gesture in scrollable
    if (position.extentBefore == 0.0 &&
        widget.refreshStyle == RefreshStyle.front) {
      position.context.setIgnorePointer(false);
    }
    // Sometimes different devices return velocity differently, so it's impossible to judge from velocity whether the user
    // has invoked animateTo (0.0) or the user is dragging the view.Sometimes animateTo (0.0) does not return velocity = 0.0
    // velocity < 0.0 may be spring up,>0.0 spring down
    if ((conf.enableBallisticRefresh && activity.velocity < 0.0) ||
        activity is DragScrollActivity ||
        activity is DrivenScrollActivity) {
      if (currentRefresher.enablePullDown &&
          offset >= conf.headerTriggerDistance) {
        if (!conf.skipCanRefresh) {
          mode = RefreshStatus.canRefresh;
        } else {
          floating = true;
          update();
          readyToRefresh().then((_) {
            if (!mounted) return;
            mode = RefreshStatus.refreshing;
          });
        }
      } else if (currentRefresher.enablePullDown) {
        mode = RefreshStatus.idle;
      }
      if (currentRefresher.enableTwoLevel &&
          offset >= conf.twiceTriggerDistance) {
        mode = RefreshStatus.canTwoLevel;
      } else if (currentRefresher.enableTwoLevel &&
          !currentRefresher.enablePullDown) {
        mode = RefreshStatus.idle;
      }
    }
    //mostly for spring back
    else if (activity is BallisticScrollActivity) {
      if (RefreshStatus.canRefresh == mode) {
        // refreshing
        floating = true;
        update();
        readyToRefresh().then((_) {
          if (!mounted) return;
          mode = RefreshStatus.refreshing;
        });
      }
      if (mode == RefreshStatus.canTwoLevel) {
        // enter twoLevel
        floating = true;
        update();
        if (!mounted) return;

        mode = RefreshStatus.twoLevelOpening;
      }
    }
  }

  @override
  void _handleModeChange() {
    if (!mounted) {
      return;
    }
    final SmartRefresherState state = _requireRefresherState();
    final RefreshConfiguration conf = _requireConfiguration();
    final SmartRefresher currentRefresher = _requireRefresher();
    final ScrollPosition position = _requirePosition();
    update();
    if (mode == RefreshStatus.idle || mode == RefreshStatus.canRefresh) {
      floating = false;

      resetValue();

      if (mode == RefreshStatus.idle) state.setCanDrag(true);
    }
    if (mode == RefreshStatus.completed || mode == RefreshStatus.failed) {
      endRefresh().then((_) {
        if (!mounted) return;
        floating = false;
        if (mode == RefreshStatus.completed || mode == RefreshStatus.failed) {
          state.setCanDrag(conf.enableScrollWhenRefreshCompleted);
        }
        update();
        /*
          handle two Situation:
          1.when user dragging to refreshing, then user scroll down not to see the indicator,then it will not spring back,
          the _onOffsetChange didn't callback,it will keep failed or success state.
          2. As FrontStyle,when user dragging in 0~100 in refreshing state,it should be reset after the state change
          */
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) {
            return;
          }
          if (widget.refreshStyle == RefreshStyle.front) {
            if (_inVisual()) {
              position.jumpTo(0.0);
            }
            mode = RefreshStatus.idle;
          } else {
            if (!_inVisual()) {
              mode = RefreshStatus.idle;
            } else {
              activity.delegate.goBallistic(0.0);
            }
          }
        });
      });
    } else if (mode == RefreshStatus.refreshing) {
      if (!floating) {
        floating = true;
        readyToRefresh();
      }
      if (conf.enableRefreshVibrate) {
        HapticFeedback.vibrate();
      }
      currentRefresher.onRefresh?.call();
    } else if (mode == RefreshStatus.twoLevelOpening) {
      floating = true;
      state.setCanDrag(false);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        activity.resetActivity();
        position
            .animateTo(
              0.0,
              duration: const Duration(milliseconds: 500),
              curve: Curves.linear,
            )
            .whenComplete(() {
              mode = RefreshStatus.twoLeveling;
            });
        if (currentRefresher.onTwoLevel != null) {
          currentRefresher.onTwoLevel?.call(true);
        }
      });
    } else if (mode == RefreshStatus.twoLevelClosing) {
      floating = false;
      state.setCanDrag(false);
      update();
      if (currentRefresher.onTwoLevel != null) {
        currentRefresher.onTwoLevel?.call(false);
      }
    } else if (mode == RefreshStatus.twoLeveling) {
      state.setCanDrag(conf.enableScrollWhenTwoLevel);
    }
    onModeChange(mode);
  }

  // the method can provide a callback to implements some animation
  @override
  Future<void> readyToRefresh() {
    return Future.value();
  }

  // it mean the state will enter success or fail
  @override
  Future<void> endRefresh() {
    return Future.delayed(widget.completeDuration);
  }

  bool needReverseAll() {
    return true;
  }

  @override
  void resetValue() {}

  @override
  Widget build(BuildContext context) {
    return SliverRefresh(
      paintOffsetY: widget.offset,
      floating: floating,
      refreshIndicatorLayoutExtent:
          mode == RefreshStatus.twoLeveling ||
              mode == RefreshStatus.twoLevelOpening ||
              mode == RefreshStatus.twoLevelClosing
          ? _requireRefresherState().viewportExtent
          : widget.height,
      refreshStyle: widget.refreshStyle,
      child: RotatedBox(
        quarterTurns:
            needReverseAll() &&
                Scrollable.of(context).axisDirection == AxisDirection.up
            ? 10
            : 0,
        child: buildContent(context, mode ?? RefreshStatus.idle),
      ),
    );
  }
}

abstract class LoadIndicatorState<T extends LoadIndicator> extends State<T>
    with IndicatorStateMixin<T, LoadStatus>, LoadingProcessor {
  // use to update between one page and above one page
  bool _isHide = false;
  bool _enableLoading = false;
  LoadStatus? _lastMode = LoadStatus.idle;

  @override
  double _calculateScrollOffset() {
    final ScrollPosition position = _requirePosition();
    final double overScrollPastEnd = math.max(
      position.pixels - position.maxScrollExtent,
      0.0,
    );
    return overScrollPastEnd;
  }

  void enterLoading() {
    setState(() {
      floating = true;
    });
    _enableLoading = false;
    readyToLoad().then((_) {
      if (!mounted) {
        return;
      }
      mode = LoadStatus.loading;
    });
  }

  @override
  Future endLoading() {
    return Future.delayed(const Duration(milliseconds: 0));
  }

  void finishLoading() {
    if (!floating) {
      return;
    }
    endLoading().then((_) {
      if (!mounted) {
        return;
      }

      // this line for patch bug temporary:indicator disappears fastly when load more complete
      if (mounted) Scrollable.of(context).position.correctBy(0.00001);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _position?.outOfRange == true) {
          activity.delegate.goBallistic(0);
        }
      });
      setState(() {
        floating = false;
      });
    });
  }

  bool _checkIfCanLoading() {
    final ScrollPosition position = _requirePosition();
    final RefreshConfiguration conf = _requireConfiguration();
    if (position.maxScrollExtent - position.pixels <=
            conf.footerTriggerDistance &&
        position.extentBefore > 2.0 &&
        _enableLoading) {
      if (!conf.enableLoadingWhenFailed && mode == LoadStatus.failed) {
        return false;
      }
      if (!conf.enableLoadingWhenNoData && mode == LoadStatus.noMore) {
        return false;
      }
      if (mode != LoadStatus.canLoading &&
          position.userScrollDirection == ScrollDirection.forward) {
        return false;
      }
      return true;
    }
    return false;
  }

  @override
  void _handleModeChange() {
    if (!mounted || _isHide) {
      return;
    }
    final ScrollPosition position = _requirePosition();
    final RefreshConfiguration conf = _requireConfiguration();
    final SmartRefresher currentRefresher = _requireRefresher();

    update();
    if (mode == LoadStatus.idle ||
        mode == LoadStatus.failed ||
        mode == LoadStatus.noMore) {
      // #292,#265,#208
      // stop the slow bouncing when load more too fast
      final ScrollActivity? currentActivity = position.activity;
      if ((currentActivity?.velocity ?? 0.0) < 0 &&
          _lastMode == LoadStatus.loading &&
          !position.outOfRange &&
          position is ScrollActivityDelegate) {
        position.beginActivity(
          IdleScrollActivity(position as ScrollActivityDelegate),
        );
      }

      finishLoading();
    }
    if (mode == LoadStatus.loading) {
      if (!floating) {
        enterLoading();
      }
      if (conf.enableLoadMoreVibrate) {
        HapticFeedback.vibrate();
      }
      currentRefresher.onLoading?.call();
      if (widget.loadStyle == LoadStyle.showWhenLoading) {
        floating = true;
      }
    } else {
      if (activity is! DragScrollActivity) _enableLoading = false;
    }
    _lastMode = mode;
    onModeChange(mode);
  }

  @override
  void _dispatchModeByOffset(double offset) {
    if (!mounted || _isHide || LoadStatus.loading == mode || floating) {
      return;
    }
    if (activity is DragScrollActivity) {
      if (_checkIfCanLoading()) {
        mode = LoadStatus.canLoading;
      } else {
        mode = _lastMode;
      }
    }
    if (activity is BallisticScrollActivity) {
      if (_requireConfiguration().enableBallisticLoad) {
        if (_checkIfCanLoading()) enterLoading();
      } else if (mode == LoadStatus.canLoading) {
        enterLoading();
      }
    }
  }

  @override
  void _handleOffsetChange() {
    if (_isHide) {
      return;
    }
    super._handleOffsetChange();
    final double overscrollPast = _calculateScrollOffset();
    onOffsetChange(overscrollPast);
  }

  void _listenScrollEnd() {
    if (!_requirePosition().isScrollingNotifier.value) {
      // when user release gesture from screen
      if (_isHide || mode == LoadStatus.loading || mode == LoadStatus.noMore) {
        return;
      }

      if (_checkIfCanLoading()) {
        if (activity is IdleScrollActivity) {
          if ((_requireConfiguration().enableBallisticLoad) ||
              ((!_requireConfiguration().enableBallisticLoad) &&
                  mode == LoadStatus.canLoading))
            enterLoading();
        }
      }
    } else {
      if (activity is DragScrollActivity || activity is DrivenScrollActivity) {
        _enableLoading = true;
      }
    }
  }

  @override
  void _onPositionUpdated(ScrollPosition newPosition) {
    _position?.isScrollingNotifier.removeListener(_listenScrollEnd);
    newPosition.isScrollingNotifier.addListener(_listenScrollEnd);
    super._onPositionUpdated(newPosition);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _lastMode = mode;
  }

  @override
  void dispose() {
    _position?.isScrollingNotifier.removeListener(_listenScrollEnd);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final RefreshConfiguration conf = _requireConfiguration();
    return SliverLoading(
      hideWhenNotFull: conf.hideFooterWhenNotFull,
      floating: widget.loadStyle == LoadStyle.showAlways
          ? true
          : widget.loadStyle == LoadStyle.hideAlways
          ? false
          : floating,
      shouldFollowContent: conf.shouldFooterFollowWhenNotFull != null
          ? conf.shouldFooterFollowWhenNotFull!(mode)
          : mode == LoadStatus.noMore,
      layoutExtent: widget.height,
      mode: mode,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints cons) {
          _isHide = cons.biggest.height == 0.0;
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              if (widget.onClick != null) {
                widget.onClick!();
              }
            },
            child: buildContent(context, mode ?? LoadStatus.idle),
          );
        },
      ),
    );
  }
}

/// mixin in IndicatorState,it will get position and remove when dispose,init mode state
///
/// help to finish the work that the header indicator and footer indicator need to do
mixin IndicatorStateMixin<T extends StatefulWidget, V> on State<T> {
  SmartRefresher? refresher;

  RefreshConfiguration? configuration;
  SmartRefresherState? refresherState;

  bool _floating = false;

  set floating(bool floating) => _floating = floating;

  bool get floating => _floating;

  set mode(V? mode) => _mode?.value = mode;

  V? get mode => _mode?.value;

  RefreshNotifier<V?>? _mode;

  ScrollActivity get activity {
    final ScrollActivity? currentActivity = _requirePosition().activity;
    if (currentActivity == null) {
      throw StateError("ScrollActivity is not available for indicator state.");
    }
    return currentActivity;
  }

  // it doesn't support get the ScrollController as the listener, because it will cause "multiple scrollview use one ScrollController"
  // error,only replace the ScrollPosition to listen the offset
  ScrollPosition? _position;

  ScrollPosition _requirePosition() {
    final ScrollPosition? position = _position;
    if (position == null) {
      throw StateError("ScrollPosition is not available for indicator state.");
    }
    return position;
  }

  RefreshConfiguration _requireConfiguration() {
    final RefreshConfiguration? conf = configuration;
    if (conf == null) {
      throw StateError(
        "RefreshConfiguration is not available for indicator state.",
      );
    }
    return conf;
  }

  SmartRefresher _requireRefresher() {
    final SmartRefresher? currentRefresher = refresher;
    if (currentRefresher == null) {
      throw StateError("SmartRefresher is not available for indicator state.");
    }
    return currentRefresher;
  }

  SmartRefresherState _requireRefresherState() {
    final SmartRefresherState? state = refresherState;
    if (state == null) {
      throw StateError(
        "SmartRefresherState is not available for indicator state.",
      );
    }
    return state;
  }

  // update ui
  void update() {
    if (mounted) setState(() {});
  }

  void _handleOffsetChange() {
    if (!mounted) {
      return;
    }
    final double overscrollPast = _calculateScrollOffset();
    if (overscrollPast < 0.0) {
      return;
    }
    _dispatchModeByOffset(overscrollPast);
  }

  void disposeListener() {
    _mode?.removeListener(_handleModeChange);
    _position?.removeListener(_handleOffsetChange);
    _position = null;
    _mode = null;
  }

  void _updateListener() {
    configuration = RefreshConfiguration.of(context);
    refresher = SmartRefresher.of(context);
    refresherState = SmartRefresher.ofState(context);
    final SmartRefresher currentRefresher = _requireRefresher();
    final RefreshNotifier<V>? newMode = V == RefreshStatus
        ? currentRefresher.controller.headerMode as RefreshNotifier<V>?
        : currentRefresher.controller.footerMode as RefreshNotifier<V>?;
    final ScrollPosition newPosition = Scrollable.of(context).position;
    if (newMode != _mode) {
      _mode?.removeListener(_handleModeChange);
      _mode = newMode;
      _mode?.addListener(_handleModeChange);
    }
    if (newPosition != _position) {
      _position?.removeListener(_handleOffsetChange);
      _onPositionUpdated(newPosition);
      _position = newPosition;
      _position?.addListener(_handleOffsetChange);
    }
  }

  @override
  void initState() {
    if (V == RefreshStatus) {
      SmartRefresher.of(context)?.controller.headerMode?.value =
          RefreshStatus.idle;
    }
    super.initState();
  }

  @override
  void dispose() {
    //1.3.7: here need to careful after add asSliver builder
    disposeListener();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    _updateListener();
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(T oldWidget) {
    // needn't to update _headerMode,because it's state will never change
    // 1.3.7: here need to careful after add asSliver builder
    _updateListener();
    super.didUpdateWidget(oldWidget);
  }

  void _onPositionUpdated(ScrollPosition newPosition) {
    _requireRefresher().controller.onPositionUpdated(newPosition);
  }

  void _handleModeChange();

  double _calculateScrollOffset();

  void _dispatchModeByOffset(double offset);

  Widget buildContent(BuildContext context, V mode);
}

/// head Indicator exposure interface
mixin RefreshProcessor {
  /// out of edge offset callback
  void onOffsetChange(double offset) {}

  /// mode change callback
  void onModeChange(RefreshStatus? mode) {}

  /// when indicator is ready into refresh,it will call back and waiting for this function finish,then callback onRefresh
  Future readyToRefresh() {
    return Future.value();
  }

  // when indicator is ready to dismiss layout ,it will callback and then spring back after finish
  Future endRefresh() {
    return Future.value();
  }

  // when indicator has been spring back,it  need to reset value
  void resetValue() {}
}

/// footer Indicator exposure interface
mixin LoadingProcessor {
  void onOffsetChange(double offset) {}

  void onModeChange(LoadStatus? mode) {}

  /// when indicator is ready into refresh,it will call back and waiting for this function finish,then callback onRefresh
  Future readyToLoad() {
    return Future.value();
  }

  // when indicator is ready to dismiss layout ,it will callback and then spring back after finish
  Future endLoading() {
    return Future.value();
  }

  // when indicator has been spring back,it  need to reset value
  void resetValue() {}
}
