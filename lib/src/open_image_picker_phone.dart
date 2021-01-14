import 'dart:async';
import 'dart:typed_data';
import 'dart:core';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import '../open_image_picker.dart';

class _ImageFile extends UImageFile {
  PickedFile _file;

  double _width;

  double _height;

  _ImageFile(this._file, this._width, this._height);

  @override
  String get path => _file.path;

  @override
  double get height => _height;

  @override
  double get width => _width;

  @override
  Future<Uint8List> readAsBytes(BuildContext context) {
    return _file.readAsBytes();
  }
}

Future<List<UImageFile>> openImage({
  bool allowsMultipleSelection = true,
  double width,
  double height,
}) async {
  var files = await ImagePicker().getImage(
    source: ImageSource.gallery,
    maxWidth: width,
    maxHeight: height,
  );
  if (null == files) {
    return [];
  }
  return [_ImageFile(files, width, height)];
}
