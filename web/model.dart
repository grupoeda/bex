import 'dart:json' as json;
import 'dart:html';
import 'package:web_ui/web_ui.dart';
import 'package:jsonp_request/jsonp_request.dart';
import 'package:sharepointauth/authentication.dart';

Model model = new Model();
final bool useJsonp = false;

class Html5Support{
  bool inputTypeDate;
  bool inputTypeNumber;
}

@observable
class Cell{
  static const int EMPTY = 99;
  static const int CHARINFOROW = 0;
  static const int CHARINFOCOLUMN = 1;
  static const int CHARDATAROW = 10;
  static const int CHARDATACOLUMN = 11;
  static const int CELL = 20;
  String id;
  String description;
  int type;
  bool odd = false;
  int colspan = 1;
  int get colspanShow{
    if(model.viewState.showGrid)
      return colspan;
    else return 1;
  }
  int rowspan = 1;
  int get rowspanShow{
    if(model.viewState.showGrid)
      return rowspan;
    else return 1;
  }
  bool show = true;
  bool totalOdd = false;
  bool totalRow = false;
  bool totalColumn = false;
  bool total = false;
  bool selected = false;
  String get value{
    if((model.viewState.useDescription&&description!=null&&description.length>0)||id==null||id.length==0)
      return description;
    else
      return id;
  }
  String get cssClass{
    String cssClass;
    if(total)
      if(type==Cell.CELL)
        cssClass = "cell20Total";
      else
        cssClass = "cellTotal";
    else
      cssClass = "cell${type}";
    bool odd;
    if(!model.viewState.showTotals)
      odd = this.totalOdd;
    else
      odd = this.odd;
    if(model.viewState.showGrid)
      if(type!=Cell.EMPTY)
        cssClass += " border";
    else if(!total&&odd&&(type==CHARDATAROW||type==CELL))
      cssClass += "odd";
    return cssClass;
  }
  Cell(this.id,this.description,this.type,this.total);
}

@observable
class Axis{
  String id;
  String description;
  bool selected = false;
  String get value{
    if((model.viewState.useDescription&&description!=null&&description.length>0)||id==null||id.length==0)
      return description;
    else
      return id;
  }
  
  Axis(this.id,this.description);
}

@observable
class Query{
  static final Query EMPTYQUERY = new Query("","","---Seleccione uma query------------------------------------------------------------");
  String infocube;
  String query;
  String description;
  String get id{
    if(infocube!="")
      return "${infocube}/${query}";
    else
      return "";
  }
  String get value{
    if(!model.viewState.useDescription&&id!="")
      return id;
    else
      return description;
  }
  
  Query(this.infocube, this.query, this.description);
}

@observable
class VariableValue{
  String guid;
  String operation;
  String sign;
  String low;
  String lowDescription;
  String high;
  String highDescription;
  bool get interval{
    return operation=="BT"||operation=="NB";
  }
  
  VariableValue(){
    operation = "EQ";
    sign = "I";
    low = "";
    lowDescription = "";
    high = "";
    highDescription = "";
  }
}

@observable
class Variable{
  String id;
  String description;
  bool obligatory;
  bool copy;
  String interval;
  String charName;
  int length;
  String dataType;
  String get name{
    if(model.viewState.useDescription&&description.length>0)
      return description;
    else
      return id;
  }
  String get htmlInputType{
    if(dataType=="NUMC"&&model.html5Support.inputTypeNumber)
      return "number";
    else if (dataType=="DATS"&&model.html5Support.inputTypeDate)
      return "date";
    else
      return "text";
  }
  String get htmlInputPlaceholder{
    if(dataType=="NUMC")
      return "número com ${length} digitos";
    else if(dataType=="CHAR")
      return "cadeia com ${length} caracteres";
    else if (dataType=="DATS")
      return "aaaa-mm-dd (10 digitos)";
    else
      return "";
  }
  bool get customDateInput{
    return (dataType=="DATS"&&!model.html5Support.inputTypeDate);
  }
  bool get customInput{
    return customDateInput;
  }
  List<Map> possibleValues;
  List<VariableValue> values;
  
