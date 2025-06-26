import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DatePickerField extends StatefulWidget {
  TextEditingController controller;

  DatePickerField({super.key, required this.controller});

  @override
  State<DatePickerField> createState() => _DatePickerState();
}

class _DatePickerState extends State<DatePickerField> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      readOnly: true,
      onTap: () async {
        DateTime? picked = await showDatePicker(
          context: context,
          locale: const Locale('ko'),
          initialDate: DateTime.now(),
          firstDate: DateTime(1900),
          lastDate: DateTime(2101),
        );
        if (picked != null) {
          String formattedDate = DateFormat('yyMMdd').format(picked);

          setState(() {
            widget.controller.text = formattedDate;
          });
        }
      },
      decoration: InputDecoration(
        labelText: '생년월일',
        suffixIcon: Icon(Icons.calendar_today),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10), // 👈 Rounded edges
          borderSide: BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.blue, width: 2),
        ),
      ),
    );
  }
}
