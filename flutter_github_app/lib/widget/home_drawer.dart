import 'package:flutter/material.dart';
import 'package:redux/redux.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_github_app/widget/gsy_flex_button.dart';
import 'package:flutter_github_app/common/config/config.dart';
import 'package:flutter_github_app/common/local/local_storage.dart';
import 'package:flutter_github_app/common/style/gsy_style.dart';
import 'package:flutter_github_app/common/utils/common_utils.dart';
import 'package:flutter_github_app/common/model/User.dart';
import 'package:flutter_github_app/common/redux/gsy_state.dart';
import 'package:flutter_github_app/common/utils/navigator_utils.dart';
import 'package:flutter_github_app/common/dao/user_dao.dart';

class HomeDrawer extends StatelessWidget {

  showThemeDialog(BuildContext context, Store store) {
    List<String> list = [
      CommonUtils.getLocale(context).home_theme_default,
      CommonUtils.getLocale(context).home_theme_1,
      CommonUtils.getLocale(context).home_theme_2,
      CommonUtils.getLocale(context).home_theme_3,
      CommonUtils.getLocale(context).home_theme_4,
      CommonUtils.getLocale(context).home_theme_5,
      CommonUtils.getLocale(context).home_theme_6,
    ];

    CommonUtils.showCommitOptionDialog(context, list, (index) {
      CommonUtils.pushTheme(store, index);
      LocalStorage.save(Config.THEME_COLOR, index.toString());
    }, colorList: CommonUtils.getThemeListColor());

  }

  showLanguageDialog(BuildContext context, Store store) {
    List<String> list = [
      CommonUtils.getLocale(context).home_language_default,
      CommonUtils.getLocale(context).home_language_zh,
      CommonUtils.getLocale(context).home_language_en,
    ];

    CommonUtils.showCommitOptionDialog(context, list, (index) {
      CommonUtils.changeLocale(store, index);
      LocalStorage.save(Config.LOCALE, index.toString());
    }, height: 150.0);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: StoreBuilder<GSYState>(
        builder: (context, store) {
          User user = store.state.userInfo;
          return Drawer(
            child: Container(
              color: store.state.themeData.primaryColor,
              child: SingleChildScrollView(
                child: Container(
                  constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height),
                  child: Material(
                    color: Color(GSYColors.white),
                    child: Column(
                      children: <Widget>[
                        UserAccountsDrawerHeader(
                          accountName: Text(user.login ?? "---", style: GSYConstant.largeTextWhite),
                          accountEmail: Text(user.email ?? user.name ?? "---", style: GSYConstant.normalTextLight),
                          currentAccountPicture: GestureDetector(
                            onTap: () {},
                            child: CircleAvatar(
                              backgroundImage: NetworkImage(user.avatar_url ?? GSYICons.DEFAULT_REMOTE_PIC),
                            ),
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        ListTile(
                          title: Text(CommonUtils.getLocale(context).home_change_theme, style: GSYConstant.normalText),
                          onTap: () {
                            showThemeDialog(context, store);
                          },
                        ),
                        ListTile(
                          title: Text(CommonUtils.getLocale(context).home_change_language, style: GSYConstant.normalText),
                          onTap: () {
                            showLanguageDialog(context, store);
                          },
                        ),
                        ListTile(
                          title: Text(CommonUtils.getLocale(context).home_user_info, style: GSYConstant.normalText),
                          onTap: () {},
                        ),
                        ListTile(
                          title: GSYFlexButton(
                            text: CommonUtils.getLocale(context).login_out,
                            color: Colors.redAccent,
                            textColor: Color(GSYColors.textWhite),
                            onPress: () {
                              UserDao.clearAll(store);
//                              SqlManager.close();
                              NavigatorUtils.goLogin(context);
                            },
                          ),
                          onTap: () {},
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
