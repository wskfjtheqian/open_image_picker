import 'dart:async';
import 'dart:core';
import 'dart:typed_data';
import 'dart:ui' as ui;

// ignore: avoid_web_libraries_in_flutter
import 'dart:html';

import 'package:flutter/services.dart';
import 'open_image_picker_pc.dart' as pc;

Future<ui.Image> zoomImage(ui.Image image, double maxWidth, double maxHeight) {
  if (!(image is ImageElement)) {
    return pc.zoomImage(image, maxWidth, maxHeight);
  }
  if (null == maxWidth && null == maxHeight) {
    return Future.value(image);
  }

  var scale;
  if (null == maxWidth) {
    scale = maxHeight / image.height;
    maxWidth = image.width * scale;
  } else if (null == maxHeight) {
    scale = maxWidth / image.width;
    maxHeight = image.height * scale;
  } else {
    scale = maxWidth / image.width < maxHeight / image.height ? maxWidth / image.width : maxHeight / image.height;
    maxWidth = image.width * scale;
    maxHeight = image.height * scale;
  }

  var canvas = CanvasElement(width: maxWidth.toInt(), height: maxHeight.toInt());
  canvas.context2D.translate(maxWidth / 2, maxHeight / 2);
  canvas.context2D.scale(scale, scale);
  canvas.context2D.drawImage((image as dynamic).imgElement, -image.width / 2, -image.height / 2);

  return Future.value(HtmlImage(canvas));
}

class HtmlImage implements ui.Image {
  CanvasElement element;

  HtmlImage(this.element);

  @override
  void dispose() {}

  @override
  int get height => element.height;

  @override
  // ignore: invalid_override_different_default_values_named
  Future<ByteData> toByteData({ui.ImageByteFormat format = ui.ImageByteFormat.png}) async {
    var completer = new Completer<ByteData>();

    final out = new FileReader();
    out.onLoadEnd.listen((event) {
      completer.complete((out.result as Uint8List).buffer.asByteData());
    });
    out.onError.listen((event) {
      completer.completeError(event);
    });
    out.readAsArrayBuffer(await element.toBlob());
    return completer.future;
  }

  int get width => element.width;

  @override
  ui.Image clone() {
    return null;
  }

  @override
  bool get debugDisposed => throw UnimplementedError();

  @override
  List<StackTrace> debugGetOpenHandleStackTraces() {
    return [];
  }

  @override
  bool isCloneOf(ui.Image other) {
    return false;
  }
}
