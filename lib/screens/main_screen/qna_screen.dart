import 'package:english_word_app/api/supabase_api.dart';
import 'package:english_word_app/components/dialog/common_dialog.dart';
import 'package:english_word_app/provider/qna_provider.dart';
import 'package:english_word_app/provider/session.dart';
import 'package:english_word_app/screens/main_screen/qna_answer_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../components/common/common_text.dart';
import '../../consts/colors.dart';
import '../../models/qna.dart';

class QnAScreen extends ConsumerStatefulWidget {
  const QnAScreen({super.key});

  @override
  ConsumerState<QnAScreen> createState() => _QnAScreenState();
}

class _QnAScreenState extends ConsumerState<QnAScreen> {
  final ScrollController _controller = ScrollController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notifier = ref.read(qnaProvider.notifier);
      notifier.truncateState();
      notifier.initProvider();
    });

    _controller.addListener(() {
      final notifier = ref.read(qnaProvider.notifier);
      if (_controller.position.pixels >=
              _controller.position.maxScrollExtent - 10 &&
          notifier.isLoadCompleted()) {
        notifier.getNextQnAPage();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final qnas = ref.watch(qnaProvider);
    final qnasNotifier = ref.watch(qnaProvider.notifier);
    final userInfo = ref.watch(userSessionTokenProvider);

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          Map<String, String>? question = await CommonDialog.getQnADialog(
            context,
          );
          if (question == null)
            return;
          else {
            SupabaseAPI client = SupabaseAPI.getInstance();
            await client.registerQnA(question, userInfo.id);
            qnasNotifier.appendQnAInLocal(question);
          }
        },
        backgroundColor: MainColors.PrimaryColorDisable,
        shape: CircleBorder(),
        child: Icon(Icons.add, color: MainColors.MainWhite, size: 40),
      ),
      appBar: AppBar(
        elevation: 0, // 👈 Prevent shadow on scroll
        surfaceTintColor:
            Colors.transparent, // 👈 For Material 3 — prevents dynamic tinting
        backgroundColor: MainColors.MainWhite,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            padding: EdgeInsets.only(left: 30),
            child: Icon(
              Icons.arrow_back_ios_sharp,
              color: MainColors.MainBlack,
            ),
          ),
        ),
        title: CommonText(
          text: "1:1 문의하기",
          style: TextStyle(
            color: MainColors.MainBlack,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(color: MainColors.MainWhite),
        child: ListView.separated(
          controller: _controller,
          itemBuilder: (context, index) {
            return QnAWidget(qna: qnas.qnas[index]);
          },
          separatorBuilder:
              (context, index) => Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: MainColors.MainGray),
                  ),
                ),
              ),
          itemCount: qnas.qnas.length,
        ),
      ),
    );
  }
}

class QnAWidget extends StatelessWidget {
  QnA qna;

  QnAWidget({super.key, required this.qna});

  @override
  Widget build(BuildContext context) {
    String question = qna.question;
    if (question.length > 50) question.substring(0, 50);

    return Material(
      child: Ink(
        decoration: BoxDecoration(color: MainColors.MainWhite),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => QnaAnswerScreen(qna: qna),
                fullscreenDialog: true,
              ),
            );
          },
          child: Container(
            padding: EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                CommonText(
                  text: qna.date,
                  style: TextStyle(fontSize: 12, color: MainColors.MainGray),
                ),
                SizedBox(height: 5),
                Container(
                  height: 70,
                  child: CommonText(
                    text: question,
                    style: TextStyle(fontSize: 12, color: MainColors.MainBlack),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
