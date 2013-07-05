import 'model.dart';
import 'package:web_ui/web_ui.dart';
import 'dart:html';
import 'dart:async';
import 'package:js/js.dart' as js;

class XGraph extends WebComponent {
@observable
  bool isReady = false;
@observable
  ViewState viewstate;
@observable
  List<List<Cell>> bextable;
@observable
  Map bexraw;
@observable
  List<List> chartdata=[];
@observable
  Map options={};
  
  void drawVisualization() {
    if(isReady&&fillChartData()){
      var gviz = js.context.google.visualization;
      var arrayData = js.array(chartdata);
      var tableData = gviz.arrayToDataTable(arrayData);
      var jsoptions = js.map(options);      
      var chart;
      Element graphElement=query('#graphvisualization');
      if(graphElement!=null){
        if(viewstate.showGraphMode==ViewState.GRAPH_MODE_LINE || viewstate.showGraphMode==ViewState.GRAPH_MODE_LINE_FUNCTION)
          chart = new js.Proxy(gviz.LineChart, graphElement);
        else if(viewstate.showGraphMode==ViewState.GRAPH_MODE_AREA)
          chart = new js.Proxy(gviz.AreaChart, graphElement);
        else if(viewstate.showGraphMode==ViewState.GRAPH_MODE_BAR)
          chart = new js.Proxy(gviz.BarChart, graphElement);
        else if(viewstate.showGraphMode==ViewState.GRAPH_MODE_COLUMN)
          chart = new js.Proxy(gviz.ColumnChart, graphElement);
        else if(viewstate.showGraphMode==ViewState.GRAPH_MODE_PIE)
          chart = new js.Proxy(gviz.PieChart, graphElement);      
        if(chart!=null&&graphElement!=null){        
          chart.draw(tableData, jsoptions);
        }
      }
    }
  }
  
  bool fillChartData(){
    List<List> chartdata=[];
    Map options={};
    if(bexraw==null||bexraw['row_data']==null||bexraw['col_data']==null||bexraw['row_data'].length==0||bexraw['col_data'].length==0){
      model.globalState.errorMessage="Tabela necessita de ter 1 ou mais linhas e colunas para mostrar gráfico'";
      return false;
    }
    List<String> header = [];
    String headerId="";
    String separator="";
    for(int i=0; i<bexraw['row_info'].length;i++){
      headerId+=separator+=bextable[bexraw['col_info'].length][i].value;
      separator="/";
    }
    options["hAxis"]={"title":headerId,"textPosition":"out"};
    options["legend"]={"position":"top"};
    if(viewstate.showGraphMode==ViewState.GRAPH_MODE_LINE_FUNCTION)
      options["curveType"]="function";
    header.add(headerId);
    for(int j=bexraw['row_info'].length; j<bextable[0].length;j++){
      String headerId="";
      String separator="";
      if(!bextable[0][j].totalColumn){
        for(int i=0; i<bexraw['col_info'].length;i++){
          headerId+=separator+=bextable[i][j].value;
          separator="/";
        }
        header.add(headerId);
      }
    }    
    chartdata.add(header);
    List<String> units=[];
    for(int j=bexraw['row_info'].length; j<bextable[0].length; j++){
      if(!bextable[0][j].totalColumn)
        units.add(null);
    }
    for(int i=bexraw['col_info'].length+1; i<bextable.length;i++){
      if(bextable[i][0].totalRow)
        continue;
      List line = [];
      String char="";
      String separator="";
      for(int j=0; j<bexraw['row_info'].length; j++){
        char+=separator+bextable[i][j].value;
        separator="/";
      }
      line.add(char);
      int k = 0;
      for(int j=bexraw['row_info'].length; j<bextable[0].length; j++){
        if(!bextable[i][j].totalColumn){
          String value = bextable[i][j].id;
          if(value!="")
            line.add(double.parse(value));
          else
            line.add(0);          
          if(units[k]==null){
            units[k]=bextable[i][j].unit;
          }else{
            if(units[k]!=bextable[i][j].unit){
              model.globalState.errorMessage="Unidades diferentes para '${header[j]}'";
              return false;
            }
          }
          k++;
        }
      }
      chartdata.add(line);
    }
    Map<String, List<int>> unitsMap = {};
    for(int i = 0; i<units.length;i++){
      if(unitsMap[units[i]]==null)
        unitsMap[units[i]]=[];
      unitsMap[units[i]].add(i);
    }
    List<Map> vAxes = [];
    List<String> vAxesPos = ["out","out","in"];
    int i = 0;
    Map unitsMapAux = {};
    for(int k = 0; k<unitsMap.keys.length;k++){
      String x = unitsMap.keys.elementAt(k);
      unitsMapAux[x]=k;
      vAxes.add({"title":x,"textPosition":vAxesPos[i]});
      if(i<vAxesPos.length)
        i++;
    }
    options["vAxes"]=vAxes;
    List<Map> series = [];
    for(int i=0;i<units.length;i++){
      if(units[i]!="")
        header[i+1]+=" (${units[i]})";
      series.add({"targetAxisIndex":unitsMapAux[units[i]]});
    }
    options["series"]=series;
    this.chartdata=chartdata;
    this.options=options;
    model.globalState.errorMessage=null;
    return true;
  }
  
  void ready(){
    isReady=true;
  }
  
  void inserted() {
    observe(()=>viewstate,(_){
      new Future.delayed(new Duration(milliseconds:0),(){drawVisualization();});
    });
    observe(()=>isReady,(_){
      new Future.delayed(new Duration(milliseconds:0),(){drawVisualization();});
    });
    observe(()=>bextable,(_){
      new Future.delayed(new Duration(milliseconds:0),(){drawVisualization();});
    });
    js.context.google.load('visualization', '1', js.map({
      'packages': ['corechart'],
      'callback': new js.Callback.once(ready)
    }));
  }
}
