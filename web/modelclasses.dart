part of model;

class Html5Support{
  bool inputTypeDate;
  bool inputTypeNumber;
  bool anchorDownload;
  
  Html5Support(){
    inputTypeDate = new InputElement(type: "date").type != "text";
    inputTypeNumber = new InputElement(type: "number").type != "text";
    AnchorElement a = new AnchorElement();
    a.download="x.txt";
    anchorDownload = a.download=="x.txt";
    print(anchorDownload);
  }
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
  String characteristic;
  int type;
  String unit;
  bool odd = false;
  int colspanTotal = 1;
  int rowspanTotal = 1;
  int colspan = 1;
  int get colspanShow{
    if(model.viewState.showGrid)
      if(model.viewState.showTotals)
        return colspan;
      else
        return colspanTotal;
    else return 1;
  }
  int rowspan = 1;
  int get rowspanShow{
    if(model.viewState.showGrid)
      if(model.viewState.showTotals)
        return rowspan;
      else
        return rowspanTotal;
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
      if(!total&&(type==Cell.CHARDATACOLUMN||type==Cell.CHARDATAROW)){
        if(model.viewState.viewTableMode==ViewState.VIEW_TABLE_DESCRIPTION)
          return description;
        else if(model.viewState.viewTableMode==ViewState.VIEW_TABLE_ID)
          return id;
        else if(model.viewState.viewTableMode==ViewState.VIEW_TABLE_ID_AND_DESCRIPTION)
          return "${id} - ${description}";
      }else
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
  Cell(this.id,this.description,this.type,this.total,this.characteristic);
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
  static final Query EMPTYQUERY = new Query("","","---Selecione um relatório----------------------------------------------------------");
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
class CharValue{
  String id;
  String desc;
  
  CharValue(this.id, this.desc);
}

@observable
class VariableValue{
  String operation;
  String sign;
  String low;
  String high;
  bool get interval{
    return operation=="BT"||operation=="NB";
  }
  bool get empty{
    return (low==null||low=="")&&(high==null||high=="");
  }
  void changed(variable, isHigh){
    if(isHigh&&variable.interval=="S")
      if(high==""&&interval)
        operation = "EQ";
      else if(high!=""&&!interval)
        operation = "BT";
  }
  
  VariableValue(){
    operation = "EQ";
    sign = "I";
    low = "";
    high = "";
  }
}

@observable
class Variable{
  bool isChar;
  String id;
  String _description;
  set description(String description){
    _description = description;
  }
  String get description{
    if(!isChar || _description!=null)
      return _description;
    if(model.globalState.serverState.queryState.queryExecutionState!=null){
      if(_description==null)
        _description = findDescription(model.globalState.serverState.queryState.queryExecutionState.axisColumns, id);
      if(_description==null)
        _description = findDescription(model.globalState.serverState.queryState.queryExecutionState.axisRows, id);
      if(_description==null)
        _description = findDescription(model.globalState.serverState.queryState.queryExecutionState.axisFree, id);
    }
    return _description;
  }
  bool obligatory;
  bool copy;
  String interval;
  String charName;
  int length;
  String dataType;
  String get name{
    if(model.viewState.useDescription&&description!=null&&description.length>0)
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
    if(length<=0)
      return "";
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
  bool get hasValues{
    return !customInput&&dataType!="DATS";
  }
  List<VariableValue> values;
  
  String findDescription(List<Axis> axisList, String char){
    var axisAux = axisList.where((Axis axis)=>axis.id==char);
    if(axisAux.isEmpty)
      return null;
    else
      return axisAux.first.description;
  }
  
  Variable(this.isChar,this.id,description,this.obligatory,this.interval,this.charName, this.length, this.dataType){
    VariableValue value = new VariableValue();    
    if(interval=='I')
      value.operation = "BT";
    values = toObservable([]);
    addVariableValue(value);
    this.description = description;
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
  static final Server BWP = new Server("BWP100", "Produtivo BW", "http://dcsapbwprd01.grupoeda.pt:8000/ZBEX2JSON");
  static final Server BWQ = new Server("BWQ100", "Qualidade BW", "http://dcsapbwq01.grupoeda.pt:8000/ZBEX2JSON");
  static final Server BWD = new Server("BWD100", "Desenvolvimento BW", "http://dcsapbw01.grupoeda.pt:8000/ZBEX2JSON");
  static final Server MOCK = new Server("MOCK", "Sistema Falso para Testes", "../");
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
  List<Server> servers = [Server.BWP,Server.BWQ,Server.BWD];
  Server currentServer = Server.BWP;
  String get serverId{
    if(currentServer==null)
      return "";
    else
      return currentServer.id;
  }
  set serverId(String id){
    window.location.hash = "";
    setServerId(id,true);
  }
  Map<String, Query> queries=toObservable({});
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
    window.location.hash = "";
    setQueryId(id, true);
  }
  Query currentQuery = null;
  
  Future setQueryId(String id, bool modeAll){
    model.globalState.errorMessage="";
    if(modeAll){
      if(id==null||id==""){
        currentQuery=null;
      }else{
        currentQuery = queries[id];
      }
      return model.loadQuery(currentQuery);
    }else{
      Completer completer = new Completer();
      List<String> idAux = id.split("/");
      if(idAux.length==2){
        currentQuery=new Query(idAux[0], idAux[1],id);
        model.globalState.serverState.queryState=new QueryState();
      }
      completer.complete(null);
      return completer.future;
    }
  }
  Future setServerId(String id, bool modeAll){
    if(id==null||id==""){
      currentServer = null;
    }else{
      currentServer = servers.where((Server a){
        return a.id==id;
      }).first;
    }    
    if(modeAll)
      return model.loadQueries();
    else{
      Completer completer = new Completer();
      completer.complete(null);
      return completer.future;
    }
  }
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
  Map<String, List<CharValue>> charValues=toObservable({});
}

@observable
class QueryExecutionState{
  Map bexraw = {};
  bool download=false;
  List<List<Cell>> bextable = toObservable([]);
  List<List<Cell>> bexinfo = toObservable([]);
  List<Axis> newAxisFree = toObservable([]);
  List<Axis> newAxisColumns = toObservable([]);
  List<Axis> newAxisRows = toObservable([]);
  List<Axis> axisFree = toObservable([]);
  List<Axis> axisColumns = toObservable([]);
  List<Axis> axisRows = toObservable([]);
  bool get undoAxisPossible{
    if(newAxisFree.length!=axisFree.length||newAxisColumns.length!=axisColumns.length||newAxisRows.length!=axisRows.length)
      return true;
    for(int i=0; i<axisFree.length;i++)
      if(axisFree[i]!=newAxisFree[i])
        return true;
    for(int i=0; i<axisColumns.length;i++)
      if(axisColumns[i]!=newAxisColumns[i])
        return true;
    for(int i=0; i<axisRows.length;i++)
      if(axisRows[i]!=newAxisRows[i])
        return true;
    return false;
  }
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
    newAxisFree.addAll(newAxisColumns);
    newAxisColumns = toObservable([]);
  }
  
  void clearNewAxisRows(){
    newAxisFree.addAll(newAxisRows);
    newAxisRows = toObservable([]);
  }
}

@observable
class ViewState{
  static const String VIEW_TABLE_ID = "0";
  static const String VIEW_TABLE_DESCRIPTION = "1";
  static const String VIEW_TABLE_ID_AND_DESCRIPTION = "2";  
  static const String GRAPH_MODE_LINE = "0";
  static const String GRAPH_MODE_LINE_FUNCTION = "1";
  static const String GRAPH_MODE_AREA = "2";
  static const String GRAPH_MODE_BAR = "3";
  static const String GRAPH_MODE_COLUMN = "4";
  static const String GRAPH_MODE_PIE = "5";
  bool showSystem = false;
  bool useDescription = true;  
  bool showInformation = false;
  bool showAxis = false;
  bool showTotals = true;
  bool showGrid = true;
  bool expandTableText = false;
  bool showSettings = false;
  String viewTableMode = VIEW_TABLE_DESCRIPTION;
  bool showGraph = false;
  String showGraphMode = GRAPH_MODE_COLUMN;
}

@observable
class GlobalState{
  String errorMessage=null;
  bool loading = false;
  ServerState serverState = new ServerState();
  Map<String, String> lastValues=toObservable({});
}

@observable
class Params{
  bool mock=false;
  bool modeAll=false;
  bool modeTable=false;
  bool modeGraph=false;
  set mode(String mode){
    if(mode==null)
      mode="ALL";
    if(mode.toUpperCase()=="GRAPH")
      modeGraph=true;
    else if(mode.toUpperCase()=="TABLE")
      modeTable=true;
    else{
      modeAll=true;
    }
  }
}