import 'package:intl/intl.dart';

class DateTimeUtils {
  static String formatDate(DateTime dateTime) {
    return DateFormat('d MMMM yyyy').format(dateTime);
  }

  static String formatTime(DateTime dateTime) {
    return DateFormat('hh:mm a').format(dateTime);
  }
}
