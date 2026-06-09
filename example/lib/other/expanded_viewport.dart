/*
 * Author: Jpeng
 * Email: peng8350@gmail.com
 * Time:  2019-07-11 12:23
 */

import "package:flutter/widgets.dart";

/*
   Compatibility wrapper for old examples that used a custom expanded viewport.
   Modern Flutter viewport APIs changed significantly, so this keeps the sample
   code compiling while preserving the original intent and call sites.
 */
class ExpandedViewport extends Viewport {
  ExpandedViewport({
    required super.offset, super.key,
    super.axisDirection = AxisDirection.down,
    super.crossAxisDirection,
    super.anchor = 0.0,
    super.center,
    super.clipBehavior = Clip.hardEdge,
    super.slivers,
  });
}

// Legacy marker sliver used by old examples.
class SliverExpanded extends StatelessWidget {
  const SliverExpanded({super.key});

  @override
  Widget build(BuildContext context) {
    return const SliverToBoxAdapter(child: SizedBox.shrink());
  }
}
