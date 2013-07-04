import 'model.dart';
import 'package:web_ui/web_ui.dart';
import 'package:crypto/crypto.dart';
import 'dart:async';
import 'dart:utf';

class XDownload extends WebComponent {
  QueryExecutionState queryexecutionstate;
  Query currentquery;
  String filename = "bex-download.xml";
@observable
  bool downloadReady = false;
  String filedata;
  
  String prepareData(){
    String data = 
'<?xml version="1.0"?>'+
'<?mso-application progid="Excel.Sheet"?>'+
'<Workbook xmlns="urn:schemas-microsoft-com:office:spreadsheet" xmlns:o="urn:schemas-microsoft-com:office:office" xmlns:x="urn:schemas-microsoft-com:office:excel" xmlns:ss="urn:schemas-microsoft-com:office:spreadsheet" xmlns:html="http://www.w3.org/TR/REC-html40">'+
'  <DocumentProperties xmlns="urn:schemas-microsoft-com:office:office">'+
'  </DocumentProperties>'+
'  <ExcelWorkbook xmlns="urn:schemas-microsoft-com:office:excel">'+
'    <ProtectStructure>False</ProtectStructure>'+
'    <ProtectWindows>False</ProtectWindows>'+
'  </ExcelWorkbook>'+
'  <Styles>'+
'    <Style ss:ID="Default" ss:Name="Normal">'+
'      <Alignment ss:Vertical="Center" />'+
'    </Style>'+
'    <Style ss:ID="cell1"><Font ss:Bold="1" ss:Color="#FFFFFF" /><Interior ss:Color="#1ED062" ss:Pattern="Solid" /><Alignment ss:Horizontal="Center" ss:Vertical="Center"/></Style>'+
'    <Style ss:ID="cell0"><Font ss:Bold="1" ss:Color="#FFFFFF" /><Interior ss:Color="#1E62D0" ss:Pattern="Solid" /><Alignment ss:Horizontal="Center" ss:Vertical="Center"/></Style>'+
'    <Style ss:ID="cell11"><Interior ss:Color="#C0F0C0" ss:Pattern="Solid" /><Alignment ss:Horizontal="Center" ss:Vertical="Center"/></Style>'+
'    <Style ss:ID="cell10"><Interior ss:Color="#C0C0F0" ss:Pattern="Solid" /><Alignment ss:Horizontal="Center" ss:Vertical="Center"/></Style>'+
'    <Style ss:ID="cell20"><Interior ss:Color="#F0F0F0" ss:Pattern="Solid" /><Alignment ss:Horizontal="Right" ss:Vertical="Center"/><NumberFormat ss:Format="Fixed"/></Style>'+
'    <Style ss:ID="cell99"></Style>'+
'  </Styles>'+
'  <Worksheet ss:Name="${currentquery.description.substring(0,31>currentquery.description.length?currentquery.description.length:31)}">'+
'    <Table>';
    for(List<Cell> row in queryexecutionstate.bextable){
      if(row.length>0&&!row[0].totalRow){
        data+=
'      <Row>';
        for(Cell cell in row){
          if(!cell.totalColumn){
            if(cell.type==Cell.CELL){
              data+='        <Cell ss:StyleID="cell${cell.type}"><Data ss:Type="Number">${cell.id}</Data></Cell><Cell ss:StyleID="cell${cell.type}"><Data ss:Type="String">${cell.unit}</Data></Cell>';
            }else if (cell.type==Cell.CHARDATAROW){
              data+='        <Cell ss:StyleID="cell${cell.type}"><Data ss:Type="String">${cell.id}</Data></Cell><Cell ss:StyleID="cell${cell.type}"><Data ss:Type="String">${cell.description}</Data></Cell>';
            }else if (cell.type==Cell.CHARDATACOLUMN){
              data+='        <Cell ss:StyleID="cell${cell.type}"><Data ss:Type="String">${cell.value}</Data></Cell><Cell ss:StyleID="cell${cell.type}"><Data ss:Type="String">${cell.value==""?"":"Unidade"}</Data></Cell>';
            }else if (cell.type==Cell.CHARINFOROW){
              data+='        <Cell ss:StyleID="cell${cell.type}"><Data ss:Type="String">${cell.value}</Data></Cell><Cell ss:StyleID="cell${cell.type}"><Data ss:Type="String">Descrição</Data></Cell>';
            }else if (cell.type==Cell.CHARINFOCOLUMN){
              data+='        <Cell ss:StyleID="cell${cell.type}"><Data ss:Type="String">${cell.value}</Data></Cell><Cell ss:StyleID="cell${cell.type}"><Data ss:Type="String"></Data></Cell>';
            }else if (cell.type==Cell.EMPTY){
              data+='        <Cell ss:StyleID="cell${cell.type}"><Data ss:Type="String"></Data></Cell><Cell ss:StyleID="cell${cell.type}"><Data ss:Type="String"></Data></Cell>';
            }
          }
        }
        data+=
'      </Row>';
      }
    }
    data+=
'    </Table>'+
'    <WorksheetOptions xmlns="urn:schemas-microsoft-com:office:excel">'+      
'      <Selected />'+
'      <ProtectObjects>False</ProtectObjects>'+
'      <ProtectScenarios>False</ProtectScenarios>'+
'    </WorksheetOptions>'+
'  </Worksheet>'+
'</Workbook>';
    List bytes = encodeUtf8(data);    
    return CryptoUtils.bytesToBase64(bytes);
  }
  
  void inserted(){
    new Future.delayed(new Duration(milliseconds:500), (){
      filedata = prepareData();
      downloadReady = true;
    });
  }
}

