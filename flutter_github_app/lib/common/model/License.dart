import 'package:json_annotation/json_annotation.dart';

part 'License.g.dart';

@JsonSerializable()
class License {
  String name;

  License(this.name);


}