import 'package:dio_hub/common/loading_indicator.dart';
import 'package:dio_hub/controller/button/button_controller.dart';
import 'package:dio_hub/style/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Button extends StatefulWidget {
  final bool listenToLoadingController;
  final Function? onTap;
  final Color? color;
  final bool enabled;
  final Widget child;
  final Icon? leadingIcon;
  final double borderRadius;
  final Widget? loadingWidget;
  final bool stretch;
  final bool loading;
  final double elevation;
  final EdgeInsets padding;
  Button({
    this.listenToLoadingController = true,
    required this.onTap,
    required this.child,
    this.enabled = true,
    this.stretch = true,
    this.color,
    this.loading = false,
    this.padding = const EdgeInsets.all(16),
    this.elevation = 2,
    this.borderRadius = 10,
    this.leadingIcon,
    this.loadingWidget,
  });

  @override
  _ButtonState createState() => _ButtonState();
}

class _ButtonState extends State<Button> {
  bool loading = false;
  @override
  void initState() {
    if (widget.listenToLoadingController) {
      ButtonController.buttonStream.listen((onData) {
        if (mounted) {
          setState(() {
            if (onData != null) {
              loading = onData;
            } else {
              loading = false;
            }
          });
        }
      });
    } else
      loading = widget.loading;
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      disabledColor: (widget.color ?? AppColor.accent).withOpacity(0.7),
      elevation: widget.elevation,
      padding: widget.padding,
      disabledTextColor: Colors.white,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(widget.borderRadius)),
      onPressed:
          widget.enabled && !loading ? widget.onTap as void Function()? : null,
      color: widget.color ?? AppColor.accent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          !loading
              ? Row(
                  mainAxisSize:
                      widget.stretch ? MainAxisSize.max : MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Visibility(
                        visible: widget.leadingIcon != null,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 16.0),
                          child: widget.leadingIcon ?? Container(),
                        )),
                    Flexible(child: widget.child),
                  ],
                )
              : Row(
                  mainAxisSize:
                      widget.stretch ? MainAxisSize.max : MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Visibility(
                        visible: widget.loadingWidget != null,
                        child: widget.loadingWidget ?? Container()),
                    LoadingIndicator(),
                  ],
                ),
        ],
      ),
    );
  }
}

class StringButton extends StatelessWidget {
  final bool listenToLoadingController;
  final Function? onTap;
  final Color? color;
  final bool enabled;
  final double? textSize;
  final String? title;
  final String? subtitle;
  final Icon? leadingIcon;
  final double borderRadius;
  final String? loadingText;
  final bool stretch;
  final double elevation;
  final EdgeInsets padding;

  StringButton({
    this.listenToLoadingController = true,
    required this.onTap,
    required this.title,
    this.enabled = true,
    this.stretch = true,
    this.color,
    this.subtitle,
    this.elevation = 2,
    this.borderRadius = 10,
    this.textSize,
    this.leadingIcon,
    this.padding = const EdgeInsets.all(16),
    this.loadingText,
  });
  @override
  Widget build(BuildContext context) {
    return Button(
      onTap: onTap,
      child: Column(
        children: [
          Text(
            title!,
            style: Theme.of(context)
                .textTheme
                .button!
                .copyWith(fontSize: textSize),
          ),
          Visibility(
              visible: subtitle != null,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(subtitle ?? ''),
              )),
        ],
      ),
      loadingWidget: Text(loadingText ?? '',
          style:
              Theme.of(context).textTheme.button!.copyWith(fontSize: textSize)),
      color: color,
      borderRadius: borderRadius,
      leadingIcon: leadingIcon,
      enabled: enabled,
      elevation: elevation,
      stretch: stretch,
      listenToLoadingController: listenToLoadingController,
    );
  }
}