  Variable(this.id,this.description,this.obligatory,this.interval,this.charName, this.length, this.dataType){
    possibleValues = [];
    VariableValue value = new VariableValue();    
    if(interval=='I')
      value.operation = "BT";
    values = [];
    addVariableValue(value);
  }
  
  addVariableValue(VariableValue value){
    values.add(value);
  }
  
  removeVariableValue(VariableValue value){
    values.remove(value);
  }
}

@observable
class Server{
  static final Server BWP = new Server("BWP 100", "Produtivo BW", "http://dcsapbwprd01.grupoeda.pt:8000/ZBEX2JSON");
  static final Server BWQ = new Server("BWQ 100", "Qualidade BW", "http://dcsapbwq01.grupoeda.pt:8000/ZBEX2JSON");
  static final Server BWD = new Server("BWD 100", "Desenvolvimento BW", "http://dcsapbw01.grupoeda.pt:8000/ZBEX2JSON");
  String id;
  String description;
  String endpoint;
  String get name{
    if(model.viewState.useDescription&&description.length>0)
      return description;
    else
      return id;
  }
  
  Server(this.id, this.description, this.endpoint);
}

@observable
class ServerState{
  Server currentServer = Server.BWP;
  List<Server> servers = [Server.BWP,Server.BWQ,Server.BWD];
  String get serverId{
    if(currentServer==null)
      return "";
    else
      return currentServer.id;
  }
  set serverId(String serverId){
    if(serverId==null||serverId==""){
      currentServer = null;
    }else{
      currentServer = servers.where((Server a){
        return a.id==serverId;
      }).first;
    }
    model.loadQueries();
  }
  Map<String, Query> queries={};
  List<Query> get queryList{
    List<Query> queryList = toObservable(queries.values.toList(growable: true));
    queryList.sort((Query a, Query b) {
      return a.description.compareTo(b.description);
    });
    queryList.insert(0, Query.EMPTYQUERY);
    return queryList;
  }
  QueryState queryState = null;
  String get currentQueryId{
    if(currentQuery==null)
      return "";
    else
      return currentQuery.id;
  }
  set currentQueryId(String id){
    if(id==null||id==""){
      currentQuery=null;
    }else{
      currentQuery = queries[id];
    }
    model.loadQuery(currentQuery);
  }
  Query currentQuery = null;
}

@observable
class QueryState{
  List<Variable> currentQueryVars=toObservable([]);
  QueryExecutionState queryExecutionState = null;
  bool get currentQueryVarsObligatory{
    return currentQueryVars.any((Variable x){
      return x.obligatory;
    });
  }
}

@observable
class QueryExecutionState{
  Map bexraw = {};
  List<List<Cell>> bextable = toObservable([]);
  List<List<Cell>> bexinfo = toObservable([]);
  List<Axis> newAxisFree = toObservable([]);
  List<Axis> newAxisColumns = toObservable([]);
  List<Axis> newAxisRows = toObservable([]);
  List<Axis> axisFree = toObservable([]);
  List<Axis> axisColumns = toObservable([]);
  List<Axis> axisRows = toObservable([]);
  List<List<Cell>> get bextablechecktotals{
    if(model.viewState.showTotals)
      return bextable;
    else
      return toObservable(bextable.where((List<Cell> l){
        return !l[0].totalRow;
      })); 
  }
  
  void resetNewAxis(){
    newAxisFree = toObservable([]);
    newAxisFree.addAll(axisFree);
    newAxisColumns = toObservable([]);
    newAxisColumns.addAll(axisColumns);
    newAxisRows = toObservable([]);
    newAxisRows.addAll(axisRows);
  }
  
  void clearNewAxisColumns(){
    newAxisFree = toObservable([]);
    newAxisFree.addAll(axisFree);    
    newAxisFree.addAll(axisColumns);
    newAxisColumns = toObservable([]);
  }
  
  void clearNewAxisRows(){
    newAxisFree = toObservable([]);
    newAxisFree.addAll(axisFree);
    newAxisFree.addAll(axisRows);
    newAxisRows = toObservable([]);    
  }
}

