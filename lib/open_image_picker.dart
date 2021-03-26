library open_image;

import 'dart:async';
import 'dart:core';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:open_file/open_file.dart';
import 'src/open_image_picker_pc.dart' if (dart.library.html) 'src/open_image_picker_web.dart';

class UImageFile {
  OFile _file;

  UImageFile(this._file);

  String get path => _file?.path;

  Future<ui.Image> readImage(BuildContext context, {int maxWidth, int maxHeight}) async {
    Uint8List memory = (await _file.byteBuffer).asUint8List();
    final ImageStream stream = MemoryImage(memory).resolve(createLocalImageConfiguration(context));
    var listener;
    var completer = Completer<ui.Image>();
    listener = ImageStreamListener((image, synchronousCall) {
      completer.complete(zoomImage(image.image, maxWidth?.toDouble(), maxHeight?.toDouble()));
      stream.removeListener(listener);
    }, onError: (exception, stackTrace) {
      stream.removeListener(listener);
      completer.completeError(exception);
    });
    stream.addListener(listener);

    return completer.future;
  }
}

Future<List<UImageFile>> openImage({
  bool allowsMultipleSelection = true,
  double maxWidth,
  double maxHeight,
  String accept,
}) async {
  if (accept?.isEmpty ?? true) {
    accept = "jpeg,png,gif,webp,bmp,wbmp";
  }
  if (kIsWeb) {
    if ('*' != accept) {
      accept = "image/${accept.replaceAll(",", ",image/")}";
    }
  }
  var files = await openFile(allowsMultipleSelection: allowsMultipleSelection, accept: accept);
  return files.map((e) {
    return UImageFile(e);
  }).toList();
}
