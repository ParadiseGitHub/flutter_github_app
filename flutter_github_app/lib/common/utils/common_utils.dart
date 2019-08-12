import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_github_app/common/style/gsy_string_base.dart';
import 'package:flutter_github_app/common/localization/default_localizations.dart';

class CommonUtils {


  static GSYStringBase getLocale(BuildContext context) {
    return GSYLocalizations.of(context).currentLocalized;
  }

}