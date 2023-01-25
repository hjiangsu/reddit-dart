import 'package:reddit/src/utils/parse.dart';

class Comment {
  late Map<String, dynamic> _information;

  List<dynamic>? children;
  List<Comment> replies = [];

  Comment({required Map<String, dynamic> information}) {
    _information = information;

    if (information["replies"] is String) {
      // This means that there are no more replies to this comment
      replies = [];
    } else {
      Map<String, dynamic> repliesListing = parseListing(information["replies"]);
      Map<String, dynamic> _replies = parseCommentListing(commentListing: repliesListing);

      if (_replies["comments"].length > 0) {
        replies = _replies["comments"];
      } else {
        children = _replies["more"]["data"]["children"];
      }
    }
  }

  Map<String, dynamic> get information => _information;
}
