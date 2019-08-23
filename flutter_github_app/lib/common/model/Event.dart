import 'package:json_annotation/json_annotation.dart';
import 'package:flutter_github_app/common/model/User.dart';
import 'package:flutter_github_app/common/model/Repository.dart';
import 'package:flutter_github_app/common/model/EventPayload.dart';

part 'Event.g.dart';

@JsonSerializable()
class Event {
  String id;
  String type;
  @JsonKey(name: "public")
  bool isPublic;
  @JsonKey(name: "created_at")
  DateTime createAt;

  User actor;
  Repository repo;
  User org;
  EventPayload payload;

  Event(
    this.id,
    this.type,
    this.isPublic,
    this.createAt,
    this.actor,
    this.repo,
    this.org,
    this.payload,
  );

  factory Event.fromJson(Map<String, dynamic> json) => _$EventFromJson(json);

  Map<String, dynamic> toJson() => _$EventToJson(this);
}
