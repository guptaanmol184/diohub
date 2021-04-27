import 'package:dio_hub/common/events/cards/base_card.dart';
import 'package:dio_hub/common/pulls/pull_list_card.dart';
import 'package:dio_hub/models/events/events_model.dart';
import 'package:flutter/material.dart';

class PullEventCard extends StatelessWidget {
  final EventsModel event;
  PullEventCard(this.event);
  @override
  Widget build(BuildContext context) {
    return BaseEventCard(
      actor: event.actor!.login,
      headerText: [
        TextSpan(text: ' ${event.payload.action} a pull request in '),
        TextSpan(
          text: event.repo!.name,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
      userLogin: event.actor!.login,
      date: event.createdAt,
      avatarUrl: event.actor!.avatarUrl,
      childPadding: EdgeInsets.zero,
      child: PullListCard(
        event.payload.pullRequest,
        disableMaterial: true,
        compact: true,
        padding: EdgeInsets.zero,
      ),
    );
  }
}
