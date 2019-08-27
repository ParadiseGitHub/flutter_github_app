import 'package:flutter/material.dart';
import 'package:flutter_github_app/common/model/Event.dart';
import 'package:flutter_github_app/common/utils/common_utils.dart';
import 'package:flutter_github_app/common/utils/event_utils.dart';
import 'package:flutter_github_app/common/style/gsy_style.dart';
import 'package:flutter_github_app/widget/gsy_user_icon_widget.dart';
import 'package:flutter_github_app/common/utils/navigator_utils.dart';
import 'package:flutter_github_app/widget/gsy_card_item.dart';

class EventItem extends StatelessWidget {

  final EventViewModel eventViewModel;

  final VoidCallback onPressed;

  final bool needImage;

  EventItem(this.eventViewModel, {this.onPressed, this.needImage = true}) : super();

  @override
  Widget build(BuildContext context) {
    Widget des = (eventViewModel.actionDes == null || eventViewModel.actionDes.length == 0)
        ? Container()
        : Container(
            child: Text(
              eventViewModel.actionDes,
              style: GSYConstant.smallSubText,
              maxLines: 3,
              ),
            margin: EdgeInsets.only(top: 6.0, bottom: 2.0),
            alignment: Alignment.topLeft,
          );

    Widget userImage = (needImage)
        ? GSYUserIconWidget(
            padding: const EdgeInsets.only(top: 0.0, right: 5.0, left: 0.0),
            width: 30.0,
            height: 30.0,
            image: eventViewModel.actionUserPic,
            onPressed: () {
              print('go person page !!!');
              //NavigatorUtils.goPerson(context, eventViewModel.actionUser);
            },
          )
        : Container();

    return Container(
      child: GSYCardItem(
        child: FlatButton(
          onPressed: onPressed,
          child: Padding(
            padding: EdgeInsets.only(left: 0.0, top: 10.0, right: 0.0, bottom: 10.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    userImage,
                    Expanded(child: Text(eventViewModel.actionUser, style: GSYConstant.smallTextBold)),
                    Text(eventViewModel.actionTime, style: GSYConstant.smallSubText),
                  ],
                ),
                Container(
                  child: Text(eventViewModel.actionTarget, style: GSYConstant.smallTextBold),
                  margin: EdgeInsets.only(top: 6.0, bottom: 2.0),
                  alignment: Alignment.topLeft,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class EventViewModel {
  String actionUser;
  String actionUserPic;
  String actionDes;
  String actionTime;
  String actionTarget;

  EventViewModel.fromEventMap(Event event) {
    actionTime = CommonUtils.getNewsTimeStr(event.createAt);
    actionUser = event.actor.login;
    actionUserPic = event.actor.avatar_url;
    var other = EventUtils.getActionAndDes(event);
    actionDes = other["des"];
    actionTarget = other["actionStr"];
  }

  EventViewModel.fromCommitMap() {

  }

  EventViewModel.fromNotify() {

  }
}
