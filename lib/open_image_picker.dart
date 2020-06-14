library open_image;

import 'dart:core';
import 'dart:typed_data';
import 'package:flutter/widgets.dart';

import 'src/open_image_picker_pc.dart' if (dart.library.html) 'src/open_image_picker_web.dart' as picker;


abstract class UImageFile {
  Future<Uint8List> readAsBytes(BuildContext context);

  String get path;

  double get width;

  double get height;
}

Future<List<UImageFile>> openImage({
  bool allowsMultipleSelection = true,
  double width,
  double height,
}) {
  return picker.openImage(
    allowsMultipleSelection: allowsMultipleSelection,
    width: width,
    height: height,
  );
}
