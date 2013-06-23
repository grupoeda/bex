import 'model.dart';
import 'package:web_ui/web_ui.dart';

class XValues extends WebComponent{
@observable
  Variable variable;
@observable
  VariableValue variablevalue;
@observable
  String valueid;
@observable
  Map<String, List<CharValue>> values;
@observable
  bool show;
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

  void choose(String id){
    valueid = id;
    show = false;
  }
  
  void close(){
    show = false;
  }
  
  void nextPage(){
    if(page<lastPage)
      page+=1;
    else
      page=1;
  }
  
  void prevPage(){
    if(page>1)
      page-=1;
    else
      page=lastPage;
  }
}
