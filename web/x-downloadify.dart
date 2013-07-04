import 'model.dart';
import 'package:web_ui/web_ui.dart';
import 'package:js/js.dart' as js;

class XDownloadify extends WebComponent {
  String filedata;
  String filename;
  
  void createDownloadifyButton(){    
    var downloadify = js.context.Downloadify;
    downloadify.create("downloadify", js.map({
      "filename": filename,
      "data": filedata,
      "dataType": "base64",
      "swf": "packages/Downloadify/downloadify.swf",
      "hidden": true,
      "append":false
    }));
  }
  
  void inserted(){
    createDownloadifyButton();
  }
}