import 'model.dart';
import 'package:web_ui/web_ui.dart';
import 'dart:html';
import 'dart:json';

class XBexTable extends WebComponent {
  @observable
  bool showEmbed=false;
  
  String get buttonToogleShowAxisText{
    return model.viewState.showAxis? "Esconder Conf. Eixos":"Ver Conf. Eixos";
  }
  void toogleShowSettings(){
    model.viewState.showSettings = !model.viewState.showSettings;
  }
  void toogleInformation(){
    model.viewState.showInformation = !model.viewState.showInformation;
  }
  void toogleUseDescription(){
    model.viewState.useDescription = !model.viewState.useDescription;
  }
  void toogleShowAxis(){
    model.viewState.showAxis = !model.viewState.showAxis;
  }
  void toogleExpandTable(){
    model.viewState.expandTableText = !model.viewState.expandTableText;
  }
  void toogleShowTotals(){
    model.viewState.showTotals = !model.viewState.showTotals;
  }
  void toogleShowGrid(){
    model.viewState.showGrid = !model.viewState.showGrid;
  }
  void addFilter(Cell cell){
    if(cell.characteristic==null)
      return;
    String value = null;
    if(!cell.total&&cell.type!=Cell.CHARINFOCOLUMN&&cell.type!=Cell.CHARINFOROW){
      value = cell.id;
    }
    List<Variable> vars = model.globalState.serverState.queryState.currentQueryVars;    
    var foundVar = vars.where((Variable i)=>i.isChar&&i.id==cell.characteristic);
    Variable variable;
    if(foundVar.isNotEmpty)
      variable=foundVar.first;
    else{
      variable=new Variable(true, cell.characteristic, null, false, "S", cell.characteristic,0,'CHAR');
      vars.add(variable);
    }
    if(variable.values.length>0&&variable.values[variable.values.length-1].empty)
      variable.removeVariableValue(variable.values[variable.values.length-1]);
    VariableValue variableValue = new VariableValue();
    if(value!=null){
      variableValue.operation="EQ";
      variableValue.sign = "I";
      variableValue.low = value;
      variableValue.high = "";
    }
    variable.addVariableValue(variableValue);
  }
  
  void prepareDownload(){
    if(model.globalState.serverState.queryState.queryExecutionState!=null){
      model.globalState.serverState.queryState.queryExecutionState.download=true;
    }
  }
}
