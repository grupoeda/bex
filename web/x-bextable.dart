import 'model.dart';
import 'package:web_ui/web_ui.dart';
import 'dart:html';
import 'dart:json';

class XBexTable extends WebComponent {
  String get buttonToogleUseDescriptionText{
    return model.viewState.useDescription? "Ver nomes técnicos":"Ver Descrições";
  }
  String get buttonToogleInformationText{
    return model.viewState.showInformation? "Esconder Inf. Query":"Ver Inf. Query";
  }
  String get buttonToogleShowAxisText{
    return model.viewState.showAxis? "Esconder Conf. Eixos":"Ver Conf. Eixos";
  }
  String get buttonToogleShowTotalsText{
    return model.viewState.showTotals? "Esconder Totais":"Mostrar Totais";
  }
  String get buttonToogleExpandTableText{
    return model.viewState.expandTableText?"> <":"< >";
  }
  String get buttonToogleShowGridText{
    return model.viewState.showGrid? "Esconder Grelha":"Mostrar Grelha";
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
  
/*  void exportCSV(){
    String content = "";
    String line = "";
    for(num i=0; i<model.bextable.length; i++){
      for(num j=0; j<model.bextable[i].length; j++){
        if(j>0)
          line+="\t";
        line+=model.bextable[i][j].description;
      }
      content+=line+"\n";
      line="";
    }
    content = encodeUri(content);
    window.open("data:text/csv;charset=utf-8,${content}", "_blank");
  }
  void selectTable(){
    _select("bextable");
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
  }*/
}
