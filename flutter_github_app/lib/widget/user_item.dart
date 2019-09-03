import 'package:flutter/material.dart';
import 'package:flutter_github_app/common/model/UserOrg.dart';
import 'package:flutter_github_app/common/model/User.dart';
import 'package:flutter_github_app/common/style/gsy_style.dart';
import 'package:flutter_github_app/widget/gsy_card_item.dart';

/**
 * 用户item
 */

class UserItem extends StatelessWidget {

  final UserItemViewModel userItemViewModel;

  final VoidCallback onPressed;

  final bool needImage;

  UserItem(this.userItemViewModel, {this.onPressed, this.needImage = true}) : super();

  @override
  Widget build(BuildContext context) {
    Widget userImage = IconButton(
      padding:  EdgeInsets.only(top: 0.0, left: 0.0, bottom: 0.0, right: 10.0),
      icon: ClipOval(
        child: FadeInImage.assetNetwork(
          placeholder: GSYICons.DEFAULT_USER_ICON,
          fit: BoxFit.fitWidth,
          image: userItemViewModel.userPic,
          width: 30.0,
          height: 30.0,
        ),
      ),
      onPressed: null,
    );

    return Container(
      child: GSYCardItem(
        child: FlatButton(
          onPressed: onPressed,
          child: Padding(
            padding: EdgeInsets.only(left: 0.0, top: 5.0, right: 0.0, bottom: 10.0),
            child: Row(
              children: <Widget>[
                userImage,
                Expanded(child: Text(userItemViewModel.userName, style: GSYConstant.smallTextBold)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class UserItemViewModel {

  String userPic;
  String userName;

  UserItemViewModel.fromMap(User user) {
    userName = user.login;
    userPic = user.avatar_url;
  }

  UserItemViewModel.fromOrgMap(UserOrg org) {
    userName = org.login;
    userPic = org.avatarUrl;
  }
}
