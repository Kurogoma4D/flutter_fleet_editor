import 'package:come_back_fleet/size_listenable_container.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:gesture_x_detector/gesture_x_detector.dart';

final List<OverlayData> overlays = [];

const _baseFontSize = 60;

@immutable
class OverlayData {
  final ElementData data;
  final OverlayEntry overlay;

  OverlayData._({required this.data, required this.overlay});

  factory OverlayData.create(ElementData originalData) => OverlayData._(
        data: originalData,
        overlay: OverlayEntry(
          builder: (context) => _buildOverlay(context, originalData),
        ),
      );
}

class ElementData {
  Offset position = Offset.zero;
  double scale = 1.0;
  double baseScale = 1.0;
  double rotation = 0.0;
  double baseRotation = 0.0;
  bool isEditMode = false;
  Size childSize = Size.zero;
  DateTime tapTimeStamp = DateTime(0);

  final focus = FocusNode();
  late final controller = TextEditingController();

  @override
  int get hashCode => hashValues(focus, controller);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (runtimeType != other.runtimeType) return false;

    return this.hashCode == other.hashCode;
  }
}

Widget _buildOverlay(BuildContext context, ElementData data) {
  return data.isEditMode
      ? Material(
          color: Colors.black26,
          child: Center(
            child: TextField(
              controller: data.controller,
              focusNode: data.focus,
              decoration: InputDecoration(border: InputBorder.none),
              textAlign: TextAlign.center,
              onEditingComplete: () {
                final overlay = _overlayFromElement(data);

                if (data.controller.text.isEmpty) {
                  overlay.remove();
                  overlays.removeWhere((element) => element.overlay == overlay);
                  return;
                }

                data.focus.unfocus();
                data.isEditMode = false;
                data.focus.requestFocus();
                overlay.markNeedsBuild();
              },
              style: TextStyle(fontSize: _baseFontSize * data.scale),
            ),
          ),
        )
      : Positioned(
          top: data.position.dy - data.childSize.height / 2,
          left: data.position.dx - data.childSize.width / 2,
          child: Material(
            color: Colors.transparent,
            child: Listener(
              onPointerSignal: (signal) {
                if (!(signal is PointerScrollEvent)) return;

                final overlay = _overlayFromElement(data);

                data.scale += signal.scrollDelta.dy * 0.01;
                data.rotation -= signal.scrollDelta.dx * 0.01;

                overlay.markNeedsBuild();
              },
              child: XGestureDetector(
                bypassTapEventOnDoubleTap: true,
                onScaleStart: (details) {
                  data.baseScale = data.scale;
                  data.baseRotation = data.rotation;
                },
                onScaleUpdate: (details) {
                  final overlay = _overlayFromElement(data);
                  data.scale = data.baseScale * details.scale;
                  data.rotation = data.baseRotation + details.rotationAngle;
                  overlay.markNeedsBuild();
                },
                onMoveUpdate: (event) {
                  final overlay = _overlayFromElement(data);
                  data.position = event.position;
                  overlay.markNeedsBuild();
                },
                onMoveStart: (_) {
                  data.tapTimeStamp = DateTime.now();
                },
                onMoveEnd: (_) {
                  if (DateTime.now()
                          .difference(data.tapTimeStamp)
                          .inMilliseconds <
                      100) {
                    final overlay = _overlayFromElement(data);
                    data.isEditMode = true;
                    data.focus.requestFocus();
                    overlay.markNeedsBuild();
                  }
                },
                onTap: (_) {
                  data.isEditMode = true;
                  data.focus.requestFocus();
                },
                child: Transform.rotate(
                  angle: -data.rotation,
                  child: SizeListenableContainer(
                    onSizeChanged: (size) {
                      data.childSize = size;
                    },
                    child: Text(
                      data.controller.text,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: _baseFontSize * data.scale),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
}

OverlayEntry _overlayFromElement(ElementData data) {
  final index = overlays.indexWhere((element) => element.data == data);
  return overlays[index].overlay;
}
