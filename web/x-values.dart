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
  bool more=false;
@observable
  List<CharValue> get charValues{
    if(values[variable.charName]==null){
      values[variable.charName]=toObservable([]);
      model.loadData(variable.charName);
    }
    String lvalueid=valueid.toLowerCase();
    var res = values[variable.charName].where((CharValue c)=>c.id.toLowerCase().contains(lvalueid)||c.desc.toLowerCase().contains(lvalueid));
    if(res.length <= 20)
      more = false;
    else
      more = true;
    return more ? res.take(20).toList():res.toList();
  }
}
