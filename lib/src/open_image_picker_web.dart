import 'dart:async';
import 'dart:typed_data';
import 'dart:core';

import 'package:flutter/widgets.dart';

import '../open_image_picker.dart';
import 'dart:ui' as ui;
import 'dart:html' as html;

class _ImageFile extends UImageFile {
  html.File _file;

  double _width;

  double _height;

  _ImageFile(this._file, this._width, this._height);

  @override
  String get path => _file.relativePath;

  @override
  double get height => _height;

  @override
  double get width => _width;

  @override
  Future<Uint8List> readAsBytes(BuildContext context) async {
    final reader = html.FileReader();
    reader.readAsArrayBuffer(_file);
    await reader.onLoad.first;
    if (null == width && null == height) {
      return reader.result;
    }

    final ImageStream stream = MemoryImage(reader.result).resolve(createLocalImageConfiguration(context));
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

  Future<Uint8List> outImageBytes(ui.Image image) async {
    double scale;
    if (null == width) {
      scale = height / image.height;
      _width = image.width * scale;
    } else if (null == height) {
      scale = width / image.width;
      _height = image.height * scale;
    } else {
      scale = width / image.width < height / image.height ? width / image.width : height / image.height;
    }

    var canvas = html.CanvasElement(width: width.toInt(), height: height.toInt());
    canvas.context2D.translate(width / 2, height / 2);
    canvas.context2D.scale(scale, scale);
    canvas.context2D.drawImage((image as dynamic).imgElement, -image.width / 2, -image.height / 2);

    var completer = new Completer<Uint8List>();
    final out = new html.FileReader();
    out.onLoadEnd.listen((event) {
      completer.complete(out.result as Uint8List);
    });
    out.onError.listen((event) {
      completer.completeError(event);
    });
    out.readAsArrayBuffer(await canvas.toBlob());
    return completer.future;
  }
}

Future<List<UImageFile>> openImage({
  bool allowsMultipleSelection = true,
  double width,
  double height,
}) async {
  final html.FileUploadInputElement input = html.FileUploadInputElement();
  input.accept = 'image/*';
  input.multiple = allowsMultipleSelection;
  input.click();
  await input.onChange.first;
  if (input.files.isEmpty) {
    return [];
  }
  return input.files.map((e) => _ImageFile(e, width, height)).toList();
}
