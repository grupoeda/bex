import 'model.dart';
import 'package:web_ui/web_ui.dart';
import 'package:web_ui/watcher.dart' as watchers;
import 'dart:html';

class XBexAxis extends WebComponent {
@observable
  Axis selectedAxis;
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
  
  void clickAxis(Axis axis){
    if(selectedAxis==axis)
      selectedAxis=null;
    else
      selectedAxis=axis;
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
      moveCell(axisList, axis, _axisList, _axis);
    }
  }
  void moveCellPos(int offset, List<Axis> _axisList, Axis _axis){
    int _pos = _axisList.indexOf(_axis)+offset;
    Axis axis;
    if(offset<0)
      if(_pos<=0)
        axis = null;
      else
        axis = _axisList[_pos-1];
    else
      if(_pos>=_axisList.length)
        axis = _axisList[_axisList.length-1];
      else
        axis = _axisList[_pos];
    moveCell(_axisList, axis, _axisList, _axis);
  }
  void moveCell(List<Axis> axisList, Axis axis, List<Axis> _axisList, Axis _axis){
    if (axis!=_axis) {   
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
