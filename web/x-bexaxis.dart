import 'model.dart';
import 'package:web_ui/web_ui.dart';
import 'package:web_ui/watcher.dart' as watchers;
import 'dart:html';

class XBexAxis extends WebComponent {  
  Element _dragSourceEl;
  List<Axis> _axisList;
  Axis _axis;

  void reset(){
    model.globalState.serverState.queryState.queryExecutionState.resetNewAxis();
  }
  
  void clearNewAxisRows(){
    model.globalState.serverState.queryState.queryExecutionState.clearNewAxisRows();
  }

  void clearNewAxisColumns(){
    model.globalState.serverState.queryState.queryExecutionState.clearNewAxisColumns();
  }
  
  void invert(){
    List<Axis> temp = model.globalState.serverState.queryState.queryExecutionState.newAxisColumns;
    model.globalState.serverState.queryState.queryExecutionState.newAxisColumns = model.globalState.serverState.queryState.queryExecutionState.newAxisRows;
    model.globalState.serverState.queryState.queryExecutionState.newAxisRows = temp;
  }
  
  void _onDragStart(MouseEvent event, List<Axis> axisList, Axis axis) {
    Element dragTarget = event.target;
    dragTarget.classes.add('moving');
    _dragSourceEl = dragTarget;
    _axisList = axisList;
    _axis = axis;
    event.dataTransfer.effectAllowed = 'move';
    event.dataTransfer.setData('text/html', dragTarget.innerHtml);
  }

  void _onDragEnd(MouseEvent event) {
    Element dragTarget = event.target;
    dragTarget.classes.remove('moving');
    var cols = document.queryAll('.panelAxisColumn .axis .axisHeader');
    for (var col in cols) {
      col.classes.remove('over');
    }
  }

  void _onDragEnter(MouseEvent event) {
    Element dropTarget = event.target;
    dropTarget.classes.add('over');
  }

  void _onDragOver(MouseEvent event) {
    // This is necessary to allow us to drop.
    event.preventDefault();
    event.dataTransfer.dropEffect = 'move';
  }

  void _onDragLeave(MouseEvent event) {
    Element dropTarget = event.target;
    dropTarget.classes.remove('over');
  }

  void _onDrop(MouseEvent event, List<Axis> axisList, Axis axis) {
    // Stop the browser from redirecting.
    event.stopPropagation();
    // Don't do anything if dropping onto the same column we're dragging.
    Element dropTarget = event.target;
    if (_dragSourceEl != dropTarget) {   
      int pos;      
      if(axis==null)
        pos=0;
      else
        pos = axisList.indexOf(axis)+1;
      int _pos = _axisList.indexOf(_axis);
      if(pos>=axisList.length)
        axisList.add(_axis);
      else
        axisList.insert(pos, _axis);
      if(axisList!=_axisList)
        _axisList.removeAt(_pos);
      else{
        if(pos>_pos)
          _axisList.removeAt(_pos);
        else
          _axisList.removeAt(_pos+1);
      }
    }
  }
}
