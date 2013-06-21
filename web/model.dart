library model;

import 'dart:json' as json;
import 'dart:html';
import 'dart:async';
import 'package:web_ui/web_ui.dart';
import 'package:jsonp_request/jsonp_request.dart';
import 'package:sharepointauth/authentication.dart';

part 'modelclasses.dart';

Model model = new Model();
final bool useJsonp = false;

class Model{        
  @observable
  Html5Support html5Support;
  @observable
  Params params;
  @observable
  GlobalState globalState= new GlobalState();
  @observable
  ViewState viewState= new ViewState();
  @observable
  Authentication authentication=new Authentication();
    
  Future callService(String service, String endpointParams){
    Completer completer = new Completer();
    String url;
    if(globalState.serverState.currentServer==Server.MOCK)
      url = "${globalState.serverState.currentServer.endpoint}mock_${service}.json?${endpointParams}";
    else
      url = "${globalState.serverState.currentServer.endpoint}?service=${service}${endpointParams}";
    if(useJsonp){
      jsonpRequest(url).then((result) {
        completer.complete(result);
      });
    }else{      
      HttpRequest.request(url).then((req){
        try{
          var result = json.parse(req.responseText);
          completer.complete(result);
        }catch (e,s){
          print("Erro no serviço ${service}: ${e}");
          print(s);
          completer.completeError(e);
        }
      }).catchError((e){
        print("Erro no serviço ${service}: ${e}");
        completer.completeError(e);
      });
    }
    return completer.future;
  }
  
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
    if(low){
      value = variable.values[index].low;
      globalState.lastValues["l-${variable.id}"]=value;
    }else{      
      value = variable.values[index].high;
      globalState.lastValues["h-${variable.id}"]=value;
      if(!variable.values[index].interval){
        variable.values[index].high = "";
        return "";
      }
    }
    /*if(value==null)
      value="";*/
    if(variable.dataType=="NUMC"){
      setValue = true;      
      num missing0 = variable.length-value.length;
      for(num j=0;j<missing0;j++){
        value="0"+value;
      }
    } else if(variable.dataType=="DATS"){
      if(value.length==0)
        value="";
      else if(value.length==8){
        String ano = value.substring(0, 4);
        String mes = value.substring(4, 6);
        String dia = value.substring(6, 8);
        value = "${ano}${mes}${dia}";
      }else if(value.length==10){      
        String ano = value.substring(0, 4);
        String mes = value.substring(5, 7);
        String dia = value.substring(8, 10);
        value = "${ano}${mes}${dia}";
      }else{
        globalState.errorMessage='O valor "${value}" não é uma data';
        return null;
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
  
  Future executeBex(){
    Completer completer=new Completer();
    bool validate = true;
    if(globalState.serverState==null||globalState.serverState.queryState==null)
      validate = false;
    if(validate&&authentication==null){
      globalState.errorMessage="Nenhum utilizador autenticado";
      validate = false;
    }
    String endpointParams="";
    String hash="";
    if(validate){
      endpointParams = "&infocube=${globalState.serverState.currentQuery.infocube}&query=${globalState.serverState.currentQuery.query}";
      endpointParams += "&USER=${authentication.user}";
      endpointParams += "&KEY=${authentication.key}";
      endpointParams += "&DATETIME=${authentication.datetime}";      
      num i = 1;
      for(Variable variable in globalState.serverState.queryState.currentQueryVars){
        bool filled = false;
        for(num index = 0; index<variable.values.length;index++){
          if(variable.values[index].low!=""||variable.values[index].high!=""){
            String low = fillVariableValue(variable, index, true);
            String high = fillVariableValue(variable, index, false);
            if(low==null||high==null)
              validate = false;
            String operation = variable.values[index].operation;
            if(variable.interval=="I"&&(high==null||high==""))
              operation="EQ";
            hash += "&VAR${i}_VNAM=${variable.id}&VAR${i}_OPT=${operation}&VAR${i}_SIGN=${variable.values[index].sign}&VAR${i}_LOW=${low}&VAR${i}_HIGH=${high}";                  
            i++;
            filled = true;
          } else if (!filled&&variable.obligatory){
            globalState.errorMessage='O filtro "${variable.name}" é obrigatório';
            validate = false;
          }
        }
      }
    }
    if(validate && globalState.serverState.queryState.queryExecutionState!=null){
      hash += fillUrlAxis("FREE", globalState.serverState.queryState.queryExecutionState.newAxisFree);
      hash += fillUrlAxis("COL", globalState.serverState.queryState.queryExecutionState.newAxisColumns);
      hash += fillUrlAxis("ROW", globalState.serverState.queryState.queryExecutionState.newAxisRows);
    }
    if(validate){
      endpointParams+=hash;
      globalState.loading=true;
      globalState.serverState.queryState.queryExecutionState = new QueryExecutionState();
      callService("execute",endpointParams).then((result){
        assignBexResult(result);
        hash="execute&serverId=${globalState.serverState.serverId}&queryId=${globalState.serverState.currentQueryId}${hash}";
        window.location.hash=hash;
        completer.complete(null);
      }).catchError((e){
        globalState.loading=false;
        model.globalState.errorMessage='Erro na execução do serviço no servidor "${globalState.serverState.currentServer.name}"';
        completer.completeError(e);
      });
    }else{
      completer.completeError(null);
    }
    return completer.future;
  }
  
  void assignQueries(Map result){
    globalState.errorMessage=null;
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
      globalState.serverState.queryState.currentQueryVars.sort((Variable a, Variable b) {
        if(a.obligatory)
          if(b.obligatory)
            return 0;
          else
            return -1;
        else
          return 1;
      });
      for(Variable i in globalState.serverState.queryState.currentQueryVars){
        String high = globalState.lastValues["h-${i.id}"];
        if(high!=null)
          i.values[0].high=high;
        String low = globalState.lastValues["l-${i.id}"];
        if(low!=null)
          i.values[0].low=low;
      }
    }
    globalState.loading=false;
  }
  
  Future loadQuery(Query query){
    Completer completer=new Completer();
    globalState.loading = true;
    globalState.serverState.queryState=null;
    if(query==null || query==""){
      globalState.loading=false;
      completer.completeError(null);
    }else{
      String endpointParams = "&infocube=${query.infocube}&query=${query.query}";
      callService("getquery",endpointParams).then((result){
        assignGetVarsResult(result);
        completer.complete(null);
      }).catchError((e){
        globalState.loading=false;
        model.globalState.errorMessage='Erro na execução do serviço no servidor "${globalState.serverState.currentServer.name}"';
        completer.completeError(e);
      });
    }
    return completer.future;
  }
  
  Future loadQueries(){
    Completer completer=new Completer();
    globalState.serverState.currentQueryId = null;
    globalState.serverState.queryState = null;
    globalState.serverState.queries = {};
    if(globalState.serverState.currentServer!=null){
      callService("getqueries","").then((result){
        assignQueries(result);
        completer.complete(null);
      }).catchError((e){
        globalState.loading=false;
        model.globalState.errorMessage='Erro na execução do serviço no servidor "${globalState.serverState.currentServer.name}"';
        completer.completeError(e);
      });
    }else{
      completer.completeError(null);
    }
    return completer.future;
  }
  
  String replaceVariableValue(String dataType, String value){
    if(value==null)
      return null;
    else{
      String str = value.replaceAllMapped(new RegExp(r"d{{[^}]*}}"), (Match match){
        String expression=match.group(0).substring(3, match.group(0).length-2);
        DateTime date = new DateTime.now();
        List<String> comps = expression.replaceAll(" ", "").split(",");
        try{
          int day=date.day;
          int month=date.month;
          int year=date.year;
          if(comps.length>=3)
            if(comps[2].startsWith("_"))
              day += int.parse(comps[2].substring(1));
            else
              day = int.parse(comps[2]);
          if(comps.length>=2)
            if(comps[1].startsWith("_"))
              month += int.parse(comps[1].substring(1));
            else
              month = int.parse(comps[1]);
          if(comps.length>=1)
            if(comps[0].startsWith("_"))
              year += int.parse(comps[0].substring(1));
            else
              year = int.parse(comps[0]);
          date = new DateTime(year, month, day);
        }catch(e, s){
          print(e);
          print(s);
        }
        String dateStr = date.toString().substring(0,10);
        print("${expression}=${dateStr}");
        return dateStr;
      });
      if(dataType=="DATS"&&str.length==8)
        str=str.substring(0, 4)+"-"+str.substring(4, 6)+"-"+str.substring(6, 8);
      return str;
    }
  }
  void fillVarsFromHash(Map<String, String> params){
    QueryExecutionState qes = new QueryExecutionState();
    globalState.serverState.queryState.queryExecutionState=qes;
    List<Variable> vars = globalState.serverState.queryState.currentQueryVars;
    Map<String, Map<String, String>> paramVars = {};
    for(String k in params.keys){
      String p=k.toLowerCase();
      if(p.startsWith("var")){
        List<String> aux = p.split("_");
        if(aux.length==2){
          if(paramVars[aux[0]]==null){
            paramVars[aux[0]]={};
          }
          paramVars[aux[0]][aux[1]]=params[k];
        }
      }else if(p.startsWith("free")){
        qes.newAxisFree.add(new Axis(params[k],params[k]));
      }else if(p.startsWith("col")){
        qes.newAxisColumns.add(new Axis(params[k],params[k]));
      }else if(p.startsWith("row")){
        qes.newAxisRows.add(new Axis(params[k],params[k]));
      }
    }
    for(Map<String, String> varMap in paramVars.values){
      String vnam = varMap['vnam'];
      var variables = vars.where((Variable v){
        return v.id==vnam;
      });
      Variable variable;
      if(variables.isEmpty){        
        variable = new Variable(vnam,vnam,false,"S",vnam,100,"CHAR");
        vars.add(variable);
      }else{
        variable = variables.first;        
      }
      if(variable!=null){
        VariableValue variableValue = new VariableValue();
        if(varMap['opt']!=null)
          variableValue.operation=varMap['opt'];
        if(varMap['sign']!=null)
          variableValue.sign=varMap['sign'];
        if(varMap['low']!=null)
          variableValue.low=replaceVariableValue(variable.dataType, varMap['low']);
        if(varMap['high']!=null)
          variableValue.high=replaceVariableValue(variable.dataType, varMap['high']);
        variable.values.add(variableValue);
      }
    }
    for(Variable variable in vars)
      if(variable.values.length>1)
        variable.values.removeAt(0);
  }
  
  void assignData(String charName, Map result){
    List<CharValue> list = [];
    if(result['error']!=null)
      model.globalState.errorMessage=result['error'];
    else
      for(Map i in result['data']){
        list.add(new CharValue(i['id'],i['desc']));
      }
    model.globalState.charValues[charName]=list;
  }
  
  Future loadData(String charName){
    Completer completer=new Completer();
    callService("getdata","").then((result){
      assignData(charName, result);
      completer.complete(null);
    }).catchError((e){
      model.globalState.errorMessage='Erro na execução do serviço no servidor "${globalState.serverState.currentServer.name}"';
      completer.completeError(e);
    });
    return completer.future;
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
  Map<String, String> paramsHash = getUriParams(window.location.hash);
  model.params = new Params();
  model.params.mock = params['mock']!=null;
  model.params.mode = params['mode'];
  if(model.params.mock)
    model.globalState.serverState.servers.add(Server.MOCK);  
  Future future;
  if(paramsHash['serverId']!=null)
    future = model.globalState.serverState.setServerId(paramsHash['serverId'], model.params.modeAll);
  else
    if(model.params.mock)
      future = model.globalState.serverState.setServerId(Server.MOCK.id, model.params.modeAll);
    else
      future = model.globalState.serverState.setServerId(Server.BWP.id, model.params.modeAll);
  if(paramsHash['queryId']!=null){
    future.then((_){
      Future future = model.globalState.serverState.setQueryId(paramsHash['queryId'], model.params.modeAll);
      future.then((_){
        model.fillVarsFromHash(paramsHash);
        if(paramsHash['execute']!=null){
          model.authentication.waitForAuthentication().then((_){
            model.executeBex();
          });
        }
      });
    });
  }
  // Enable this to use Shadow DOM in the browser.
  //useShadowDom = true;
}