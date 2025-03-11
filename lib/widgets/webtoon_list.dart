import 'package:flutter/material.dart';
import 'package:toonflix/models/webtoon_models.dart';
import './webtoon_item.dart';

class WebtoonList extends StatefulWidget {
  final dataSnapshot;

  const WebtoonList({super.key, required this.dataSnapshot});

  @override
  State<WebtoonList> createState() => _WebtoonListState();
}

/*
예제 데이터
  4(0)). {
    "id": "835736",
    "title": "중증외상센터 : 외과의사 백강혁",
    "thumb": "https://image-comic.pstatic.net/webtoon/835736/thumbnail/thumbnail_IMAG21_91f8c0be-dcab-47f2-a198-afeb0746e06e.jpg"
  },
  3(1)). {
    "id": "835531",
    "title": "최애캐의 고민상담소",
    "thumb": "https://image-comic.pstatic.net/webtoon/835531/thumbnail/thumbnail_IMAG21_aaf2c172-81d3-43cb-9675-b38d4f4430cb.jpg"
  },
  2(2)). {
    "id": "833255",
    "title": "낢이 사는 이야기 - 계속되는 미미한 인생",
    "thumb": "https://image-comic.pstatic.net/webtoon/833255/thumbnail/thumbnail_IMAG21_504f6152-8a60-42a0-a1c0-43cd77f9c430.jpg"
  },
  1(3)). {
    "id": "817247",
    "title": "못 잡아먹어서 안달",
    "thumb": "https://image-comic.pstatic.net/webtoon/817247/thumbnail/thumbnail_IMAG21_61bd3fbe-b16f-494a-b374-e7a68e5ca607.jpg"
  },
  
  0(4)). {
    "id": "822556",
    "title": "유부 감자",
    "thumb": "https://image-comic.pstatic.net/webtoon/822556/thumbnail/thumbnail_IMAG21_46b37b9f-0a73-43e0-982a-1cf5666397c7.jpg"
  },
  // 그려지는 순서 0 -> 1 -> 2 -> 3 -> 4
*/

class _WebtoonListState extends State<WebtoonList> {
  late List<WebtoonModel> webtoons;
  List<WebtoonItem> items =
      List<WebtoonItem>.empty(growable: true); // Item Widget
  List<GlobalKey<WebtoonItemState>> itemKeys =
      List<GlobalKey<WebtoonItemState>>.empty(growable: true); // Widget 키
  late GlobalKey<WebtoonItemState> frontItemKey; // 현재 가장 앞에 있는 웹툰 아이템,

  static const WAIT_WEBTOON = 4; // 4개 웹툰 대기 및 1개 웹툰 전방, 총 합해서 5개 웹툰을 보여줌.

  static const double SwipeSensevity = 0.05;
  static const double SwapFrontRange = 70;
  double accumDeltaDx = 0;

  int startIdx = WAIT_WEBTOON;
  int lastIdx = 0;
  int cursorIdx = 0;
  // 전체 데이터 셋에서 보여줄 범위

  int front = 1;

  late Offset touchPivot;
  /*
    값이 바뀌는건 model 뿐, 위젯이 달라지지 않는다.
    webtoonsItem : 0 1 2 3 4
    items Order : 4 3 2 1 0


    Widget 변경은 없음, 모델만 바뀜
    Idx     Key
    5       (1) : FrontWebtoonItem, 현재 가장 앞에 있는 웹툰 키 인덱스
    1       (4) : Insert New Webtoon Item, 새로운 웹툰을 삽입할 키 인덱스

    0       (6) : SkipWebtoonItem, 뒤로 넘어간 웹툰 키 인덱스
    6       (0) : Animation을 위한 Dummy 객체, 왼쪽으로 Swipe할 때 front웹툰을 덮어씌우는 효과를 위함.

               0 ---> 가장 앞에 있음 (key = 0가 맨 앞 아이템)
    -1 4 3 2 1 0  --- Item order --- Translate 시킬 순서 좌표 
       |insert |front
    0  1 2 3 4 5  6  --- List Idx  --- model을 참조하기 위함
    6  5 4 3 2 1  0  --- key 순서  --- Widget을 참조하기 위함
    X| 5 4 3 2 1 |A  --- WebtoonItemList index --- 그려지는 순서
    0| 6 5 4 3 2 |A
    1| 7 6 5 4 3 |A
    2| 8 7 6 5 4 |A
          ...
    N-1| ... N ...

  */
  @override
  void initState() {
    super.initState();

    webtoons = widget.dataSnapshot.data;
    // Get으로 가져온 WebtoonData

    for (int i = 0; i < 7; i++) itemKeys.add(GlobalKey<WebtoonItemState>());

    items.add(WebtoonItem(
      key: itemKeys[6],
      webtoonItemKey: itemKeys[6],
      isFavorite: false,
      order: -1,
      model: null,
    ));
    // 첫 skipWebtoon 객체, 더미데이터. : 6

    for (int idx = startIdx; idx >= lastIdx; idx--) {
      items.add(WebtoonItem(
        key: itemKeys[idx + 1],
        webtoonItemKey: itemKeys[idx + 1],
        isFavorite: false,
        order: idx,
        model: webtoons[idx],
      ));
    }

    // 첫 5개의 아이템을 만들어 낸다, Key는 역순으로 삽입된다. : 5, 4, 3, 2, 1

    items.add(WebtoonItem(
      key: itemKeys[0],
      webtoonItemKey: itemKeys[0],
      isFavorite: false,
      order: -1,
      model: null,
    ));
    // Animation을 위한 Dummy 객체, 왼쪽으로 Swipe할 때 front웹툰을 덮어씌우는 효과를 위함. Key : 0

    frontItemKey = itemKeys[front];
    WidgetsBinding.instance.addPostFrameCallback((_) {
      frontItemKey.currentState!.setFront(true, front);
    });
    // 첫 가장 앞에 있는 Key 설정, 가장 앞에 있는 Key 아이템은 0번째 아이템이다.
  }

