import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DatePicker extends StatelessWidget {
  final TextEditingController dateInput;
  final DateTime dateTime;
  final Function onTap;

  const DatePicker({
    super.key,
    required this.dateInput,
    required this.dateTime,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.all(10),
        height: MediaQuery.of(context).size.width / 3,
        child: Center(
            child: TextField(
          controller: dateInput,
          decoration: InputDecoration(
              icon: const Icon(Icons.calendar_today),
              hintText: DateFormat('yyyy-MM-dd').format(dateTime),
              hintStyle: TextStyle(color: Theme.of(context).shadowColor),
              filled: true,
              fillColor: Theme.of(context).cardColor,
              enabledBorder: UnderlineInputBorder(
                  borderSide:
                      BorderSide(color: Theme.of(context).shadowColor))),
          readOnly: true,
          onTap: () async {
            DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: dateTime,
                firstDate: DateTime(1950),
                lastDate: DateTime(2100));

            if (pickedDate != null) {
              onTap(DateTime(
                  pickedDate.year,
                  pickedDate.month,
                  pickedDate.day,
                  DateTime.now().hour,
                  DateTime.now().minute,
                  DateTime.now().second,
                  DateTime.now().millisecond));
            }
          },
        )));
  }
}