@observable
class ViewState{
  bool useDescription = true;  
  bool showInformation = false;
  bool showAxis = false;
  bool showTotals = true;
  bool showGrid = true;
  bool expandTableText = false;
  bool showSettings = false;
}
@observable
class GlobalState{
  String errorMessage=null;
  bool loading = false;
  ServerState serverState = new ServerState();
}

class Model{        
  Html5Support html5Support;
  @observable
  GlobalState globalState= new GlobalState();
  @observable
  ViewState viewState= new ViewState();
  @observable
  Authentication authentication;
  
  void assignBexResult(Map result){
    if(result['error']!=null)
      model.globalState.errorMessage=result['error'];
    else{
      model.globalState.errorMessage=null;
      QueryExecutionState qes = new QueryExecutionState();
      qes.bexraw = result;
      num countColChars = qes.bexraw['col_info'].length;
      num countRowChars = qes.bexraw['row_info'].length;
      List<bool> totalCol = [];
      for(num i = 0; i<qes.bexraw['col_data'].length; i++){
        totalCol.add(false);
      }
      for(num i = 0; i<qes.bexraw['col_info'].length; i++){
        List<Cell> tableRow = [];
        List<Cell> empty = [];
        for(num k = 0; k<countRowChars-1; k++)
          empty.add(new Cell("","",Cell.EMPTY, false));
        tableRow.addAll(empty);
        Cell cell = new Cell(qes.bexraw['col_info'][i]['name'],qes.bexraw['col_info'][i]['description'],Cell.CHARINFOCOLUMN,false);
        tableRow.add(cell);
        qes.axisColumns.add(new Axis(qes.bexraw['col_info'][i]['name'],qes.bexraw['col_info'][i]['description']));
        for(num j = 0; j < qes.bexraw['col_data'].length; j++){
          Map cellMap = qes.bexraw['col_data'][j][i];
          bool oldTotalCol = totalCol[j];
          if(cellMap['name']=="SUMME")
            totalCol[j]=true;
          if(totalCol[j]&&oldTotalCol)
            cell = new Cell("","",Cell.CHARDATACOLUMN,true);
          else
            cell = new Cell(cellMap['name'],cellMap['description'],Cell.CHARDATACOLUMN,totalCol[j]);
          tableRow.add(cell);        
        }
        qes.bextable.add(tableRow);
      }
      List<Cell> tableRow = [];
      if(qes.bexraw['row_info'].length==0)
        tableRow.add(new Cell("","",Cell.EMPTY, false));
      for(num i = 0; i<qes.bexraw['row_info'].length; i++){
        Cell cell = new Cell(qes.bexraw['row_info'][i]['name'],qes.bexraw['row_info'][i]['description'],Cell.CHARINFOROW,false);
        tableRow.add(cell);
        qes.axisRows.add(new Axis(qes.bexraw['row_info'][i]['name'],qes.bexraw['row_info'][i]['description']));
      }
      for(num i = 0; i<qes.bexraw['col_data'].length; i++){
        tableRow.add(new Cell("","", Cell.CHARDATACOLUMN, totalCol[i]));
      }
      qes.bextable.add(tableRow);        
      for(num i = 0; i<qes.bexraw['row_data'].length; i++){
        List<Cell> tableRow = [];
        bool total=false;
        bool clearNextTotalTitle=false;
        for(Map j in qes.bexraw['row_data'][i]){
          if(j['name']=="SUMME"){
            if(total)
              clearNextTotalTitle=true;
            total=true;
          }
          if(clearNextTotalTitle)
            tableRow.add(new Cell("","", Cell.CHARDATAROW, total));
          else
            tableRow.add(new Cell(j['name'],j['description'], Cell.CHARDATAROW, total));
        }
        if(qes.bexraw['values'].length>0){
          for(num j = 0; j<qes.bexraw['values'][i].length; j++){
            Map cell = qes.bexraw['values'][i][j];
            tableRow.add(new Cell(cell['name'],cell['formatted'], Cell.CELL, total||totalCol[j]));
          }
        }
        qes.bextable.add(tableRow);
      }
      for(num i = 0; i<qes.bexraw['free_info'].length; i++){
        Axis axis = new Axis(qes.bexraw['free_info'][i]['name'],qes.bexraw['free_info'][i]['description']);
        qes.axisFree.add(axis);
      }
      List<Cell> line = [];
      line.add(new Cell("Tipo", "Tipo", Cell.CHARINFOCOLUMN, false));
      line.add(new Cell("Nome", "Nome", Cell.CHARINFOCOLUMN, false));
      line.add(new Cell("Valor", "Valor", Cell.CHARINFOCOLUMN, false));
      qes.bexinfo.add(line);
      for(num i = 0; i<qes.bexraw['symbols'].length; i++){
        List<Cell> line = [];
        Map cell=qes.bexraw['symbols'][i];
        line.add(new Cell(cell['sym_type'], cell['sym_type'], Cell.CHARDATAROW, false));
        line.add(new Cell(cell['sym_name'], cell['sym_caption'], Cell.CHARDATAROW, false));
        line.add(new Cell(cell['sym_value'], cell['sym_value'], Cell.CELL, false));
        qes.bexinfo.add(line);
        /*if(cell['sym_name']=="REPTXTLG"){
          currentQuery.description=cell['sym_value'];
        }*/
      }
      for(int i = 0; i<qes.bextable.length;i++){
        bool total = false;
        for(int j = 0; j<qes.bexraw['row_info'].length;j++){
          if(qes.bextable[i][j].id=="SUMME"){
            total=true;
          }
          if(total){
            for(int j = 0; j<qes.bextable[i].length;j++)
              qes.bextable[i][j].totalRow=true;           
          }
        }        
      }
      for(int j = 0; j<qes.bextable[0].length;j++){
        bool total = false;
        for(int i = 0; i<qes.bexraw['col_info'].length;i++){
          if(qes.bextable[i][j].id=="SUMME"){
            total=true;
          }
          if(total){
            for(int i = 0; i<qes.bextable.length;i++)
              qes.bextable[i][j].totalColumn=true;           
          }
        }        
      }
      int z=0;
      for(int i = 0; i<qes.bextable.length;i++){        
        for(int j = 0; j<qes.bextable[i].length;j++){
          qes.bextable[i][j].odd = i%2==0;
          qes.bextable[i][j].totalOdd = z%2==0;          
        }
        if(!qes.bextable[i][0].totalRow)
          z++;
      }
      for(int i = 0; i<qes.bexinfo.length;i++){        
        for(int j = 0; j<qes.bexinfo[i].length;j++){
          qes.bexinfo[i][j].odd = i%2==0;
          qes.bexinfo[i][j].totalOdd = i%2==0;
        }
      }
      //Celulas Vazias
      for(int i = 0; i<qes.bexraw['col_info'].length;i++)
        for(int j = 0; j<qes.bexraw['row_info'].length-1;j++){
          if(i==0&&j==0){
            qes.bextable[0][0].show=true;
            qes.bextable[0][0].rowspan=qes.bexraw['col_info'].length;
            qes.bextable[0][0].colspan=qes.bexraw['row_info'].length-1;            
          }else          
            qes.bextable[i][j].show=false;
        }
      //Celulas vazias abaixo das Colunas 
      if(qes.bextable.length>0&&qes.bexraw['col_info'].length>0)
        for(int j = qes.bexraw['row_info'].length; j<qes.bextable[0].length;j++){
          qes.bextable[qes.bexraw['col_info'].length-1][j].rowspan+=1;
          qes.bextable[qes.bexraw['col_info'].length][j].show=false;
        }
      //Agrupamento de linhas
      if(qes.bexraw['row_info'].length>0){
        List<int> indexes = [];
        int start = qes.bexraw['col_info'].length+1;
        for(int k = 0; k<qes.bexraw['row_info'].length;k++)
          indexes.add(start);
        for(int i = start+1; i<qes.bextable.length;i++){        
          for(int j = 0; j<qes.bexraw['row_info'].length;j++){          
            if(qes.bextable[i][j].value==qes.bextable[indexes[j]][j].value){
              qes.bextable[indexes[j]][j].rowspan+=1;
              qes.bextable[i][j].show=false;
            }else{
              for(int k = j; k<qes.bexraw['row_info'].length;k++)
                indexes[k]=i;
              break;
            }
          }
        }
        for(int i = start; i<qes.bextable.length;i++)
          for(int j = qes.bexraw['row_info'].length-1; j>0;j--)  
            if(qes.bextable[i][j].total&&qes.bextable[i][j-1].total){
              qes.bextable[i][j].show=false;
              qes.bextable[i][j-1].colspan+=qes.bextable[i][j].colspan;
            }
      }
      //Agrupamento de colunas
      if(qes.bexraw['col_info'].length>0){
        List<int> indexes = [];
        int start = qes.bexraw['row_info'].length;
        for(int k = 0; k<qes.bexraw['col_info'].length;k++)
          indexes.add(start);
        for(int j = start+1; j<qes.bextable[0].length;j++){        
          for(int i = 0; i<qes.bexraw['col_info'].length;i++){          
            if(qes.bextable[i][j].value==qes.bextable[i][indexes[i]].value){
              qes.bextable[i][indexes[i]].colspan+=1;
              qes.bextable[i][j].show=false;
            }else{
              for(int k = i; k<qes.bexraw['col_info'].length;k++)
                indexes[k]=j;
              break;
            }
          }
        }        
        for(int j = start; j<qes.bextable[0].length;j++)
          for(int i = qes.bexraw['col_info'].length-1; i>0;i--)  
            if(qes.bextable[i][j].total&&qes.bextable[i-1][j].total){
              qes.bextable[i][j].show=false;
              qes.bextable[i-1][j].rowspan+=qes.bextable[i][j].rowspan;
            }
      }
      qes.resetNewAxis();
      globalState.serverState.queryState.queryExecutionState = qes; 
    }
    globalState.loading=false;
  }
  