  void _initWidget() {
    for (int i = 0; i < 7; i++) itemKeys[i].currentState!.swipeFrontEnd();
    items[6].model = null;
    // 최종 변경사항 업데이트
  }

  void getNextWebtoon() {
    setState(() {
      if (cursorIdx < webtoons.length - 1) {
        cursorIdx++;

        items[front - 1].model = items[5].model;
        // Front Webtoon을 Skip Webtoon에 삽입, SkipWebtoon Widget의 index는 0

        for (int i = 4; i > 0; i--) items[i + 1].model = items[i].model;
        // 로테이팅 후,

        if (startIdx < webtoons.length - 1) {
          startIdx++;
          items[1].model = webtoons[startIdx];
          lastIdx++;
        } else
          items[1].model = null;
        // 범위 시작 인덱스가 데이터 스트림 범위를 벗어나지 않을 때, 범위 이동
        // startIdx가 범위에 끝에 도달했을 때, null 삽입
      }
      _initWidget();
    });
  }

/*
       |insert |front
    0  1 2 3 4 5  6  --- List Idx  --- model을 참조하기 위함
    6  5 4 3 2 1  0  --- key 순서  --- Widget을 참조하기 위함
    2| 8 7 6 5 4 |A
    1| 7 6 5 4 3 |A
    0| 6 5 4 3 2 |A
    X| 5 4 3 2 1 |A  --- WebtoonItemList index --- 그려지는 순서


    lastIdx = 39

*/
  void getPrevWebtoon() {
    setState(() {
      items[0].model = items[6].model;
      // Skip Webtoon을 복원한다. (null이 로테이션에서 말려들어감을 방지)

      if (cursorIdx > 0) {
        cursorIdx--;
        for (int i = 2; i <= 5; i++) items[i - 1].model = items[i].model;
        items[5].model = items[front - 1].model;
        // 로테이팅 코드

        // 커서 인덱스가 마지막 범위에 포함되어 있을 경우의 처리
        // ex) 43 <= n <= 39
        if (cursorIdx >= lastIdx) {
          items[front - 1].model = webtoons[cursorIdx - 1];
          _initWidget();
          return;
        }

        // 커서 인덱스가 마지막 범위에 포함되어 있지 않을 경우
        startIdx--;
        lastIdx--;
        if (lastIdx > 0)
          items[front - 1].model = webtoons[lastIdx - 1];
        else
          items[front - 1].model = null;
      }
      _initWidget();
    });
  }

  void swipe(DragUpdateDetails update) {
    setState(() {
      accumDeltaDx += update.delta.dx;

      for (int i = 1; i < 6; i++) {
        itemKeys[i]
            .currentState!
            .setBackOffset(update.delta.dx * SwipeSensevity);
      }

      frontItemKey.currentState!.setFrontOffset(
          update.delta.dx * 0.9, touchPivot, update.localPosition);

      itemKeys[2].currentState!.setBackScale(touchPivot, update.localPosition);
      // frontWebtoon과 BackWebtoon의 Transform을 변경하고

      if (items[0].model != null) {
        // 오른쪽 스와이프 방향일 경우 Animation을 숨김
        if (accumDeltaDx >= 0) {
          items[6].model = null;
        }
        // 왼쪽 스와이프 방향일 경우 Animation을 앞으로
        else {
          items[6].model = items[0].model;
          items[0].model = null;
          itemKeys[6].currentState!.swapModel();
        }
      }
      // 0(SkipWebtoon) 6(Animation)을 swap
      itemKeys[0]
          .currentState!
          .setSkipOffset(touchPivot, update.localPosition, update.delta.dx);
      //
    });
  }

  void swipeEnd(DragEndDetails details) {
    if (accumDeltaDx > SwapFrontRange)
      getNextWebtoon();
    else if (accumDeltaDx < -SwapFrontRange)
      getPrevWebtoon();
    else {
      if (items[6].model != null) items[0].model = items[6].model;
      items[6].model = null;
      // 오른쪽 Swipe가 취소될 경우, SkipWebtoon을 복구한다.
      _initWidget();
    }
    // print("lastIdx $lastIdx");
    // print("startIdx $startIdx");
    // print("cursorIdx $cursorIdx");
    // for debug
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragStart: (details) {
        accumDeltaDx = 0;
        touchPivot = details.localPosition;
      },
      onHorizontalDragUpdate: swipe,
      onHorizontalDragEnd: swipeEnd,
      child: Container(
        width: double.infinity,
        child: Stack(
          children: items,
        ),
      ),
    );
  }
}
