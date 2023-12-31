

import 'package:moyeolam/background_alarm/model/alarm.dart';
import 'package:moyeolam/background_alarm/service/file_handler.dart';

class AlarmFileHandler extends FileHandler<List<Alarm>> {
  static final AlarmFileHandler _instance = AlarmFileHandler._();

  factory AlarmFileHandler() => _instance;

  AlarmFileHandler._();

  @override
  String get fileName => 'alarms.txt';

  @override
  List<Alarm> parse(jsonObject) {
    return (jsonObject as List<dynamic>)
        .map((e) => Alarm.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
