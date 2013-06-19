part of model;

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
  static final Query EMPTYQUERY = new Query("","","---Seleccione um relatório---------------------------------------------------------");
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
    setServerId(id,true);
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