import 'package:flutter/foundation.dart';

class ZoomNotifier {
  // Private notifier, starts with a default zoom level of 1.0 (normal size)
  static final ValueNotifier<double> _zoomLevel = ValueNotifier<double>(0.7);

  // Public getter to listen to changes
  static ValueNotifier<double> get zoomLevel => _zoomLevel;

  // Define zoom limits
  static const double _minZoom = 0.3;
  static const double _maxZoom = 1.0;
  static const double _zoomStep = 0.1;

  /// Increases the zoom level by one step, up to the maximum limit.
  static void increaseZoom() {
    if (_zoomLevel.value < _maxZoom) {
      _zoomLevel.value = double.parse(
        (_zoomLevel.value + _zoomStep).toStringAsFixed(2),
      );
    }
  }

  /// Decreases the zoom level by one step, down to the minimum limit.
  static void decreaseZoom() {
    if (_zoomLevel.value > _minZoom) {
      _zoomLevel.value = double.parse(
        (_zoomLevel.value - _zoomStep).toStringAsFixed(2),
      );
    }
  }

  /// Resets the zoom level to the default value (1.0).
  static void resetZoom() {
    _zoomLevel.value = 1.0;
  }
}
