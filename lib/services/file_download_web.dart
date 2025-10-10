import 'dart:html' as html;
import 'dart:typed_data';

/// Web implementation using dart:html
Future<void> saveFile({
  required Uint8List bytes,
  required String filename,
}) async {
  final blob = html.Blob([bytes]);
  final url = html.Url.createObjectUrlFromBlob(blob);
  // ignore: unused_local_variable
  final anchor = html.AnchorElement(href: url)
    ..setAttribute('download', filename)
    ..click();
  html.Url.revokeObjectUrl(url);
}
