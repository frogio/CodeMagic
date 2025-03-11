import 'package:flutter/material.dart';
import '../models/webtoon_models.dart';
import 'package:sprintf/sprintf.dart';
import '../screens//episode_screen.dart';

class WebtoonItem extends StatefulWidget {
  WebtoonModel? model;
  final GlobalKey<WebtoonItemState>? webtoonItemKey;
  final int order;
  bool isFavorite;

  WebtoonItem({
    super.key,
    required this.webtoonItemKey,
    required this.order,
    required this.model,
    required this.isFavorite,
  });

  @override
  State<WebtoonItem> createState() => WebtoonItemState();
}

class WebtoonItemState extends State<WebtoonItem> {
  final GlobalKey _imageKey = GlobalKey();
  late Image image;

  bool isFront = false;
  double _frontOffset = 0;
  double _frontScaleOffset = 1;
  double _backScaleOffset = 1;
  int curFrontIdx = 0;
  // 현재 List의 Front Index

  late int _order;
  double _backOffset = -30;
  double _skipOffset = 30;

  @override
  void initState() {
    super.initState();
    _order = widget.order;
  }

  void setFront(bool front, int idx) {
    setState(() {
      isFront = front;
      curFrontIdx = idx;
    });
  }

  void swipeFrontEnd() {
    setState(() {
      _frontOffset = 0;
      _backOffset = -30;
      _skipOffset = 30;
      _backScaleOffset = 1;
      _frontScaleOffset = 1;
    });
  }

  void swapModel() {
    setState(() {});
  }

  void setBackScale(Offset pivot, Offset swipePoint) {
    setState(() {
      if (pivot.dx - swipePoint.dx < 0)
        _backScaleOffset = 1 + (pivot.dx - swipePoint.dx).abs() * 0.0015;
      // 앞을 향한 스와이프
      else if (_backScaleOffset > 1 && pivot.dx - swipePoint.dx > 0)
        _backScaleOffset -= 0.0015;
      // 뒤를 향한 스와이프
    });
  }

  void setFrontOffset(double dx, Offset pivot, Offset swipePoint) {
    setState(() {
      if (dx > 0) _frontOffset += dx;
      _frontScaleOffset = 1 - (pivot.dx - swipePoint.dx).abs() * 0.001;
      // 피벗을 기준으로 터치포인트 간 유클리드 거리만큼 크기를 줄인다.
    });
  }

  void setBackOffset(double dx) {
    setState(() {
      _backOffset += dx;
    });
  }

  void setSkipOffset(Offset pivot, Offset swipePoint, double dx) {
    setState(() {
      if (pivot.dx - swipePoint.dx < 0)
        _backScaleOffset = 1 - (pivot.dx - swipePoint.dx).abs() * 0.0015;
      // 앞을 향한 스와이프
      else if (pivot.dx - swipePoint.dx > 0)
        _backScaleOffset = 1 + (pivot.dx - swipePoint.dx).abs() * 0.0015;
      // 뒤를 향한 스와이프
      _skipOffset -= dx;
    });
  }

  Widget FrontWebtooon(BuildContext context) {
    return Transform.scale(
      scale: _frontScaleOffset,
      child: Transform.translate(
        offset: Offset(_frontOffset, 0),
        child: GestureDetector(
          onTap: () {
            print("isWorking??");
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EpisodeScreen(model: widget.model!),
                  fullscreenDialog: true,
                ));
          },
          child: Container(
            child: LayoutBuilder(
              builder: (context, constraints) {
                double imageWidth = constraints.maxWidth * 0.6;
                double imageHeight = constraints.maxHeight * 0.5;

                return Stack(
                  children: [
                    Positioned(
                      left: (constraints.maxWidth - imageWidth) / 2,
                      top: (constraints.maxHeight - imageHeight) / 2,
                      child: Stack(children: [
                        Hero(
                          tag: widget.model!.id,
                          child: Image.network(
                            key: _imageKey,
                            widget.model!.thumb,
                            headers: {
                              "User-Agent":
                                  "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/110.0.0.0 Safari/537.36",
                            },
                            width: constraints.maxWidth * 0.6,
                            // height: constraints.maxHeight * 0.4,
                          ),
                        ),
                        Text(
                          "${sprintf("%.3f", [_frontOffset])}",
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.black,
                          ),
                        ),
                      ]),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget WaitWebtoon(BuildContext context) {
    return Transform.scale(
      scale: _backScaleOffset,
      child: Transform.translate(
        offset: Offset(_order * _backOffset, 0),
        child: Container(
          child: LayoutBuilder(
            builder: (context, constraints) {
              double imageWidth = constraints.maxWidth * 0.5;
              double imageHeight = constraints.maxHeight * 0.4;

              return Stack(
                children: [
                  Positioned(
                    left: (constraints.maxWidth - imageWidth) / 2,
                    top: (constraints.maxHeight - imageHeight) / 2,
                    child: Stack(children: [
                      Image.network(
                        key: _imageKey,
                        widget.model!.thumb,
                        headers: {
                          "User-Agent":
                              "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/110.0.0.0 Safari/537.36",
                        },
                        width: constraints.maxWidth * 0.5,
                        // height: constraints.maxHeight * 0.4,
                      ),
                      Text(
                        "${sprintf("%.3f", [_backOffset * _order])}",
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.black,
                        ),
                      ),
                    ]),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget SkipWebtoon(BuildContext context) {
    return Transform.scale(
      scale: _backScaleOffset,
      child: Transform.translate(
        offset: Offset(_order * _skipOffset + 220, 0),
        child: Container(
          child: LayoutBuilder(
            builder: (context, constraints) {
              double imageWidth = constraints.maxWidth * 0.5;
              double imageHeight = constraints.maxHeight * 0.4;

              return Stack(
                children: [
                  Positioned(
                    left: (constraints.maxWidth - imageWidth) / 2,
                    top: (constraints.maxHeight - imageHeight) / 2,
                    child: Stack(children: [
                      Image.network(
                        key: _imageKey,
                        widget.model!.thumb,
                        headers: {
                          "User-Agent":
                              "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/110.0.0.0 Safari/537.36",
                        },
                        width: constraints.maxWidth * 0.5,
                        // height: constraints.maxHeight * 0.4,
                      ),
                      Text(
                        "${sprintf("%.3f", [_skipOffset * _order])}",
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.black,
                        ),
                      ),
                    ]),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget BackWebtoon(BuildContext context) {
    return (_order == -1) ? SkipWebtoon(context) : WaitWebtoon(context);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.model != null)
      return isFront ? FrontWebtooon(context) : BackWebtoon(context);

    return Container();
  }
}
