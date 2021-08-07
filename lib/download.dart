import 'dart:convert';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html';
import 'dart:typed_data';

void download(Uint8List bytes) {
  // Encode our file in base64
  final _base64 = base64Encode(bytes);
  // Create the link with the file
  final anchor =
      AnchorElement(href: 'data:application/octet-stream;base64,$_base64')
        ..target = 'blank';
  // add the name
  anchor.download = 'download.png';

  // trigger download
  document.body!.append(anchor);
  anchor.click();
  anchor.remove();
  return;
}
