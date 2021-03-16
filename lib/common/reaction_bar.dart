import 'package:flutter/material.dart';
import 'package:flutter_reaction_button/flutter_reaction_button.dart';
import 'package:onehub/common/animations/size_expanded_widget.dart';
import 'package:onehub/common/bottom_sheet.dart';
import 'package:onehub/common/loading_indicator.dart';
import 'package:onehub/common/profile_banner.dart';
import 'package:onehub/common/shimmer_widget.dart';
import 'package:onehub/models/reactions/reactions_model.dart';
import 'package:onehub/models/users/user_info_model.dart';
import 'package:onehub/services/reactions/reactions_service.dart';
import 'package:onehub/style/borderRadiuses.dart';
import 'package:onehub/style/colors.dart';

class CommentReaction {
  final String reaction;
  int count = 0;
  bool reacted = false;
  List<UserInfoModel> users = [];
  int userReactionID;
  String get emoji => getReaction(reaction);
  CommentReaction({this.reaction});

  void addUserReaction(int id) {
    userReactionID = id;
    count++;
    reacted = true;
  }

  void removeReaction() {
    userReactionID = null;
    count--;
    reacted = false;
  }
}

String getReaction(String reaction) {
  switch (reaction) {
    case '+1':
      return '👍';
      break;
    case '-1':
      return '👎';
      break;
    case 'laugh':
      return '😄';
      break;
    case 'confused':
      return '😕';
      break;
    case 'heart':
      return '❤️';
      break;
    case 'hooray':
      return '🎉';
      break;
    case 'rocket':
      return '🚀';
      break;
    case 'eyes':
      return '👀';
      break;
    default:
      return null;
  }
}

class ReactionBar extends StatefulWidget {
  final String url;
  final String currentUser;
  final bool isEnabled;
  ReactionBar(this.url, this.currentUser, [this.isEnabled = true]);

  @override
  _ReactionBarState createState() => _ReactionBarState();
}

class _ReactionBarState extends State<ReactionBar> {
  bool loading = true;

  List<CommentReaction> reactions = [];
  void fetchData() async {
    await ReactionsService.getReactions(widget.url).then((value) {
      reactions = getReactionStats(value);
    });
    setState(() {
      loading = false;
    });
  }

