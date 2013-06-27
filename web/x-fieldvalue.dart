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
    variable.removeVariableValue(value);
    if(variable.values.length==1 && !variable.isChar)
      variable.addVariableValue(new VariableValue());
  }
}
