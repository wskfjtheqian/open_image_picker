import 'dart:async';
import 'dart:core';
import 'dart:ui' as ui;

Future<ui.Image> zoomImage(ui.Image image, double maxWidth, double maxHeight) {
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

  var recorder = ui.PictureRecorder();
  var canvas = ui.Canvas(recorder, ui.Rect.fromLTRB(0, 0, maxWidth, maxHeight));
  canvas.translate(maxWidth / 2, maxHeight / 2);
  canvas.scale(scale);
  canvas.drawImage(image, ui.Offset(-image.width / 2, -image.height / 2), ui.Paint());

  ui.Picture picture = recorder.endRecording();
  return picture.toImage(maxWidth.toInt(), maxHeight.toInt());
}