  String fillVariableValue(Variable variable, int index, bool low){
    String value;
    bool setValue = false;
    if(low)
      value = variable.values[index].low;
    else{
      value = variable.values[index].high;
      if(!variable.values[index].interval){
        variable.values[index].high = "";
        return "";
      }
    }
    if(variable.dataType=="NUMC"){
      setValue = true;      
      num missing0 = variable.length-value.length;
      for(num j=0;j<missing0;j++){
        value="0"+value;
      }
    } else if(variable.dataType=="DATS"){
      if(value.length!=10&&value.length!=0){
        globalState.errorMessage='O valor "${value}" não é uma data';
        return null;
      }else if (value.length!=0){
        String ano = value.substring(0, 4);
        String mes = value.substring(5, 7);
        String dia = value.substring(8, 10);
        value = "${ano}${mes}${dia}";
      }
    }
    if(setValue){
      if(low)
        variable.values[index].low = value;
      else
        variable.values[index].high = value;
    }
    return value;
  }
  
  String fillUrlAxis(String name, List<Axis> list){
    String param = "";
    for(int i = 0; i<list.length; i++)
      param+="&${name}${i+1}=${list[i].id}";
    return param;
  }
  
  void executeBex(){
    if(globalState.serverState==null||globalState.serverState.queryState==null)
      return;
    bool validate = true;
    if(authentication==null){
      globalState.errorMessage="Nenhum utilizador autenticado";
      validate = false;
    }
    String endpointParams = "&infocube=${globalState.serverState.currentQuery.infocube}&query=${globalState.serverState.currentQuery.query}";
    endpointParams += "&USER=${authentication.user}";
    endpointParams += "&KEY=${authentication.key}";
    num i = 1;    
    for(Variable variable in globalState.serverState.queryState.currentQueryVars){
      bool filled = false;
      for(num index = 0; index<variable.values.length;index++){
        if(variable.values[index].low!=""||variable.values[index].high!=""){
          String low = fillVariableValue(variable, index, true);
          String high = fillVariableValue(variable, index, false);
          if(low==null||high==null)
            validate = false;
          endpointParams += "&VAR${i}_VNAM=${variable.id}&VAR${i}_OPT=${variable.values[index].operation}&VAR${i}_SIGN=${variable.values[index].sign}&VAR${i}_LOW=${low}&VAR${i}_HIGH=${high}";
          i++;
          filled = true;
        } else if (!filled&&variable.obligatory){
          globalState.errorMessage='O filtro "${variable.name}" é obrigatório';
          validate = false;
        }
      }
    }
    if(validate && globalState.serverState.queryState.queryExecutionState!=null){
      endpointParams += fillUrlAxis("FREE", globalState.serverState.queryState.queryExecutionState.newAxisFree);
      endpointParams += fillUrlAxis("COL", globalState.serverState.queryState.queryExecutionState.newAxisColumns);
      endpointParams += fillUrlAxis("ROW", globalState.serverState.queryState.queryExecutionState.newAxisRows);
    }
    if(validate){
      globalState.loading=true;
      globalState.serverState.queryState.queryExecutionState = new QueryExecutionState();
      String url = "${globalState.serverState.currentServer.endpoint}?service=execute${endpointParams}";
      if(useJsonp){
        jsonpRequest(url).then((Map result) {
          assignBexResult(result);
        });
      }else{
        HttpRequest.request(url).then((req){
          assignBexResult(json.parse(req.responseText));
        });
      }
    }
  }
  
