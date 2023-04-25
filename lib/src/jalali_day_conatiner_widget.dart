import 'package:flutter/material.dart';
import 'package:jalali_table_calendar/jalali_table_calendar.dart';
import 'package:persian_number_utility/persian_number_utility.dart';
import 'package:simple_tooltip/simple_tooltip.dart';

class JalaliDayContainerWidget extends StatelessWidget {
  const JalaliDayContainerWidget({
    Key? key,
    required this.localizations,
    required this.marker,
    required this.events,
    required this.day,
    required this.dayToBuild,
    this.disabled = false,
    this.isHoliday = false,
    this.isSelectedDay = false,
    required this.onChanged,
  }) : super(key: key);
  final MarkerBuilder? marker;
  final MaterialLocalizations localizations;
  final int day;
  final DateTime dayToBuild;
  final Map<DateTime, List>? events;
  final bool isSelectedDay;
  final bool disabled;
  final bool isHoliday;
  final ValueChanged<DateTime> onChanged;

  @override
  Widget build(BuildContext context) {
    return _widget();
  }

  /// This method returns a widget based on the state of the calendar day.
  Widget _widget() {
    if (disabled) {
      return _disabledDayContainer();
    } else if (isHoliday) {
    } else if (marker != null &&
        events != null &&
        events![dayToBuild] != null) {
      return _eventDayContainer();
    } else if (isSelectedDay) {
      return _selectDayContainer();
    }

    return _activeContainer();
  }

  Widget _activeContainer() {
    return _containerBase(
      day.toString(),
      color: Colors.black26,
      text: Colors.black26,
    );
  }

  Widget _selectDayContainer() {
    return _containerBase(
      day.toString(),
      color: Colors.blue,
      text: Colors.white,
      background: Colors.blue,
    );
  }

  Widget _eventDayContainer() {
    late Color color;
    final bool isFull = _calculateDailyHours(events![dayToBuild]!) >= 8;
    if (isFull) {
      color = Colors.red;
    } else {
      color = Colors.orange;
    }
    // return _containerBase(
    //   day.toString(),
    //   color: color,
    //   text: Colors.white,
    //   background: color,
    // );
    return SimpleTooltip(
      // radius: 15,
      // text: 'تاریخ های رزرو',
      backgroundColor: color,
      borderColor: color,
      borderRadius: 16,
      ballonPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
      // maxHeight: 150,
      child: _containerBase(
        day.toString(),
        color: color,
        text: Colors.white,
        background: color,
      ),
      tooltipTap: () => onChanged(dayToBuild),
      // show: isSelectedDay,
      content: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          ...events![dayToBuild]?.map((e) {
                DateTime start = DateTime.parse(e["start_datetime"]!);
                DateTime end = DateTime.parse(e["end_datetime"]!);

                return Text(
                  "${start.hour} تا ${end.hour}",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                );
              }).toList() ??
              [],
          // if (!isFull)
          //   MaterialButton(
          //     child: Container(
          //       padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          //       decoration: BoxDecoration(
          //         borderRadius: BorderRadius.circular(5),
          //         color: Colors.red,
          //       ),
          //       child: Text(
          //         "انتخاب تاریخ",
          //         style: TextStyle(fontSize: 16, color: Colors.white),
          //       ),
          //     ),
          //     onPressed: () => ,
          //   )
        ],
      ),
      show: isSelectedDay,
    );
  }

  Widget _disabledDayContainer() {
    return _containerBase(
      day.toString(),
      color: Colors.grey.shade100,
      text: Colors.grey.shade300,
      background: Colors.grey.shade100,
    );
  }

  ///This method returns a Container widget with customizable properties such as value, color, text, and background.
  Widget _containerBase(
    String value, {
    required Color color,
    required Color text,
    Color background = Colors.white,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 3, horizontal: 5),
      decoration: BoxDecoration(
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(8),
        color: background,
        boxShadow: background == Colors.white
            ? null
            : [
                BoxShadow(
                  color: background.withOpacity(0.2),
                  spreadRadius: 2,
                  blurRadius: 2,
                  offset: Offset(0, 0), // changes position of shadow
                ),
              ],
      ),
      child: Center(
        child: Text(
          value.toPersianDigit(),
          style: TextStyle(color: text),
        ),
      ),
    );
  }

  int _calculateDailyHours(List events) {
    Map<String, int> hoursPerDay = {};

    events.forEach((event) {
      DateTime start = DateTime.parse(event["start_datetime"]!);
      DateTime end = DateTime.parse(event["end_datetime"]!);

      if (start.day != end.day) {
        // Event starts on one day and ends on the next day, skip it
        return;
      }

      String date = "${start.year}-${start.month}-${start.day}";

      int duration = end.difference(start).inHours;

      if (!hoursPerDay.containsKey(date)) {
        hoursPerDay[date] = 0;
      }

      hoursPerDay[date] = hoursPerDay[date]! + duration;
    });

    return hoursPerDay.values.first;
  }
}
