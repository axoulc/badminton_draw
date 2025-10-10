import 'dart:typed_data';

/// Stub implementation - should never be called
Future<void> saveFile({
  required Uint8List bytes,
  required String filename,
}) async {
  throw UnimplementedError('File download not implemented for this platform');
}
