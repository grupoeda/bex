import 'model.dart';
import 'package:web_ui/web_ui.dart';
import 'dart:html';

class XBexInfo extends WebComponent {
  @observable
  bool expandTableText=false;
  
  String get buttonToogleExpandTableText{
    return expandTableText?"> <":"< >";
  }
  void toogleExpandTable(){
    expandTableText = !expandTableText;
  }
  void selectTable(){
    _select("bexinfo");
  }
  void _select(String id){
    Element bexTableElement = document.getElementById(id);
    if(bexTableElement!=null){
      Selection selection = window.getSelection();
      Range rangeToSelect = new Range();
      rangeToSelect.selectNodeContents(bexTableElement);
      selection.removeAllRanges();
      selection.addRange(rangeToSelect);
    }
  }
}
