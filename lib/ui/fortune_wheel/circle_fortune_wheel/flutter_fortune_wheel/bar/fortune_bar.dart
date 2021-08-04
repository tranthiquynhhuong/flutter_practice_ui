//
//import 'dart:ui';
//
//import 'package:flutter/material.dart';
//import 'package:flutter_practice_ui/ui/fortune_wheel/circle_fortune_wheel/flutter_fortune_wheel/bar/fortune_bar.dart';
//import 'package:flutter_practice_ui/ui/fortune_wheel/circle_fortune_wheel/flutter_fortune_wheel/bar/fortune_bar.dart';
//import 'package:flutter_practice_ui/ui/fortune_wheel/circle_fortune_wheel/flutter_fortune_wheel/core/core.dart';
//import 'package:flutter_practice_ui/ui/fortune_wheel/circle_fortune_wheel/flutter_fortune_wheel/indicators/indicators.dart';
//import 'dart:math' as Math;
//
//import 'package:flutter_hooks/flutter_hooks.dart';
//import 'package:rxdart/rxdart.dart';
//
//import 'item.dart';
//import 'infinite_bar.dart';
//
//
//
//
//
///// A fortune bar visualizes a (random) selection process as a horizontal bar
///// divided into uniformly sized boxes, which correspond to the number of
///// [items]. When spinning, items are moved horizontally for [duration].
/////
///// See also:
/////  * [FortuneWheel], which provides an alternative visualization
/////  * [FortuneWidget()], which automatically chooses a fitting widget
/////  * [Fortune.randomItem], which helps selecting random items from a list
/////  * [Fortune.randomDuration], which helps choosing a random duration
//class FortuneBar extends HookWidget implements FortuneWidget {
//  static const int kDefaultVisibleItemCount = 3;
//
//  static const List<FortuneIndicator> kDefaultIndicators =
//      const <FortuneIndicator>[
//    FortuneIndicator(
//      alignment: Alignment.topCenter,
//      child: RectangleIndicator(),
//    ),
//  ];
//
//  static const StyleStrategy kDefaultStyleStrategy =
//      const UniformStyleStrategy(borderWidth: 4);
//
//  /// Requires this widget to have exactly this height.
//  final double height;
//
//  /// {@macro flutter_fortune_wheel.FortuneWidget.items}
//  final List<FortuneItem> items;
//
//  /// {@macro flutter_fortune_wheel.FortuneWidget.selected}
//  final BehaviorSubject<int> selected;
//
//  /// {@macro flutter_fortune_wheel.FortuneWidget.rotationCount}
//  final int rotationCount;
//
//  /// {@macro flutter_fortune_wheel.FortuneWidget.duration}
//  final Duration duration;
//
//  final List<FortuneIndicator> indicators;
//
//  /// {@macro flutter_fortune_wheel.FortuneWidget.animationType}
//  final Curve curve;
//
//  /// {@macro flutter_fortune_wheel.FortuneWidget.onAnimationStart}
//  final VoidCallback onAnimationStart;
//
//  /// {@macro flutter_fortune_wheel.FortuneWidget.onAnimationEnd}
//  final VoidCallback onAnimationEnd;
//
//  /// {@macro flutter_fortune_wheel.FortuneWidget.styleStrategy}
//  final StyleStrategy styleStrategy;
//
//  /// {@macro flutter_fortune_wheel.FortuneWidget.physics}
//  final PanPhysics physics;
//
//  /// {@macro flutter_fortune_wheel.FortuneWidget.onFling}
//  final VoidCallback onFling;
//
//  /// If this value is true, this widget expands to the screen width and ignores
//  /// width constraints imposed by parent widgets.
//  ///
//  /// This is disabled by default.
//  final bool fullWidth;
//
//  /// {@macro flutter_fortune_wheel.FortuneWidget.animateFirst}
//  final bool animateFirst;
//
//  final int visibleItemCount;
//
//  /// {@template flutter_fortune_wheel.FortuneBar}
//  /// Creates a new [FortuneBar] with the given [items], which is centered
//  /// on the [selected] value.
//  ///
//  /// {@macro flutter_fortune_wheel.FortuneWidget.ctorArgs}.
//  ///
//  /// See also:
//  ///  * [FortuneWheel], which provides an alternative visualization.
//  /// {@endtemplate}
//  FortuneBar({
//    Key key,
//    this.height = 56.0,
//    this.duration = FortuneWidget.kDefaultDuration,
//    this.onAnimationStart,
//    this.onAnimationEnd,
//    this.curve = FortuneCurve.spin,
//    @required this.selected,
//    this.rotationCount = FortuneWidget.kDefaultRotationCount,
//    @required this.items,
//    this.indicators = kDefaultIndicators,
//    this.fullWidth = false,
//    this.styleStrategy = kDefaultStyleStrategy,
//    this.animateFirst = true,
//    this.visibleItemCount = kDefaultVisibleItemCount,
//    this.onFling,
//    PanPhysics physics,
//  })  : physics = physics ?? DirectionalPanPhysics.horizontal(),
//        super(key: key);
//
//  @override
//  Widget build(BuildContext context) {
//    final animationCtrl = useAnimationController(duration: duration);
//    final animation = CurvedAnimation(parent: animationCtrl, curve: curve);
//
//    // TODO: refactor: implement shared fortune animation hook
//    Future<void> animate() async {
//      if (animationCtrl.isAnimating) {
//        return;
//      }
//
//      await Future.microtask(() => onAnimationStart?.call());
//      await animationCtrl.forward(from: 0);
//      await Future.microtask(() => onAnimationEnd?.call());
//    }
//
//    useEffect(() {
//      if (animateFirst) animate();
//      return null;
//    }, []);
//
//    useValueChanged(selected, (int _, Future<void> __) async {
//      await animate();
//    });
//
//    final theme = Theme.of(context);
//
//    return PanAwareBuilder(
//        behavior: HitTestBehavior.translucent,
//        physics: physics,
//        onFling: onFling,
//        builder: (context, panState) {
//          return LayoutBuilder(builder: (context, constraints) {
//            final size = Size(
//              fullWidth
//                  ? MediaQuery.of(context).size.width
//                  : constraints.maxWidth,
//              height,
//            );
//
//            return Stack(
//              children: [
//                AnimatedBuilder(
//                    animation: animation,
//                    builder: (context, _) {
//                      final itemPosition =
//                          (items.length * rotationCount + selected);
//                      final panFactor = 2 / size.width;
//                      final panOffset = -panState.distance * panFactor;
//                      final position =
//                          animation.value * itemPosition + panOffset;
//
//                      return InfiniteBar(
//                        centerPosition: 1,
//                        visibleItemCount: visibleItemCount,
//                        size: size,
//                        position: position,
//                        children: [
//                          for (int i = 0; i < items.length; i++)
//                            FortuneBarItem(
//                              child: items[i].child,
//                              style: styleStrategy.getItemStyle(
//                                theme,
//                                i,
//                                items.length,
//                              ),
//                            )
//                        ],
//                      );
//                    }),
//                for (var it in indicators)
//                  Align(
//                    alignment: it.alignment,
//                    child: SizedBox(
//                      width: size.width / visibleItemCount,
//                      height: height,
//                      child: it.child,
//                    ),
//                  ),
//              ],
//            );
//          });
//        });
//  }
//}
