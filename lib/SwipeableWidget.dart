import 'package:flutter/material.dart';

/// A Widget that have the ability to detect swipe on itself
/// with customizable variables.
class SwipeableWidget extends StatefulWidget {
  /// The `Widget` on which we want to detect the swipe movement.
  final Widget child;

  /// The Height of the widget that will be drawn, required.
  final double height;

  /// The `VoidCallback` that will be called once a swipe with certain percentage is detected.
  final VoidCallback onSwipeCallback;

  /// The decimal percentage of swiping in order for the callbacks to get called, defaults to 0.75 (75%) of the total width of the children.
  final double swipePercentageNeeded;

  SwipeableWidget(
      {Key key,
      @required this.child,
      @required this.height,
      @required this.onSwipeCallback,
      this.swipePercentageNeeded = 0.75})
      : assert(child != null &&
            onSwipeCallback != null &&
            swipePercentageNeeded <= 1.0),
        super(key: key);

  @override
  _SwipeableWidgetState createState() => _SwipeableWidgetState();
}

class _SwipeableWidgetState extends State<SwipeableWidget>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;

  var _dxStartPosition = 0.0;
  var _dxEndsPosition = 0.0;

  var value = 1.0;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300))
      ..addListener(() {
        print(_controller.value);
        value =1.0- _controller.value;
        setState(() {});
      });

    _controller.value = 0.0;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onPanStart: (details) {
          setState(() {
            // _dxStartPosition = details.localPosition.dx;
            _dxEndsPosition = details.localPosition.dx;
            print(" end pos --->$_dxEndsPosition");
          });
        },
        onPanUpdate: (details) {
          final widgetSize = context.size.width;

          final minimumXToStartSwiping = widgetSize * 0.55;
          if (_dxEndsPosition >= minimumXToStartSwiping) {
            setState(() {
              //  _dxEndsPosition = details.localPosition.dx;
              _dxEndsPosition = details.localPosition.dx;
            });

            final widgetSize = context.size.width;
            _controller.value = 1 - ((details.localPosition.dx) / widgetSize);
          }
        },
        onPanEnd: (details) async {
          // checks if the right swipe that user has done is enough or not
          //  final delta = _dxEndsPosition - _dxStartPosition;
          final delta = _dxStartPosition - _dxEndsPosition;
          final widgetSize = context.size.width;
          final deltaNeededToBeSwiped =
              widgetSize * widget.swipePercentageNeeded;
          if (delta > deltaNeededToBeSwiped) {
            // if it's enough, then animate to hide them
            _controller.animateTo(0.0,
                duration: Duration(milliseconds: 300),
                curve: Curves.fastOutSlowIn);
            widget.onSwipeCallback();
          } else {
            // if it's not enough, then animate it back to its full width
            _controller.animateTo(1.0,
                duration: Duration(milliseconds: 300),
                curve: Curves.fastOutSlowIn);
          }
        },
        child: Container(
            height: widget.height,
            child: Container(
              height: widget.height,
              child: Align(
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: value, // _controller.value,
                  heightFactor: 1.0,
                  child: widget.child,
                ),
              ),
            )));
  }
}

/// A Button that can detect swiping movement with shimmering arrows on far end.
class SwipingButton extends StatelessWidget {
  /// The text that the button will display.
  final String text;

  /// The callback invoked when the button is swiped.
  final VoidCallback onSwipeCallback;

  SwipingButton({
    Key key,
    @required this.text,
    @required this.onSwipeCallback,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
      child: Stack(
        children: <Widget>[
          Container(
            height: 80.0,
            decoration: BoxDecoration(
                color: Colors.greenAccent,
                borderRadius: BorderRadius.circular(4.0)),
          ),
          SwipeableWidget(
            height: 80.0,
            child: Container(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                child: _buildContent(),
              ),
              height: 80.0,
              decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(4.0)),
            ),
            onSwipeCallback: onSwipeCallback,
          ),
        ],
      ),
    );
  }

  Widget _buildText() {
    final textStyle = TextStyle(
        fontSize: 18.0, fontWeight: FontWeight.w500, color: Colors.white);
    return Flexible(
      flex: 2,
      child: Text(
        text.toUpperCase(),
        style: textStyle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildContent() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        _buildText(),
      ],
    );
  }
}