  void assignQueries(Map result){
    globalState.serverState.queries = {};
    for(Map i in result['queries']){
      Query query = new Query(i['infocube'], i['query'], i['description']);
      globalState.serverState.queries[query.id] = query;
    }
  }
  
  void assignGetVarsResult(Map result){
    globalState.serverState.queryState = new QueryState();
    if(result['error']!=null)
      globalState.errorMessage=result['error'];
    else{
      globalState.errorMessage=null;    
      for(Map i in result['vars']){
        if(i['vartyp']=='1')
          globalState.serverState.queryState.currentQueryVars.add(new Variable(i['vnam'],i['vtxt'],i['entrytp']=='1'?true:false,i['vparsel'],i['iobjnm'],int.parse(i['outputlen']),i['datatp']));
      }
    }
    globalState.loading=false;
    if(result['error']==null&&globalState.serverState.queryState.currentQueryVars.length==0)
      executeBex();
  }
  
  void loadQuery(Query query){    
    globalState.loading = true;
    globalState.serverState.queryState=null;
    if(query==null || query==""){
      globalState.loading=false;
    }else{
      String endpointParams = "&infocube=${query.infocube}&query=${query.query}";
      String url = "${globalState.serverState.currentServer.endpoint}?service=getquery${endpointParams}";
      if(useJsonp){
        jsonpRequest(url).then((Map result) {
          assignGetVarsResult(result);
        });
      }else{
        HttpRequest.request(url).then((req){
          assignGetVarsResult(json.parse(req.responseText));
        });
      }
    }
  }
  
