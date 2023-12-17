import 'package:date_format/date_format.dart';

class TimeUtils {
  static String formatDateTime(int timestamp) {
    var date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    return formatDate(date, [yyyy,'年',mm,'月',dd,'日 ',HH,':',nn,':', ss]);
  }
}