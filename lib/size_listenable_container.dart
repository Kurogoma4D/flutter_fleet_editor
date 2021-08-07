import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';

typedef SizeChangedCallback = void Function(Size size);

class SizeListenableContainer extends SingleChildRenderObjectWidget {
  const SizeListenableContainer({
    Key? key,
    required Widget child,
    required this.onSizeChanged,
  }) : super(key: key, child: child);

  final SizeChangedCallback onSizeChanged;

  @override
  _SizeListenableRenderObject createRenderObject(BuildContext context) {
    return _SizeListenableRenderObject(onSizeChanged: onSizeChanged);
  }
}

class _SizeListenableRenderObject extends RenderProxyBox {
  _SizeListenableRenderObject({
    RenderBox? child,
    required this.onSizeChanged,
  }) : super(child);

  final SizeChangedCallback onSizeChanged;

  Size _oldSize = Size.zero;

  @override
  void performLayout() {
    super.performLayout();

    final Size size = this.size;
    if (size != _oldSize) {
      _oldSize = size;
      _callback(size);
    }
  }

  void _callback(Size size) {
    SchedulerBinding.instance?.addPostFrameCallback((Duration _) {
      onSizeChanged(size);
    });
  }
}
