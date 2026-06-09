import "package:flutter/material.dart";

class SpinKitFadingCircle extends StatefulWidget {
  const SpinKitFadingCircle({
    super.key,
    this.color,
    this.size = 50.0,
    this.itemBuilder,
    this.animationController,
    this.duration = const Duration(milliseconds: 1200),
  }) : assert(
         itemBuilder != null || color != null,
         "You should specify either an itemBuilder or a color",
       );

  final Color? color;
  final double size;
  final IndexedWidgetBuilder? itemBuilder;
  final AnimationController? animationController;
  final Duration duration;

  @override
  State<SpinKitFadingCircle> createState() => _SpinKitFadingCircleState();
}

class _SpinKitFadingCircleState extends State<SpinKitFadingCircle>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fallbackController;

  AnimationController get _controller =>
      widget.animationController ?? _fallbackController;

  @override
  void initState() {
    super.initState();
    _fallbackController = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat();
  }

  @override
  void dispose() {
    if (widget.animationController == null) {
      _fallbackController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox.fromSize(
        size: Size.square(widget.size),
        child: Stack(
          children: const [
            _CircleIndex(1, .0),
            _CircleIndex(2, -1.1),
            _CircleIndex(3, -1.0),
            _CircleIndex(4, -0.9),
            _CircleIndex(5, -0.8),
            _CircleIndex(6, -0.7),
            _CircleIndex(7, -0.6),
            _CircleIndex(8, -0.5),
            _CircleIndex(9, -0.4),
            _CircleIndex(10, -0.3),
            _CircleIndex(11, -0.2),
            _CircleIndex(12, -0.1),
          ].map(_buildCircle).toList(),
        ),
      ),
    );
  }

  static Widget _buildCircle(_CircleIndex item) => _Circle(item: item);
}

class _CircleIndex {
  const _CircleIndex(this.index, this.delay);

  final int index;
  final double delay;
}

class _Circle extends StatelessWidget {
  const _Circle({required this.item});

  final _CircleIndex item;

  @override
  Widget build(BuildContext context) {
    final state = context.findAncestorStateOfType<_SpinKitFadingCircleState>();
    if (state == null) {
      return const SizedBox.shrink();
    }
    final widget = state.widget;
    final size = widget.size * 0.15;
    final position = widget.size * .5;

    return Positioned.fill(
      left: position,
      top: position,
      child: Transform(
        transform: Matrix4.rotationZ(30.0 * (item.index - 1) * 0.0174533),
        child: Align(
          alignment: Alignment.center,
          child: FadeTransition(
            opacity: DelayTween(
              begin: 0.0,
              end: 1.0,
              delay: item.delay,
            ).animate(state._controller),
            child: SizedBox.fromSize(
              size: Size.square(size),
              child: widget.itemBuilder != null
                  ? widget.itemBuilder!(context, item.index - 1)
                  : DecoratedBox(
                      decoration: BoxDecoration(
                        color: widget.color,
                        shape: BoxShape.circle,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class DelayTween extends Tween<double> {
  DelayTween({required super.begin, required super.end, required this.delay});

  final double delay;

  @override
  double transform(double t) {
    final shifted = (t + delay).clamp(0.0, 1.0);
    final double from = begin ?? 0.0;
    final double to = end ?? 1.0;
    return from + (to - from) * shifted;
  }
}
