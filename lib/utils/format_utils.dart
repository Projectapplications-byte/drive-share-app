import 'package:intl/intl.dart';

class FormatUtils {
  static final DateFormat _dateFormat = DateFormat('dd MMM yyyy, hh:mm a');

  static String fileSize(int bytes) {
    if (bytes <= 0) return 'Unknown size';
    const units = <String>['B', 'KB', 'MB', 'GB', 'TB'];
    var size = bytes.toDouble();
    var unitIndex = 0;
    while (size >= 1024 && unitIndex < units.length - 1) {
      size /= 1024;
      unitIndex++;
    }
    return '${NumberFormat('#,##0.#').format(size)} ${units[unitIndex]}';
  }

  static String dateTimeFromMillis(int millis) {
    if (millis <= 0) return 'Unknown date';
    return _dateFormat.format(DateTime.fromMillisecondsSinceEpoch(millis));
  }

  static String dateTime(DateTime? value) {
    if (value == null) return 'Unknown date';
    return _dateFormat.format(value.toLocal());
  }
}
