import 'model.dart';
import 'package:web_ui/web_ui.dart';
import 'dart:html';

class XEmbed extends WebComponent {
  final String beginVarD="d{{";
  final String endVarD="}}";
@observable
  bool show;
@observable
  String mode="table";
  String get embedUrl{
    String hash = window.location.hash;
    if(hash.length>0)
      hash=hash.substring(1,hash.length);
    else
      hash="";
    String search = window.location.search;
    if(search.length>0)
      search=search.substring(1,search.length);
    else
      search="";
    return "${window.location.protocol}//${window.location.host}${window.location.pathname}?mode=${mode}&graphtype=${model.viewState.showGraphMode}${window.location.search}&${hash}";
  }
  String get embedIframeUrl{
    return '<iframe width="800" height="800" scr="${embedUrl}"></iframe>';
  }
}