  void loadQueries(){    
    globalState.serverState.currentQueryId = null;
    globalState.serverState.queryState = null;
    globalState.serverState.queries = {};
    if(globalState.serverState.currentServer!=null){
      String url = "${globalState.serverState.currentServer.endpoint}?service=getqueries";    
      if(useJsonp){
        jsonpRequest(url).then((Map result) {
          model.assignQueries(result);
        });
      }else{
        HttpRequest.request(url).then((req){
          model.assignQueries(json.parse(req.responseText));      
        });
      }
    }
  }
}

Map<String, String> getUriParams(String uriSearch) {
  if (uriSearch != '') {
    final List<String> paramValuePairs = uriSearch.substring(1).split('&');
    var paramMapping = new Map<String, String>();
    paramValuePairs.forEach((e) {
      if (e.contains('=')) {
        final paramValue = e.split('=');
        paramMapping[paramValue[0]] = paramValue[1];
      } else {
        paramMapping[e] = '';
      }
    });
    return paramMapping;
  }
  return {};
}

checkHtml5Support(){
  model.html5Support = new Html5Support();
  model.html5Support.inputTypeDate = new InputElement(type: "date").type != "text";
  model.html5Support.inputTypeNumber = new InputElement(type: "number").type != "text";
}

void main() {
  checkHtml5Support();
  Map<String, String> params = getUriParams(window.location.search);
  /*model.user = params['user'];
  model.key = params['key'];*/
  model.loadQueries();
  // Enable this to use Shadow DOM in the browser.
  //useShadowDom = true;
}