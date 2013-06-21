import 'model.dart';
import 'package:web_ui/web_ui.dart';

class XFieldValue extends WebComponent {
  Variable variable;
  @observable
  VariableValue value;
  @observable
  bool showLowValues = false;
  @observable
  bool showHighValues = false;
  
  add(){
    VariableValue newValue = new VariableValue();
    variable.addVariableValue(newValue);
  }
  remove(){
    if(variable.values.length==1)
      value = new VariableValue();
    else{
      variable.removeVariableValue(value);
    }
  }
  void changedHigh(Variable variable, VariableValue value){
    if(variable.interval=="S")
    if(value.high==""&&value.interval)
      value.operation = "EQ";
    else if(value.high!=""&&!value.interval)
      value.operation = "BT";
  }
}
