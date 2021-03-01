import 'dart:async';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_countdown_timer/countdown_timer_controller.dart';
import 'package:flutter_countdown_timer/current_remaining_time.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
import 'package:line_icons/line_icons.dart';
import 'package:onehub/app/Dio/response_handler.dart';
import 'package:onehub/blocs/authentication_bloc/authentication_bloc.dart';
import 'package:onehub/common/bottom_sheet.dart';
import 'package:onehub/models/authentication/device_code_model.dart';
import 'package:onehub/models/popup/popup_type.dart';
import 'package:onehub/style/colors.dart';
import 'package:url_launcher/url_launcher.dart';

class CodeInfoBox extends StatefulWidget {
  final DeviceCodeModel deviceCodeModel;
  CodeInfoBox(this.deviceCodeModel);
  @override
  _CodeInfoBoxState createState() => _CodeInfoBoxState();
}

class _CodeInfoBoxState extends State<CodeInfoBox> {
  CountdownTimerController timerController;
  bool copied = false;

  @override
  void initState() {
    timerController = CountdownTimerController(
      endTime: widget.deviceCodeModel.expiresIn,
      onEnd: () {
        BlocProvider.of<AuthenticationBloc>(context).add(ResetStates());
      },
    );
    super.initState();
  }

  @override
  void dispose() {
    timerController.dispose();
    super.dispose();
  }

  void copyCode({bool pop = false}) async {
    Clipboard.setData(ClipboardData(text: widget.deviceCodeModel.userCode));
    if (pop) {
      Navigator.pop(context);
    } else {
      await Future.delayed(Duration(milliseconds: 250));
    }
    ResponseHandler.setSuccessMessage(
        AppPopupData(title: 'Copied Code ${widget.deviceCodeModel.userCode}'));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: CountdownTimer(
            controller: timerController,
            endWidget: Text('Time Expired.'),
            widgetBuilder: (_, CurrentRemainingTime time) {
              return Column(
                children: [
                  Text(
                      'Expires in ${time.min ?? '00'}:${time.sec < 10 ? '0' : ''}${time.sec}'),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: LinearProgressIndicator(
                      backgroundColor: AppColor.grey,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColor.grey3),
                      value: ((time.min ?? 0) * 60 + time.sec) /
                          ((widget.deviceCodeModel.expiresIn -
                                  widget.deviceCodeModel.parsedOn) /
                              1000),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        SizedBox(
          height: 8,
        ),
        Center(
          child: Material(
            elevation: 2,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            color: AppColor.onBackground,
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () async {
                copyCode();
                setState(() {
                  copied = true;
                });
                await Future.delayed(Duration(seconds: 4));
                setState(() {
                  copied = false;
                });
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: DottedBorder(
                  radius: Radius.circular(5),
                  color: Colors.white,
                  dashPattern: [8],
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Text(
                          widget.deviceCodeModel.userCode,
                          style: Theme.of(context)
                              .textTheme
                              .headline5
                              .copyWith(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Visibility(
                              visible: !copied,
                              child: Icon(
                                Icons.copy,
                                color: Colors.grey,
                                size: 13,
                              ),
                              replacement: Icon(
                                Icons.check,
                                color: Colors.grey,
                                size: 13,
                              ),
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Visibility(
                              visible: !copied,
                              child: Text(
                                'TAP TO COPY',
                                style: TextStyle(
                                    fontSize: 13, fontWeight: FontWeight.w400),
                              ),
                              replacement: Text(
                                'COPIED',
                                style: TextStyle(
                                    fontSize: 13, fontWeight: FontWeight.w400),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        SizedBox(
          height: 16,
        ),
        Center(
          child: Text(
            'Input the code on the following link.',
            style: Theme.of(context).textTheme.bodyText1,
          ),
        ),
        SizedBox(
          height: 8,
        ),
        Flexible(
          child: Material(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            color: AppColor.onBackground,
            elevation: 2,
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.deviceCodeModel.verificationUri,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: Colors.blue,
                          decoration: TextDecoration.underline),
                    ),
                  ],
                ),
              ),
              onTap: () {
                showBottomActionsMenu(context,
                    headerText: widget.deviceCodeModel.verificationUri,
                    childWidget: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ListTile(
                        onTap: () {
                          canLaunch(widget.deviceCodeModel.verificationUri)
                              .then((value) {
                            Navigator.pop(context);
                            if (value) {
                              launch(widget.deviceCodeModel.verificationUri);
                            } else {
                              ResponseHandler.setErrorMessage(
                                  AppPopupData(title: 'Invalid URL'));
                            }
                          });
                        },
                        title: Text("Open"),
                        trailing: Icon(
                          LineIcons.link,
                          color: Colors.white,
                        ),
                      ),
                    ));
              },
            ),
          ),
        ),
        SizedBox(
          height: 16,
        ),
        Center(
          child: MaterialButton(
            child: Text(
              'Tap here to cancel',
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () {
              BlocProvider.of<AuthenticationBloc>(context).add(ResetStates());
            },
          ),
        ),
      ],
    );
  }
}
