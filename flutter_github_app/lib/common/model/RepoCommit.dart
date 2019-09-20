import 'package:json_annotation/json_annotation.dart';
import 'package:flutter_github_app/common/model/User.dart';
import 'package:flutter_github_app/common/model/CommitGitInfo.dart';

part 'RepoCommit.g.dart';

@JsonSerializable()
class RepoCommit {
  String sha;
  String url;
  @JsonKey(name: "html_url")
  String htmlUrl;
  @JsonKey(name: "comment_url")
  String commentUrl;

  CommitGitInfo commit;
  User author;
  User committer;
  List<RepoCommit> parents;

  RepoCommit(
    this.sha,
    this.url,
    this.htmlUrl,
    this.commentUrl,
    this.commit,
    this.author,
    this.committer,
    this.parents,
  );

  factory RepoCommit.fromJson(Map<String, dynamic> json) => _$RepoCommitFromJson(json);

  Map<String, dynamic> toJson() => _$RepoCommitToJson(this);
}
