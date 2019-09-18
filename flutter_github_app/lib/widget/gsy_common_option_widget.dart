import 'package:flutter/material.dart';
import 'package:flutter_github_app/common/style/gsy_style.dart';
import 'package:flutter_github_app/common/utils/common_utils.dart';
import 'package:share/share.dart';

class GSYCommonOptionWidget extends StatelessWidget {

  final List<GSYOptionModel> otherList;

  final OptionControl control;

  GSYCommonOptionWidget(this.control, {this.otherList});
  _renderHeaderPopItem(List<GSYOptionModel> list) {
    return PopupMenuButton<GSYOptionModel>(
      child: Icon(GSYICons.MORE),
      onSelected: (model) {
        model.selected(model);
      },
      itemBuilder: (BuildContext context) {
        return _renderHeaderPopItemChild(list);
      },
    );
  }

  _renderHeaderPopItemChild(List<GSYOptionModel> data) {
    List<PopupMenuEntry<GSYOptionModel>> list = List();
    for (GSYOptionModel item in data) {
      list.add(PopupMenuItem<GSYOptionModel>(
        value: item,
        child: Text(item.name),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    List<GSYOptionModel> list = [
      GSYOptionModel(CommonUtils.getLocale(context).option_web, CommonUtils.getLocale(context).option_web, (model) {
//        CommonUtils.launchOutURL(control.url, context);
        print('Lanch Url !!!');
      }),
      new GSYOptionModel(CommonUtils.getLocale(context).option_copy, CommonUtils.getLocale(context).option_copy, (model) {
//        CommonUtils.copy(control.url ?? "", context);
        print('Copy Url !!!');
      }),
      new GSYOptionModel(CommonUtils.getLocale(context).option_share, CommonUtils.getLocale(context).option_share, (model) {
//        Share.share(CommonUtils.getLocale(context).option_share_title + control.url ?? "");
        print('Share Url !!!');
      }),
    ];
    if (otherList != null && otherList.length > 0) {
      list.addAll(otherList);
    }

    return _renderHeaderPopItem(list);
  }
}


class OptionControl {
  String url = GSYConstant.app_defalut_share_url;
}

class GSYOptionModel {
  final String name;
  final String value;
  final PopupMenuItemSelected<GSYOptionModel> selected;

  GSYOptionModel(this.name, this.value, this.selected);
}