  @override
  void initState() {
    fetchData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (loading)
      return Row(
        children: [
          if (widget.isEnabled)
            ShimmerWidget(
              highlightColor: Colors.grey.shade900,
              baseColor: AppColor.background,
              borderRadius: AppThemeBorderRadius.bigBorderRadius,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: IgnorePointer(
                  child: FlutterReactionButton(
                      splashColor: Colors.transparent,
                      boxPadding: EdgeInsets.all(16),
                      shouldChangeReaction: false,
                      boxColor: AppColor.background,
                      onReactionChanged: (reaction, index) {},
                      boxItemsSpacing: 24,
                      initialReaction: Reaction(
                        icon: Material(
                            color: AppColor.background,
                            borderRadius: AppThemeBorderRadius.bigBorderRadius,
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Container(
                                  height: 36,
                                  child: Center(child: Icon(Icons.add))),
                            )),
                      ),
                      reactions: []),
                ),
              ),
            ),
        ],
      );
    else
      return SizeExpandedSection(
        axis: Axis.horizontal,
        child: Row(
          children: [
            if (widget.isEnabled)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: FlutterReactionButton(
                  splashColor: Colors.transparent,
                  boxPadding: EdgeInsets.all(16),
                  shouldChangeReaction: false,
                  boxColor: AppColor.background,
                  onReactionChanged: (reaction, index) async {
                    if (reactions[index].reacted) {
                      await ReactionsService.deleteReaction(
                          widget.url, reactions[index].userReactionID);
                      reactions[index].removeReaction();
                    } else
                      await ReactionsService.createReaction(
                              widget.url, reactions[index].reaction)
                          .then((value) {
                        reactions[index].addUserReaction(value.id);
                      });
                    setState(() {});
                  },
                  boxItemsSpacing: 24,
                  initialReaction: Reaction(
                    icon: Material(
                        color: AppColor.background,
                        borderRadius: AppThemeBorderRadius.bigBorderRadius,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Container(
                              height: 36,
                              child: Center(
                                  child: Icon(
                                Icons.add,
                                color: AppColor.grey3,
                              ))),
                        )),
                  ),
                  reactions: List.generate(
                      reactions.length,
                      (index) => Reaction(
                              icon: Text(
                            reactions[index].emoji,
                            style: TextStyle(fontSize: 18),
                          ))),
                ),
              ),
            Expanded(
                child: Row(
              children: List.generate(
                reactions.length,
                (index) => Visibility(
                  visible: reactions[index].count > 0,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ReactionButton(
                        reactions[index],
                        url: widget.url,
                        isEnabled: widget.isEnabled,
                        onChanged: (reaction) {
                          setState(() {
                            reactions[index] = reaction;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
            )),
          ],
        ),
      );
  }

  List<CommentReaction> getReactionStats(List<ReactionsModel> data) {
    CommentReaction plusOne = CommentReaction(reaction: '+1');
    CommentReaction minusOne = CommentReaction(reaction: '-1');
    CommentReaction laugh = CommentReaction(reaction: 'laugh');
    CommentReaction confused = CommentReaction(reaction: 'confused');
    CommentReaction heart = CommentReaction(reaction: 'heart');
    CommentReaction hooray = CommentReaction(reaction: 'hooray');
    CommentReaction rocket = CommentReaction(reaction: 'rocket');
    CommentReaction eyes = CommentReaction(reaction: 'eyes');
    data.forEach((element) {
      if (element.content == plusOne.reaction) {
        plusOne.users.add(element.user);
        if (element.user.login == widget.currentUser) {
          plusOne.reacted = true;
          plusOne.userReactionID = element.id;
        }
        plusOne.count++;
      } else if (element.content == minusOne.reaction) {
        minusOne.users.add(element.user);
        if (element.user.login == widget.currentUser) {
          minusOne.reacted = true;
          minusOne.userReactionID = element.id;
        }
        minusOne.count++;
      } else if (element.content == laugh.reaction) {
        hooray.users.add(element.user);
        if (element.user.login == widget.currentUser) {
          hooray.reacted = true;
          hooray.userReactionID = element.id;
        }
        hooray.count++;
      } else if (element.content == confused.reaction) {
        confused.users.add(element.user);
        if (element.user.login == widget.currentUser) {
          confused.reacted = true;
          confused.userReactionID = element.id;
        }
        confused.count++;
      } else if (element.content == heart.reaction) {
        heart.users.add(element.user);
        if (element.user.login == widget.currentUser) {
          heart.reacted = true;
          heart.userReactionID = element.id;
        }
        heart.count++;
      } else if (element.content == hooray.reaction) {
        hooray.users.add(element.user);
        if (element.user.login == widget.currentUser) {
          hooray.reacted = true;
          hooray.userReactionID = element.id;
        }
        hooray.count++;
      } else if (element.content == rocket.reaction) {
        rocket.users.add(element.user);
        if (element.user.login == widget.currentUser) {
          rocket.reacted = true;
          rocket.userReactionID = element.id;
        }
        rocket.count++;
      } else if (element.content == eyes.reaction) {
        eyes.users.add(element.user);
        if (element.user.login == widget.currentUser) {
          eyes.reacted = true;
          eyes.userReactionID = element.id;
        }
        eyes.count++;
      }
    });
    List<CommentReaction> reactions = [
      plusOne,
      minusOne,
      laugh,
      confused,
      heart,
      hooray,
      rocket,
      eyes
    ];
    return reactions;
  }
}

class ReactionButton extends StatefulWidget {
  final CommentReaction commentReaction;
  final String url;
  final bool isEnabled;
  final ValueChanged<CommentReaction> onChanged;
  ReactionButton(this.commentReaction,
      {this.url, this.onChanged, this.isEnabled = true});

  @override
  _ReactionButtonState createState() => _ReactionButtonState();
}

class _ReactionButtonState extends State<ReactionButton> {
  bool loading = false;
  CommentReaction _reaction;

  @override
  void initState() {
    _reaction = widget.commentReaction;
    super.initState();
  }

  void changeReaction() async {
    setState(() {
      loading = true;
    });
    try {
      if (_reaction.reacted) {
        await ReactionsService.deleteReaction(
            widget.url, _reaction.userReactionID);
        _reaction.removeReaction();
      } else
        await ReactionsService.createReaction(widget.url, _reaction.reaction)
            .then((value) {
          _reaction.addUserReaction(value.id);
        });
      widget.onChanged(_reaction);
    } catch (e) {}
    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizeExpandedSection(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2.0),
        child: Material(
            color: _reaction.reacted ? AppColor.accent : AppColor.background,
            borderRadius: AppThemeBorderRadius.bigBorderRadius,
            child: InkWell(
              onTap: widget.isEnabled && !loading
                  ? () {
                      changeReaction();
                    }
                  : null,
              onLongPress: () {
                showScrollableBottomActionsMenu(context,
                    titleText: ':${_reaction.reaction}: ${_reaction.emoji}',
                    child: (context, scrollController) {
                  return ListView.separated(
                      separatorBuilder: (context, index) {
                        return Divider();
                      },
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      controller: scrollController,
                      itemCount: _reaction.users.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ProfileTile(
                            _reaction.users[index].avatarUrl,
                            padding: EdgeInsets.all(8),
                            userLogin: _reaction.users[index].login,
                            showName: true,
                          ),
                        );
                      });
                });
              },
              borderRadius: AppThemeBorderRadius.bigBorderRadius,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Container(
                  height: 36,
                  child: loading
                      ? Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: LoadingIndicator(
                            size: 15,
                          ),
                        )
                      : Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 8,
                            ),
                            Text(_reaction.emoji),
                            SizedBox(
                              width: 8,
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              child: Text(
                                _reaction.count.toString(),
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                            SizedBox(
                              width: 8,
                            ),
                          ],
                        ),
                ),
              ),
            )),
      ),
    );
  }
}