library open_image;

import 'dart:core';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/widgets.dart';

import 'src/open_image_picker_pc.dart'if (dart.library.html) 'src/open_image_picker_web.dart' as picker;
import 'src/open_image_picker_phone.dart' as phone;

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
  if(Platform.isAndroid || Platform.isIOS){
    return phone.openImage(
      allowsMultipleSelection: allowsMultipleSelection,
      width: width,
      height: height,
    );
  }
  return picker.openImage(
    allowsMultipleSelection: allowsMultipleSelection,
    width: width,
    height: height,
  );
}
