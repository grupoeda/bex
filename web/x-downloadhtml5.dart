import 'model.dart';
import 'package:web_ui/web_ui.dart';
import 'package:js/js.dart' as js;
import 'dart:html';

class XDownloadHtml5 extends WebComponent {
  String filedata;
  String filename;
  String get dataUrl{
    return "data:text/plain;charset=utf-8;base64,"+Uri.encodeComponent(filedata);
  }
  
  void inserted(){
    AnchorElement a = query("#downloadhtml5");
    a.href=dataUrl;
  }
}