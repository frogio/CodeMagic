import 'package:english_word_app/models/word.dart';
import 'package:english_word_app/provider/mistake_note_provider.dart';
import 'package:english_word_app/provider/today_word_condition.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../components/common/common_text.dart';
import '../../consts/colors.dart';

class MistakeNoteItem extends StatefulWidget {
  int index;
  WidgetRef ref;

  MistakeNoteItem({super.key, required this.index, required this.ref});

  @override
  State<MistakeNoteItem> createState() => _MistakeNoteItemState();
}

class _MistakeNoteItemState extends State<MistakeNoteItem> {
  late BoxDecoration _selectedDeco;
  late BoxDecoration _noneSelectDeco;
  late TextStyle style;

  @override
  void initState() {
    super.initState();

    _selectedDeco = BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: MainColors.PrimaryColor, width: 1),
      color: MainColors.PrimaryColorLight,
    );

    _noneSelectDeco = BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: MainColors.BorderGray, width: 1),
      color: MainColors.LightGray,
    );

    style = TextStyle(fontSize: 15);
  }

  @override
  Widget build(BuildContext context) {
    final conditions = widget.ref.watch(mistakeNoteProvider);
    final notifier = widget.ref.read(mistakeNoteProvider.notifier);
    final item = conditions.wordList[widget.index];

    return Container(
      padding: EdgeInsets.all(10),
      decoration:
          notifier.isContain(widget.index) ? _selectedDeco : _noneSelectDeco,
      child: ListTile(
        leading: Icon(
          Icons.check_circle,
          size: 35,
          color:
              notifier.isContain(widget.index)
                  ? MainColors.PrimaryColor
                  : MainColors.BorderGray,
        ),
        title: CommonText(text: item.word),
        onTap: () {
          if (notifier.isContain(widget.index))
            notifier.removeIndex(widget.index);
          else
            notifier.appnedIndex(widget.index);
        },
      ),
    );
  }
}
