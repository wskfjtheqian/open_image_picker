import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:core';
import 'package:file_chooser/file_chooser.dart';
import 'package:flutter/widgets.dart';
import '../open_image_picker.dart';
import 'dart:ui' as ui;

class _ImageFile extends UImageFile {
  String _path;

  double _width;

  double _height;

  _ImageFile(this._path, this._width, this._height);

  @override
  String get path => _path;

  @override
  double get height => _height;

  @override
  double get width => _width;

  @override
  Future<Uint8List> readAsBytes(BuildContext context) {
    if (null == width && null == height) {
      return File(path).readAsBytes();
    }

    final ImageStream stream = FileImage(File(path)).resolve(createLocalImageConfiguration(context));
    var listener;
    var completer = Completer<ui.Image>();
    listener = ImageStreamListener((image, synchronousCall) {
      completer.complete(image.image);
      stream.removeListener(listener);
    }, onError: (exception, stackTrace) {
      stream.removeListener(listener);
      completer.completeError(exception);
    });
    stream.addListener(listener);

    return completer.future.then(outImageBytes);
  }

  Future<Uint8List> outImageBytes(ui.Image image) {
    var scale;
    if (null == width) {
      scale = height / image.height;
      _width = image.width * scale;
    } else if (null == height) {
      scale = width / image.width;
      _height = image.height * scale;
    } else {
      scale = width / image.width < height / image.height ? width / image.width : height / image.height;
    }

    var recorder = ui.PictureRecorder();
    var canvas = ui.Canvas(recorder, ui.Rect.fromLTRB(0, 0, width, height));
    canvas.translate(width / 2, height / 2);
    canvas.scale(scale);
    canvas.drawImage(image, ui.Offset(-image.width / 2, -image.height / 2), ui.Paint());

    ui.Picture picture = recorder.endRecording();
    return picture.toImage(width.toInt(), height.toInt()).then((value) {
      return value.toByteData(format: ui.ImageByteFormat.png);
    }).then((value) {
      return value.buffer.asUint8List();
    });
  }
}

Future<List<UImageFile>> openImage({
  bool allowsMultipleSelection = true,
  double width,
  double height,
}) async {
  var file = await showOpenPanel(
    allowsMultipleSelection: allowsMultipleSelection,
    allowedFileTypes: [
      FileTypeFilterGroup(label: "Images", fileExtensions: [
        'bmp',
        'gif',
        'jpeg',
        'jpg',
        'png',
        'tiff',
        'webp',
      ]),
    ],
  );

  if (file.canceled) {
    return [];
  }
  return file.paths.map((e) => _ImageFile(e, width, height)).toList();
}
