import 'package:english_word_app/models/word.dart';
import 'package:english_word_app/provider/today_word_condition.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../components/common/common_text.dart';
import '../../consts/colors.dart';

class ListItem extends StatefulWidget {
  int index;
  WidgetRef ref;

  ListItem({super.key, required this.index, required this.ref});

  @override
  State<ListItem> createState() => _ListItemState();
}

class _ListItemState extends State<ListItem> {
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

  CommonText getItemContext(dynamic item, TodayWordCondition conditions) {
    switch (conditions.selectedEduProcess) {
      case "워크북 과정":
      case "기본 과정":
        if (item is String) return CommonText(text: item);

      case "단어 선택하기":
        if (item is Word) return CommonText(text: item.word);
    }

    return CommonText(text: "");
  }

  @override
  Widget build(BuildContext context) {
    final conditions = widget.ref.watch(todayWordConditionProvider);
    final notifier = widget.ref.read(todayWordConditionProvider.notifier);
    final item = conditions.listValues[widget.index];

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
        title: getItemContext(item, conditions),
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
