import 'model.dart';
import 'package:web_ui/web_ui.dart';
import 'dart:html';
import 'dart:async';

class XValues extends WebComponent{
@observable
  Variable variable;
@observable
  VariableValue variablevalue;
@observable
  String valueid;
@observable
  bool high = false;
@observable
  Map<String, List<CharValue>> values;
@observable
  bool showDiv=false;
@observable
  bool closing=false;
  Timer timer;
@observable
  int page=1;
@observable
  int lastPage=0;
@observable
  int itemsperpage=20;

@observable
  List<CharValue> get charValues{
    if(values[variable.charName]==null){
      values[variable.charName]=toObservable([]);
      model.loadData(variable.charName);
    }
    String lvalueid=valueid.toLowerCase();
    var res = values[variable.charName].where((CharValue c)=>c.id.toLowerCase().contains(lvalueid)||c.desc.toLowerCase().contains(lvalueid));
    int totalItems = res.length;
    int page = this.page;
    int lastPage = this.lastPage;
    lastPage = (totalItems/itemsperpage).ceil();
    if(lastPage==0)
      lastPage=1;
    if(page>lastPage)
      page = lastPage;
    int startItem = (page-1)*itemsperpage;
    int lastItem = startItem+itemsperpage;
    if(lastItem>totalItems)
      lastItem = totalItems;
    this.page=page;
    this.lastPage = lastPage;
    if(lastItem>=0)
      return res.toList().sublist(startItem, lastItem);
    else
      return [];
  }

  void show(){
    closing = false;
    showDiv = true;
  }
  
  void choose(String id){
    valueid = id;
    showDiv = false;
  }
  
  void close(){
    closing=true;
    if(timer!=null)
      timer.cancel();
    timer = new Timer(new Duration(seconds:1), (){
      if(closing){
        showDiv=false;
      }
    });
  }
  
  void nextPage(){
    closing=false;
    if(page<lastPage)
      page+=1;
    else
      page=1;
    this.host.query("input").focus();
  }
  
  void prevPage(){
    closing=false;
    if(page>1)
      page-=1;
    else
      page=lastPage;
    this.host.query("input").focus();
  }
}
